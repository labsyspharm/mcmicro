# Roadmap: migrating `main.nf` to the Nextflow strict parser

## Background

Starting with Nextflow 25.10, scripts and configs are parsed with the strict
syntax parser (`NXF_SYNTAX_PARSER=v2`) by default. MCMICRO's main pipeline does
not compile under it:

```
$ nextflow run labsyspharm/mcmicro --in exemplar-001
Error main.nf:11:16: Unexpected input: '*'
│  11 | import mcmicro.*
```

Users on current Nextflow can work around this with `NXF_SYNTAX_PARSER=v1`,
but the legacy parser is expected to be removed eventually. CI is affected
too: `.github/workflows/ci.yml` installs the latest Nextflow via
`curl -fsSL get.nextflow.io | bash`.

`exemplar.nf` and `nextflow.config` (the `$HOME` reference in the `O2ext`
profile, issue #59) were already migrated. This roadmap covers the main
pipeline: `main.nf` and everything it pulls in (`lib/worker.nf`,
`modules/*.nf`, `roadie.nf`).

### Goal and constraints

- `nextflow lint .` reports no errors for the main pipeline.
- **Minimum supported version: Nextflow 25.04.7.** This is the oldest release
  the testing strategy covers. It is enforced with `manifest.nextflowVersion`
  (Phase 2).
- **The legacy parser stays supported until Nextflow officially removes it.**
  Until then, the same code must run under both parsers, so syntax that only
  the strict parser accepts (`onComplete:` workflow sections, typed
  `params {}` blocks, workflow `output {}` blocks) is not allowed. Each
  recommendation below has been checked against this constraint (see
  *Verified findings*).
- **Parameter source priority stays exactly as documented** in
  [`docs/parameters/index.md`](../docs/parameters/index.md#parameter-value-prioritization)
  (*Parameter value prioritization*), from lowest to highest:
  1. defaults in `config/defaults.yml`
  2. the project's `params.yml`
  3. a YAML file passed with `--params`
  4. individual `--` arguments on the command line

  In particular, values in `params.yml` are never overridden by defaults.
  The code also has one undocumented layer: the `workflow:` / `options:` /
  `modules:` sections of a Nextflow `-params-file`, applied between levels 3
  and 4 (`Opts.parseParams`). It stays where it is. Any change that would
  alter this order, even for that layer, is out of scope for this migration.
- No change in pipeline behavior: same outputs, same parameters, same
  `qc/params.yml` provenance.

## How this roadmap was built

`nextflow lint` stops at the first fatal error in each file, so the initial
lint (16 files with errors) hides most of the problems. To surface the full
list, the fixes below were applied incrementally to a scratch copy of the repo
and the linter was rerun until it came back clean. All line numbers refer to
the files as of commit `07ccae6`.

## Verified findings

These were tested directly against Nextflow 26.10.2 (both parsers) and 25.04.7.

1. **Classes in `lib/` work with fully qualified names.** `import mcmicro.*`
   is not allowed, but `mcmicro.Util.cleanFilename(...)` lints cleanly and runs
   under both parsers. Unqualified `Util.cleanFilename(...)` fails
   (`Util is not defined`).
2. **`lib/` classes cannot be referenced inside `when:` sections.**
   `when: mcmicro.Flow.doirun(...)` is a hard compile error under the strict
   parser (`mcmicro is not defined`), even though the same expression works in
   `script:`. Since every module gates execution with
   `when: Flow.doirun(...)`, removing `when:` is **required** for this
   migration, not just a deprecation cleanup.
3. **Use `workflow.onComplete { }` inside the workflow body, not an
   `onComplete:` section.** The new `onComplete:` workflow section only
   compiles under the strict parser. Both the legacy parser and Nextflow
   25.04.7 reject it with `Unknown execution scope 'onComplete:'`. An inline
   `workflow.onComplete { ... }` handler inside the entry workflow body works on
   all three and can see local variables such as `mcp`.
4. **Under the strict parser, undeclared CLI parameters are always Strings.**

   | `nextflow run types.nf --a 2 --b false --c --d 1.5` | `a` | `b` | `c` | `d` |
   |---|---|---|---|---|
   | 26.10.2, legacy parser / 25.04.7 | Integer `2` | Boolean `false` | Boolean `true` | Double `1.5` |
   | 26.10.2, strict parser | String `"2"` | String `"false"` | String `"true"` | String `"1.5"` |

   MCMICRO accepts arbitrary workflow parameters on the command line through
   `Opts.cleanParams`, so they cannot all be declared up front. Without a fix,
   `--tma false` or `--background false` becomes the truthy string `"false"`
   and silently **enables** the step. This is the highest-risk behavior change
   in the migration, and the linter cannot detect it.
5. **A typed `params {}` block does not solve finding 4**, even once the
   legacy parser is gone (tested on 26.10.2 with the strict parser):
   - An unset `Boolean` parameter is `false`, even when declared
     `tma: Boolean? = null`. So "not given" cannot be told apart from
     "`false`", and the default would override `params.yml`.
   - Every parameter must be declared. An undeclared one is a hard error
     (`Parameter ashlarOpts was specified on the command line or params file
     but is not declared in the script or config`), which rules out the
     open-ended `--<module>-opts` and `--<module>-model` parameters unless
     each one is declared.
   - The legacy parser and 25.04.7 cannot parse the block at all
     (`Unexpected input: '{'`).

## Testing strategy

Every phase goes through the same three-step cycle:

1. **Capture a baseline.** Before changing anything, run the code as it stands
   at the start of the phase under the legacy parser, and capture its outputs.
   Only run the test cases that exercise code the phase touches (each phase
   lists them under **Testing**). Do not capture outputs for parts of the
   pipeline the phase does not affect.
2. **Implement** the changes for the phase.
3. **Compare.** Run the same test cases on each candidate runtime and compare
   the captures against the baseline.

### Runtimes

| Role | Nextflow | Parser | Environment |
|---|---|---|---|
| Baseline (step 1) | 26.10.2 | legacy | `NXF_VER=26.10.2 NXF_SYNTAX_PARSER=v1` |
| Candidate | 25.04.7 | legacy | `NXF_VER=25.04.7 NXF_SYNTAX_PARSER=v1` |
| Candidate | 26.10.2 | legacy | `NXF_VER=26.10.2 NXF_SYNTAX_PARSER=v1` |
| Candidate | 26.10.2 | strict | `NXF_VER=26.10.2 NXF_SYNTAX_PARSER=v2` |

Set `NXF_SYNTAX_PARSER` explicitly on every run, so the parser doesn't depend
on a version's default or on the shell environment.

**Before the code compiles under the strict parser:** `main.nf` will not
compile under the strict parser until Phases 1–3 are all in. For Phases 1 and
2, the strict candidate is therefore a lint check instead of a pipeline run:

```bash
NXF_VER=26.10.2 nextflow lint main.nf lib modules roadie.nf -o concise > lint.txt
```

Run it at the baseline and after the changes. The lint errors the phase
targets must be gone, and no new errors may appear. Pipeline runs under the
strict parser start with Phase 3.

### Test data

- `~/exemplar-002` is used **only** for dearray (coreograph) cases. Its
  `params.yml` sets `tma: true`, so every run on it is a TMA run.
- `~/exemplar-001-af` is used **only** for background subtraction cases. It
  holds cycles 1–3 of exemplar-001, which contain the autofluorescence
  channels (`AF488`, `AF555`, `AF647`) referenced in the `background` column
  of its `markers.csv`. CI uses the same data (`ex001-af` cache).
- `~/exemplar-001` (the default cycles 6–8) is used for everything else.

If a directory is missing, download it (from the repository root):

```bash
nextflow run exemplar.nf --name exemplar-001 --path ~
nextflow run exemplar.nf --name exemplar-002 --path ~

# exemplar.nf always creates <path>/exemplar-001, so download the AF cycles
# to a temporary location and rename
nextflow run exemplar.nf --name exemplar-001 --from-cycle 1 --to-cycle 3 --path ~/af-tmp
mv ~/af-tmp/exemplar-001 ~/exemplar-001-af && rmdir ~/af-tmp
```

**Never run the pipeline directly on `~/exemplar-*`.** MCMICRO publishes its
results into the `--in` directory, and on later runs it treats results found
there as precomputed inputs, which would contaminate other test cases. Each
run gets its own project directory, built with hard links so it costs no
extra disk space (the inputs are only read, never written):

```bash
# $RUN = <test root>/<phase>/<case>/<runtime>
mkdir -p $RUN/project
cp -al ~/exemplar-001/raw ~/exemplar-001/markers.csv ~/exemplar-001/illumination $RUN/project/
```

Keep the test root outside the repository (e.g. `~/mcmicro-tests`). Run
Nextflow from `$RUN` with `-w $RUN/work`, so each run has its own `.nextflow/`
cache and work directory. Never use `-resume`.

**Seeded intermediates.** Partial runs (`--start-at` later than
`registration`) need upstream results in the project directory:

- *exemplar-001:* copy (`cp -al`) the `registration/`, `probability-maps/`,
  `segmentation/` and `quantification/` directories from the **baseline** run
  of E1-default of the same phase. Use the same seed for the baseline and all
  candidates.
- *exemplar-001-af:* copy the `background/` directory from the **baseline**
  run of AF-backsub of the same phase.
- *exemplar-002:* registering 10 cycles is expensive and is not what the E2
  case tests. Produce `registration/` once, at the start of Phase 1, with
  `--start-at registration --stop-at registration` on the baseline runtime,
  store it under `<test root>/seeds/e2-registration/`, and reuse it in every
  phase. Changes to registration itself are covered by the exemplar-001 cases.

### What to capture

Run each case with `-with-trace trace.txt` and collect the following into
`$RUN/capture/`:

| Capture | How | Catches |
|---|---|---|
| `tasks.txt` | process names from `trace.txt` (column 4, with the ` (tag)` suffix removed) and their status, counted with `sort \| uniq -c` | steps that run or are skipped when they shouldn't be (gating, Phases 3–4) |
| `commands/` | the contents of `project/qc/provenance/*.sh`, stored as a sorted set of files named by content hash | any change in the command line a tool receives (options, file names, `--crop`, `--nucleiRegion bypass`, …) |
| `params.yml` | `project/qc/params.yml` | changes in parameter parsing and types (Phases 2 and 4) |
| `manifest.tsv` | relative path, size and SHA-256 of every published file, excluding `raw/`, `qc/provenance/` and `qc/metadata.yml` | missing or extra outputs, changes in content |
| `exit.txt` | exit code, plus the first `ERROR ~` line of `.nextflow.log` | negative test cases |

Store the provenance scripts by content, not by name. Their names include
`task.index`, which depends on task ordering and can change from run to run.

### Comparing

```bash
diff -r <phase>/<case>/baseline/capture <phase>/<case>/<runtime>/capture
```

Every difference must be either fixed or explained in the PR for the phase.
Expected differences:

- **Nondeterministic files.** Some tools may not produce byte-identical
  images run to run (e.g. timestamps in TIFF metadata). At the start of Phase
  1, run the E1-default baseline **twice** and list the files whose checksums
  differ in `<test root>/nondeterministic.txt`. For those files, compare paths
  and sizes only. If a checksum differs anywhere else while `commands/` is
  identical, rerun the baseline before treating it as a regression.
- **`params.yml` under the strict parser in Phase 3.** Values passed on the
  command line are Strings until Phase 4 (finding 4). Compare them after
  converting values to strings, and leave explicit `false` values off the
  command line in Phase 3 strict runs. Phase 4 removes this exception.
- **`qc/metadata.yml`.** `githubTag` / `githubCommit` are empty for local
  runs. Check that the file exists and that `roadie:` matches.

### Test case catalog

Each phase picks its cases from this list. `P` is the project directory of
the run.

| ID | Data | Command | Exercises |
|---|---|---|---|
| **E1-default** | E1 | `--in P` | default flow: ashlar → unmicst (`worker`) → s3seg → mcquant; background, dearray and viz are skipped |
| **E1-illum** | E1, without `illumination/` | `--in P --start-at illumination --stop-at registration` | `illumination.nf`, profile channels in `main.nf`, joins in `registration.nf` |
| **E1-steps** | E1 + seed `registration/` | in one project dir, in order: `--start-at segmentation --stop-at segmentation`, `--start-at watershed --stop-at watershed`, `--start-at quantification --stop-at quantification` (from `ci.yml`) | discovering precomputed intermediates (`findFiles*`, `pre_*` channels) and `--start-at` / `--stop-at` gating |
| **E1-seg-multi** | E1 + seed `registration/` | `--in P --start-at segmentation --segmentation unmicst,cellpose` | both segmentation branches: probability maps → s3seg and instance segmentation (`watershed: no`) |
| **E1-recyze** | E1 + seed `registration/` | `--in P --start-at segmentation --stop-at segmentation --segmentation-recyze --segmentation-channel 1` | `include` of `roadie`, `roadie.nf` `runTask` |
| **E1-downstream** | E1 + seed `quantification/` | `--in P --start-at downstream --stop-at downstream --downstream scimap` | `downstream.nf`, `worker` from downstream |
| **E1-viz** | E1 | `--in P --stop-at registration --viz` | `viz.nf` (autominerva) |
| **E2-dearray** | E2 + seed `e2-registration/` + `markers.csv`, `params.yml` | `--in P --start-at dearray --stop-at watershed` | coreograph, `pre_img` for TMA, TMA mask joins in `segmentation.nf`, s3seg `--crop dearray` |
| **AF-backsub** | AF | `--in P --background` (from `ci.yml`) | `background.nf` (backsub, `GStringTemplateEngine` command), the background branches of `img` and `chMrk` in `main.nf`, and `markers_bs.csv` reaching quantification |
| **AF-rollingball** | AF | `--in P --background --background-method imagej-rolling-ball --stop-at background` (from `ci.yml`) | the second background module, and module selection by `--background-method` in `Opts.parseParams` |
| **AF-bs-pre** | AF + seed `registration/`, `background/` | `--in P --background --start-at segmentation` | precomputed `pre_bsub` / `pre_bsubm` |
| **R-cli** | none | `nextflow run roadie.nf --list-tasks`, then `nextflow run roadie.nf --help recyze` | roadie CLI workflow, `showHelp` |
| **N-noin** | none | `nextflow run main.nf` (no `--in`) | must fail with `Please specify the project directory with --in` and run no tasks |
| **N-deprecated** | E1 + empty `illumination_profiles/x` | `--in P` | must fail with `illumination_profiles/ is deprecated` |
| **N-version** | none | `nextflow run main.nf`, `exemplar.nf` and `roadie.nf` with `NXF_VER` set to a release below 25.04.7 (e.g. the latest 24.10.x) | the `manifest.nextflowVersion` check refuses all three (Phase 2) |
| **T-types** | E1 | `--in P --start-at registration --stop-at dearray --tma false --background false --viz false`; and `--in P --start-at illumination --stop-at registration --illumination false` | CLI type conversion: tasks must be ashlar only, and `params.yml` must contain Booleans (Phase 4) |
| **T-precedence** | E2 + seed `e2-registration/` | `--in P --start-at dearray --stop-at dearray --tma false` | a command-line value still overrides the project's `params.yml` (`tma: true`): coreograph must not run (Phase 4) |
| **T-badbool** | E1 | `--in P --stop-at registration --tma yes` | a `boolean` parameter rejects values other than true/false (Phase 4); the expected result differs from the baseline |
| **T-priority** | E1 | six runs, P0–P5; see *T-priority* below | the full parameter source priority order, including the undocumented `-params-file` layers (Phases 2, 4, 6) |
| **N-unknown** | E1 | `--in P --stop-at registration --not-a-param 1`; and `--in P --stop-at registration --illum` | unknown and deprecated parameters fail with the same messages as before (Phase 4) |
| **T-paramsfile** | E1 | `--in P --stop-at registration -params-file f.yml`, where `f.yml` sets `workflow: {viz: false}` | typed values from YAML are not changed (Phase 4) |

#### T-priority

Checks the parameter source priority order (see *Goal and constraints*) end
to end. Each run adds one source to the previous run. Every source gives the
same keys a different value, so the winner can be read directly from
`qc/params.yml`. Each run uses one key per schema type from Phase 4. Each run
gets a fresh project directory from `~/exemplar-001`, and every run uses
`--in P --start-at registration --stop-at registration`, so only ashlar runs
(`tma: true` has no effect at that stop point).

Files (MCMICRO parameter files use the `workflow:` namespace):

```yaml
# P/params.yml — the project's own file (P1–P5)
workflow:
  tma: true
  segmentation-channel: 2
  qc-files: copy
```

```yaml
# f3.yml — passed with --params (P2–P5)
workflow:
  tma: false
  segmentation-channel: 3
```

```yaml
# f35.yml — passed with -params-file (P3–P4)
workflow:
  tma: true
  segmentation-channel: 4
```

```yaml
# f5.yml — passed with -params-file (P5): f35.yml plus top-level keys
workflow:
  tma: true
  segmentation-channel: 4
tma: true
segmentation-channel: 6
```

| Run | Sources | `tma` | `segmentation-channel` | `qc-files` | Checks |
|---|---|---|---|---|---|
| P0 | defaults | `false` | (absent) | `inherit` | defaults apply |
| P1 | + project `params.yml` | `true` | `2` | `copy` | level 2 > level 1 |
| P2 | + `--params f3.yml` | `false` | `3` | `copy` | level 3 > level 2; a key that level 3 doesn't set (`qc-files`) keeps its lower-level value |
| P3 | + `-params-file f35.yml` | `true` | `4` | `copy` | the `-params-file` `workflow:` section > level 3 |
| P4 | + `--tma false --segmentation-channel 5` | `false` | `5` | `copy` | command line (level 4) > everything |
| P5 | project `params.yml` + `--params f3.yml` + `-params-file f5.yml` + `--tma false` | `false` | `6` | `copy` | top-level `-params-file` keys > its `workflow:` section; the command line > top-level `-params-file` keys |

Checked on 25.04.7 and on 26.10.2 under both parsers: when the same key is
both a top-level `-params-file` key and a command-line argument, Nextflow
itself gives the command line priority, which P5 relies on. Values from
`-params-file` keep their YAML types under both parsers; only command-line
values become Strings under the strict parser (finding 4).

Unlike the other cases, T-priority is checked against the expected values in
the table, **not only** against the baseline:

- **The baseline must match the table.** If it doesn't, the current code
  already disagrees with the documentation. Record that as a pre-existing
  problem in the PR for the phase and stop. Changing the order is out of
  scope (see *Goal and constraints*), so it needs a separate decision.
- **Types.** `segmentation-channel` must be an Integer and `tma` a Boolean in
  every run. Before Phase 4, a strict-parser run records the command-line
  values in P4 and P5 as Strings (see *Comparing*). From Phase 4 on, it must
  record the same types as the legacy parser.

**Not covered locally:**

- Staging (`phenoimager2mc`): no exemplar contains staging data.
- `modules/template.nf` is never executed: lint only.
- Cluster profiles (`O2*`, `AWS`, `tower`): see Phase 5.

## Phases

The phases are ordered so that each one can be merged on its own and keeps the
pipeline working under the legacy parser. Phases 1–2 are mechanical; phases 3–5
need design decisions and careful testing. Each phase follows the cycle in
*Testing strategy*, using the cases listed under its **Testing** heading.

### Phase 0 — Guardrails

- [ ] Add a CI job that runs `nextflow lint .` and fails on errors. Until the
      migration is done, it can be informational only.
- [ ] Pin the Nextflow version in `ci.yml`, and add a matrix over the
      candidate runtimes from *Testing strategy*: 25.04.7 (the minimum
      supported version), 26.10.2 legacy and 26.10.2 strict. Strict runs can
      be marked as allowed to fail until Phase 3.
- [ ] In the meantime, document the `NXF_SYNTAX_PARSER=v1` workaround in the
      README quick start.

**Testing.** This phase does not change the pipeline, so there is no baseline
capture. Check that the new lint job runs and reports the current errors, and
that the pinned legacy-parser CI jobs pass as they did before.

### Phase 1 — Mechanical, behavior-preserving fixes

Each item is a direct lint error (or deprecation warning) with a known fix.

**Imports → fully qualified names** (finding 1)

| File | Line(s) | Change |
|---|---|---|
| `main.nf` | 11, 13, 14 | drop `import mcmicro.*` and the snakeyaml imports; use `mcmicro.Opts`, `mcmicro.Flow`, `mcmicro.Util`, `org.yaml.snakeyaml.Yaml`, `org.yaml.snakeyaml.DumperOptions` |
| `lib/worker.nf` | 1 | `mcmicro.Flow`, `mcmicro.Opts` |
| `modules/background.nf` | 2, 5 | `mcmicro.*`, `groovy.text.GStringTemplateEngine` |
| `modules/staging.nf` | 1, 3 | same as above |
| `modules/illumination.nf` | 1, 2 | `mcmicro.*`, `java.nio.file.Paths` |
| `modules/{dearray,quantification,registration,segmentation,viz}.nf` | 1 | `mcmicro.*` |
| `modules/template.nf` | 49 | `mcmicro.*`; also update the instructions in the header comment |
| `roadie.nf` | 3 | `org.yaml.snakeyaml.Yaml` |

**Include paths must be string literals.** `"$projectDir/..."` is rejected
(`Unexpected input: '"'`). Use paths relative to the including file:

- `main.nf:118–126`: `from "$projectDir/modules/x"` → `from './modules/x'`
- `modules/downstream.nf:1`, `modules/segmentation.nf:48`:
  `from "$projectDir/lib/worker"` → `from '../lib/worker'`
- `modules/segmentation.nf:49`: `from "$projectDir/roadie"` → `from '../roadie'`

**Process body structure**

- Add the `script:` label where other sections are present:
  `modules/dearray.nf:33`, `modules/quantification.nf:26`,
  `modules/viz.nf:28`, `modules/template.nf:101`, `roadie.nf:42`,
  `roadie.nf:55`.
- `roadie.nf:38–40` (`showHelp`): sections must be in order
  `input` → `output` → `when` → `script`.
- `roadie.nf:52` (`runTask`): split the semicolon-separated inputs into one
  per line.

**Expressions**

- `roadie.nf:74`, `roadie.nf:117`: `(error "Unknown task.")` →
  `error("Unknown task.")`.
- `modules/quantification.nf:46`: `x = id.split('-',2)` inside a closure →
  `def x = ...`.
- `modules/illumination.nf:35`: `def relPath = Paths.get(relPath)` shadows the
  `relPath` input (`relPath is already declared`); rename the local, e.g.
  `relP`.
- `main.nf:150`, `main.nf:155`: a line ending in a trailing dot
  (`img = img.` / `chMrk = chMrk.`) is an *Incomplete expression*; move the dot
  to the start of the next line (`.branch{`).

**Deprecation warnings** (not errors, but cheap to fix now)

- `Channel.` → `channel.`: `main.nf:36,42,46,49,52`,
  `modules/downstream.nf:11`, `modules/segmentation.nf:60`,
  `roadie.nf:82,120,145`.
- Implicit `it` closure parameters → explicit parameters: `main.nf` (13
  places), `modules/registration.nf:31,59–61`,
  `modules/segmentation.nf:78,82,86`.
- Unused closure parameters → prefix with `_`
  (`main.nf`, `modules/quantification.nf:50`, `modules/template.nf`).
- Optional: the `file(...)` input qualifier → `path(...)`
  (`lib/worker.nf:46` `file(model)`, `modules/segmentation.nf:23`
  `file('mask.tif')`). Check how `worker` handles the `'built-in'` placeholder
  string before changing `file(model)`.

**Testing.** First, at the very start of this phase, produce the E2
registration seed and the `nondeterministic.txt` list (see *Testing strategy*).
Strict candidate: lint only.

| Case | Why |
|---|---|
| E1-default | imports and `Channel` in `main.nf`; the trailing-dot `branch` fixes (`main.nf:150,155`); `registration.nf`, `segmentation.nf`, `lib/worker.nf`; `def x` in `quantification.nf` |
| E1-illum | `java.nio.file.Paths` and the `relPath` rename in `illumination.nf` |
| E1-recyze, R-cli | `include` path of `roadie`, `runTask` inputs split, `error(...)`, `showHelp` section order |
| E1-downstream | `include` path of `worker` in `downstream.nf`, `Channel` |
| E1-viz | `script:` label in `viz.nf` |
| E2-dearray | `script:` label in `dearray.nf` |
| E1-seg-multi | only if `file(model)` is changed to `path(model)` (the `'built-in'` placeholder) |
| AF-backsub, AF-rollingball | fully qualified `GStringTemplateEngine` in `background.nf` |

`staging.nf` (same `GStringTemplateEngine` change) cannot be run locally.
Check it with lint and code review.

### Phase 2 — Restructure `main.nf` top level

Under the strict parser, a script may contain only declarations (`include`,
`params`, `def` functions, `process`, `workflow`) at the top level. `main.nf`
has roughly 100 lines of statements before `workflow {` (lines 3–115) and the
`workflow.onComplete` handler after it (lines 202–221).

- [ ] **Version check (lines 3–7):** replace the top-level `if/exit` with
      `manifest { nextflowVersion = '!>=25.04.7' }` in `nextflow.config` (the
      `!` prefix makes it a hard error instead of a warning). This raises the
      minimum from 22.04.3. The manifest applies to every script in the repo,
      so `exemplar.nf` and `roadie.nf` will also refuse older releases.
      `exemplar.nf` currently still runs on 22.10.8, so this is a
      user-visible change. Note it in `CHANGES.md` and update the minimum
      version in the installation docs.
- [ ] **`--in` check (lines 17–18):** declare `params.in = null` at the top
      level and move the check into the workflow. Note that `Opts.cleanParams`
      already treats `in` as a protected keyword, so declaring it does not
      change `mcp`.
- [ ] **Helper closures (lines 45–53):** `findFiles0`, `findFiles`, and
      `findDirs` are closures assigned to variables. Calling them like
      functions is rejected (`findFiles is not defined`). Convert them to
      top-level `def` functions and pass `pre` in explicitly, e.g.
      `def findFiles(pre, key, pattern, ife) { ... }`.
- [ ] **Remaining statements (lines 21–115):** move parameter parsing (`mcp`,
      `wfp`, `pre`), the deprecated `illumination_profiles/` check, and all
      channel construction into the entry `workflow`, declaring each variable
      with `def`. The multiple assignment `(formatType, formatPattern) = ...`
      (line 61) becomes `def (formatType, formatPattern) = ...`; it lints
      cleanly inside the workflow.
- [ ] **Includes (lines 118–126):** move them to the top of the file, before
      any function or workflow.
- [ ] **`workflow.onComplete` (lines 202–221):** move it *inside* the entry
      workflow body as `workflow.onComplete { ... }` (finding 3), so it can
      still reference `mcp`.

In the scratch copy, Phases 1–2 plus the `when:` removal from Phase 3 were
enough for `nextflow lint .` to report no errors in any file the main pipeline
uses. The scratch copy has only been linted, not run. Phases 3–4 are needed
for correct behavior.

**Testing.** Strict candidate: lint only. The only lint errors left should be
the `when:` errors that Phase 3 removes.

| Case | Why |
|---|---|
| E1-default | moving parsing and channel construction into the workflow; `params.in`; `workflow.onComplete` writing `qc/params.yml` and `qc/metadata.yml` (captured in every case) |
| E1-steps | the `findFiles*` functions and precomputed `pre_*` channels |
| E1-illum | `pre_dfp` / `pre_ffp` and the `illumination` call from `main.nf` |
| E2-dearray | `pre_img` and the TMA branch of `img` |
| AF-backsub | the background branches of `img` and `chMrk` |
| AF-bs-pre | `pre_bsub` / `pre_bsubm` |
| T-priority | `Opts.parseParams` is now called from inside the workflow; the priority order must not change |
| N-noin, N-deprecated | the moved `--in` and `illumination_profiles/` checks must still fail with the same message |
| N-version | `manifest.nextflowVersion` replaces the version check. The minimum changes, so there is no baseline to compare against: check that a release below 25.04.7 is refused for all three scripts, and that 25.04.7 itself is accepted (covered by every other case). |

### Phase 3 — Replace `when:` with workflow-level gating

Required (finding 2). Every gated process has at least one channel input, so
the equivalent behavior is to pass an empty channel when the step should not
run. A process with empty inputs never runs and emits empty channels, which is
what a false `when:` does today. Because `mcp` is an ordinary map (not a
channel) inside the workflows, the decision can be made with plain Groovy:

```groovy
// e.g. modules/dearray.nf
def doRun = mcmicro.Flow.doirun('dearray', mcp.workflow)
coreograph(mcp, mcp.modules['dearray'], doRun ? tma : channel.empty())
```

A small helper in `lib/mcmicro/Flow.groovy` (e.g.
`Flow.gate(step, wfp, ch)`) would keep the call sites short.

| Process | File:line | Current condition |
|---|---|---|
| `worker` | `lib/worker.nf:64` | `Flow.doirun(step, mcp.workflow)`; `step` is an input value, so gate at the callers in `modules/segmentation.nf` (`'segmentation'`) and `modules/downstream.nf` (`'downstream'`) |
| `backsub` | `modules/background.nf:49` | `mcp.workflow["background"]` |
| `coreograph` | `modules/dearray.nf:31` | `Flow.doirun('dearray', ...)` |
| `illumination` | `modules/illumination.nf:32` | `Flow.doirun('illumination', wfp)`; this process is called directly from `main.nf:143`, so gate there |
| `mcquant` | `modules/quantification.nf:24` | `Flow.doirun('quantification', ...)` |
| `ashlar` | `modules/registration.nf:22` | `Flow.doirun('registration', ...)` |
| `s3seg` | `modules/segmentation.nf:35` | `Flow.doirun('watershed', ...)` |
| `phenoimager2mc` | `modules/staging.nf:25` | `Flow.doirun('staging', ...)` |
| `autominerva` | `modules/viz.nf:26` | `Flow.doirun('viz', wfp)` |
| `snr` (template) | `modules/template.nf:96` | `mcp.workflow["report"]`; update the template's guidance too |
| `showHelp` | `roadie.nf:38` | `params.containsKey('help')`; uses only `params`, so it compiles today, but should be gated in the CLI workflow for consistency |

Things to watch:

- The `recyze` step in `modules/segmentation.nf` goes through `roadie`, which
  has no `when:`. Its existing gating via `branch` is unaffected.
- `--start-at` / `--stop-at` combinations depend entirely on this gating. The
  partial-run steps in `ci.yml` (lines 132–142) are the main regression test.

**Testing.** This is the first phase in which the strict candidate runs the
pipeline. Leave explicit `false` values off the command line (finding 4), and
expect the String/Boolean differences in `params.yml` described in
*Comparing*. The key capture here is `tasks.txt`: each step must run or be
skipped exactly as in the baseline.

| Case | Gating checked |
|---|---|
| E1-default | registration, segmentation (`worker`), watershed, quantification on; illumination, background, dearray, viz, staging off |
| AF-backsub | background on |
| E1-steps | each `--start-at` / `--stop-at` window |
| E1-illum | illumination on, everything after registration off |
| E1-seg-multi | `worker` and s3seg with mixed watershed settings |
| E1-downstream | `worker` with step `'downstream'` |
| E1-viz | viz on |
| E2-dearray | dearray on |
| R-cli | `showHelp` gating in the roadie CLI |

### Phase 4 — Type-coerce command-line parameters

Required for correctness under the strict parser (finding 4). The linter cannot
catch this.

**Approach: explicit types in `config/schema.yml`.** Every workflow parameter
gets a declared type, and `Opts.cleanParams` converts String values according
to that type. Conversion only happens where a type asks for it, so text such
as `sample-name: "001"` is never turned into a number. Under the legacy parser
the values are already typed, so the conversion does nothing.

- [ ] **Change the schema format.** `workflow:` becomes a map of name → type
      instead of a list of names. `deprecated:` is unchanged.

      ```yaml
      workflow:
        sample-name: string
        start-at: string
        stop-at: string
        qc-files: string
        tma: boolean
        viz: boolean
        illumination: boolean
        background: boolean
        segmentation-recyze: boolean
        segmentation-max-projection: boolean
        segmentation-channel: auto            # '1 5' or 1
        segmentation-nuclear-channel: auto
        segmentation-membrane-channel: auto
        segmentation: string                  # comma-separated; split later in parseParams
        downstream: string
        multi-formats: string
        single-formats: string
        background-method: string
        staging-method: string
        ilastik-model: string                 # paths, and likewise for every *-model
        # ...
      ```

- [ ] **Type meanings:**
  - `string`: left unchanged.
  - `boolean`: `"true"` / `"false"` → Boolean. Any other String is an error
    (`Parameter tma expects true or false`). This is a deliberate change for
    invalid input only: today `--tma yes` silently becomes a truthy String
    under both parsers. Note it in `CHANGES.md`.
  - `auto`: the same conversion the legacy parser applies to command-line
    values (`"true"`/`"false"` → Boolean, whole numbers → Integer, decimals →
    Double, anything else stays a String). Check the exact rules against the
    legacy parser in 26.10.2 rather than reimplementing them from memory;
    finding 4 is the starting point.
- [ ] **Module options** (`--<module>-opts`) are not in the schema. Treat them
      as `auto`, so that e.g. `--imagej-rolling-ball-opts 100` is recorded in
      `qc/params.yml` the same way as under the legacy parser (Integer). The
      command line passed to the tool is the same either way.
- [ ] **Where to convert:** in `Opts.cleanParams`, which handles only Nextflow's
      `params` (command-line arguments, top-level `-params-file` keys, and
      config `params`). Pass the loaded schema in from `Opts.parseParams`.
      Values from the project's `params.yml` and the `--params` file are loaded
      directly with SnakeYAML and do **not** go through `cleanParams`. They
      are left untouched, which keeps the documented priority order (see
      *Goal and constraints*) and the values in those files exactly as they
      are.
- [ ] **Only convert Strings.** A value that is already typed (from the legacy
      parser or from YAML) is left as is.
- [ ] **Unknown and deprecated keys** are left unconverted, so that
      `validateWFParams` reports them with the same errors as today.
- [ ] **Update `Opts.validateWFParams`** (`Opts.groovy:129`):
      `schema.workflow.contains(key)` → `schema.workflow.containsKey(key)`. It
      is the only reader of `config/schema.yml`.
- [ ] **Document the type** of each parameter in the schema comments and in
      `docs/parameters/workflow.md`, and add the rule "every new workflow
      parameter needs a type in `config/schema.yml`" to the module template
      (`modules/template.nf`, Step 1).

`exemplar.nf` already converts its own numeric parameters
(`params.nc as Integer`, etc.).

**Testing.** From this phase on, `params.yml` must match the baseline exactly
under the strict parser too, with no String/Boolean exception.

| Case | Why |
|---|---|
| T-types | `boolean` type: explicit `false` values, no extra tasks, and Booleans in `params.yml` |
| T-badbool | `boolean` type: `--in P --stop-at registration --tma yes` must fail with `Parameter tma expects true or false` and run no tasks. The baseline accepts `yes`, so this is the one expected difference (see the `boolean` type above). |
| T-priority | the full priority order with conversion in `cleanParams`; under the strict parser, P4 and P5 must now record the same types as the legacy parser |
| T-precedence | the command line still overrides the project's `params.yml`, checked through the effect on tasks (coreograph must not run) |
| T-paramsfile | values from `-params-file` are left alone |
| E1-recyze | `auto` type: `--segmentation-channel 1` stays an Integer in `params.yml`; bare `--segmentation-recyze` becomes Boolean `true` |
| E1-seg-multi | `string` type: comma-separated `--segmentation unmicst,cellpose` still splits into a list |
| AF-backsub | the bare `--background` flag (String `"true"` under the strict parser) |
| AF-rollingball | module options as `auto`: rerun with `--imagej-rolling-ball-opts 100` added, and `params.yml` must record an Integer |
| N-unknown | `--in P --stop-at registration --not-a-param 1` and `--illum` (deprecated) must fail with the same messages as the baseline |
| E2-dearray | `tma: true` from the project's own `params.yml` still enables dearray |

### Phase 5 — Other files the linter flags (not part of `main.nf`)

These do not block `main.nf`, but `nextflow lint .` will not be clean
without them:

- `setup/O2ext.nf:4`: add the `script:` label. Keep the single-quoted
  shell string so `$HOME` is still expanded by the shell, not Nextflow.
- `config/nf/sage.config:85` and onward: function definitions (`def factor`,
  `def check_max`) are not allowed in strict config files. Inline the logic
  into the closures that use it, or move it into a `lib/` class.
- `config/nf/lsp.config:37,56`: implicit `it` (warning only).
- `roadie.nf:92`: `params.out = '.'` inside the workflow → move to the top
  level (warning).

**Testing.** These are cluster configs, so instead of a pipeline run, the
capture is the resolved configuration. No exemplar data is needed.

| Check | Command |
|---|---|
| `lsp.config` | `nextflow config -profile O2LSP` and `nextflow config -profile O2LSP,GPU`, diffed against the baseline |
| `O2ext` profile | `nextflow config -profile O2ext`, which also re-checks the earlier `$HOME` fix |
| `sage.config` | `nextflow config -c config/nf/sage.config`. It sets no executor, so also run E1-viz with `-c config/nf/sage.config` to evaluate the resource closures (`factor`, `check_max`) on real tasks. If that run already fails in the baseline (e.g. because its extra `params` are rejected by `Opts.validateWFParams`), record it as a pre-existing problem and compare the config output only. |
| `setup/O2ext.nf` | lint only; it writes into `$HOME` and needs `/n/groups` |

### Phase 6 — Verification and release

- [ ] `nextflow lint .` is clean.
- [ ] End-to-end check: the baseline is the code at commit `07ccae6` (before
      Phase 1) under the legacy parser, and the candidates are the fully
      migrated code on all three candidate runtimes. Run every case in the
      catalog.
- [ ] The full exemplar-002 run in `ci.yml`
      (`--tma --start-at registration --stop-at segmentation --segmentation mesmer`)
      on `~/exemplar-002`. This is the only time registration of exemplar-002
      is rerun instead of seeded.
- [ ] Repeat the remaining partial runs from `ci.yml` (each `--downstream`
      method) on `~/exemplar-001`.
- [ ] Compare `qc/params.yml` between the pre-migration baseline and the
      strict-parser candidate. It must be identical (finding 4).
- [ ] T-priority on all three candidate runtimes matches the expected table
      exactly, values and types.
- [ ] Update `CHANGES.md`, remove the `NXF_SYNTAX_PARSER=v1` workaround from
      the docs, and close #59.

## Decisions

1. **Minimum supported Nextflow version: 25.04.7**, the oldest release this
   roadmap tests. Enforced with `manifest.nextflowVersion` in Phase 2.
2. **The legacy parser is supported until Nextflow officially removes it.**
   Until then, strict-only syntax is not used (see *Goal and constraints*).
   When it is removed, open a follow-up to adopt strict-only features where
   they help, e.g. `onComplete:` sections and workflow outputs. A typed
   `params {}` block is **not** a drop-in solution for finding 4 even then
   (finding 5).
3. **Parameter source priority stays as documented** in
   `docs/parameters/index.md`, and declared defaults never override
   `params.yml`. That rules out declaring the workflow parameters as `params`
   with defaults.
4. **Background subtraction is tested locally** with `~/exemplar-001-af`
   (cycles 1–3 of exemplar-001), in cases AF-backsub, AF-rollingball and
   AF-bs-pre.
5. **Command-line types are converted using explicit types in
   `config/schema.yml`** (`string`, `boolean`, `auto`), applied only to
   Strings in `Opts.cleanParams` (Phase 4). Two alternatives were rejected:
   - Converting based on `config/defaults.yml`: parameters without a default
     would stay Strings, so `qc/params.yml` would differ from the legacy
     parser.
   - Legacy-style conversion for every key: it would also convert quoted
     strings from `-params-file` and config.
