### 2024-03-10

* Allow for dynamic sample name specification in the fileseries/filepattern expressions.

For example, if the filenames are structured like this:
```
myproject/
  markers.csv
  params.yml
  raw/
    image1/
      image1_ch1.tif
      image1_ch2.tif
    image2/
      image2_ch1.tif
      image2_ch2.tif
```

The corresponding expression can now be specified as `fileseries|.|pattern={samplename}_ch{channel}.tif`.

### 2024-02-25

* Added support for multiple samples in `raw/` subdirectory. If multiple images share the same markers and should be processed with the same set of parameters, they can be placed as subdirectories of `raw/`. In other words, instead of structuring the data as multiple projects:

```
image1/
  markers.csv
  params.yml
  raw/
    cycle1.rcpnl
    cycle2.rcpnl

image2/
  markers.csv
  params.yml
  raw/
    cycle1.rcpnl
    cycle2.rcpnl
```

they can be consolidated under the same project folder:

```
myproject/
  markers.csv
  params.yml
  raw/
    image1/
      cycle1.rcpnl
      cycle2.rcpnl
    image2/
      cycle1.rcpnl
      cycle2.rcpnl
```

### 2024-01-31

* Added support for ASHLAR's [fileseries/filepattern](https://forum.image.sc/t/ashlar-how-to-pass-multiple-images-to-be-stitched/49864) feature. The patterns can be provided directly via ASHLAR's options:

``` yaml
options:
  ashlar: fileseries|...
```

### 2023-12-21

* Added a config parameter controlling how intermediates are published to project directory. The behavior can be controlling by adding the following to `custom.config`:

```
params.publish_dir_mode = 'copy'
```

and providing it to the pipeline with

```
nextflow run labsyspharm/mcmicro --in exemplar-001 -c custom.config
```

The valid values for `publish_dir_mode` can be found in [Nextflow documentation](https://nextflow.io/docs/latest/process.html#publishdir) of `publishDir`, argument `mode`.

### 2023-08-29

* Added ImageJ rolling ball background subtraction module

The new module can be selected by adding the following to `params.yml`:
``` yaml
workflow:
  background: true
  background-method: imagej-rolling-ball
```

### 2023-06-16

* If `--membrane-channel` is provided to Mesmer options, MCMICRO will automatically pass the input image both as `--nuclear-image` and as `--membrane-image` to the Mesmer CLI.

### 2023-03-10

* [viz] Auto-Minerva story construction will now read channel names from `markers.csv`

### 2022-11-23

* [dearray] The output of Coreograph is now being run through palom to generate pyramids, which are needed for Autominerva. The following combination of parameters should now work:

```yaml
workflow:
  tma: true
  viz: true
```

### 2022-11-01

* Expanded the parsing of the parameter file specified via `-params-file`. This allows for the entire workflow/options/modules parameter structure to be pasted directly inside the "Pipeline parameters" field of a Nextflow Tower launchpad.

### 2022-10-28

* Added a background subtraction module. The module can be turned on by setting the `background` workflow option to `true`:

``` yaml
workflow:
  background: true
```

### 2022-10-26

* Added cellpose. The module can now be selected as one of the `segmentation` workflow settings:

``` yaml
workflow:
  segmentation: cellpose
```

### 2022-10-19

* Added a roadie script for generating image pyramids. Example usage:

`nextflow run labsyspharm/mcmicro/roadie.nf --in simple.tif --out pyramid.ome.tif`

### 2022-10-01

* Changed the order of tokens in quantification output to make it easier to match filenames against other intermediate.

**Old pattern:** `unmicst-exemplar-001_cell.csv`

**New pattern:** `exemplar-001--unmicst_cell.csv`

The new pattern can now be easily matched against the original `exemplar-001.ome.tif` by cutting the feature table filename at `--`.

* Added `modules/template.nf` documenting how to add new modules to MCMICRO.

### 2022-09-08

* Added a `segmentation-recyze` parameter to the `workflow:` section. If set to `true`, MCMICRO will reduce the input image to the channels specified in `segmentation-channel` prior to passing it to the segmentation modules. This can be useful for reducing the memory footprint for modules like Mesmer, which read the entire input image into memory.

### 2022-08-19

* [registration] Updated Ashlar to v1.17.0.
  * Improve registration accuracy in certain tile layout conditions.
  * Fix support for --plates option for performing registration on multi-well plate acquisitions. (This option may not work directly with downstream modules yet)

### 2022-07-12

* Introduced a YAML pattern for parameters with three top-level namespaces:
  * `workspace` - pipeline-level parameters controlling overall behavior of MCMICRO
  * `options` - module-level parameters that will be forwarded to individual tools; the entries are matched against `name` fields in `modules`
  * `modules` - module specifications, such as container name and version, whether the module uses 0-based or 1-based indexing, and whether the module requires watershed.

An example `params.yml` may look

``` yaml
workflow:
  start-at: registration
  stop-at: quantification
  viz: true
  segmentation-channel: 5
options:
  ashlar: -m 15
  s3seg: --logSigma 45 300
modules:
  watershed:
    version: 1.4.0-large
```

which a user would supply to the pipeline with

```
nextflow run labsyspharm/mcmicro --in exemplar-001 --params params.yml
```

* The new YAML pattern is backwards-compatible
  * Users can still overwrite individual `workflow` parameters on the command-line (e.g., `--start-at segmentation`)
  * Users can also overwrite module-specific options with `--[module name]-opts`, as before
* Default values for all namespaces can be found in `config/defaults.yml`
* Pipeline will now verify all parameters and throw an error when encountering an unrecognized parameters
* Introduced the following name changes to reduce confusion:
  * `probability-maps` is now `segmentation` (e.g., `--start-at segmentation --segmentation mesmer,unmicst`)
  * `segmentation` is now `watershed` (e.g., `--stop-at watershed`)
  * `cell-states` is now `downstream` (e.g., `--start-at downstream --downstream scimap`)

### 2022-06-06

* Cleaned up provenance filenames, making their more robust across operating systems
* Added Auto-Minerva for automatic visualuzation generation. Run with the new `--viz` flag:

```
nextflow run labsyspharm/mcmicro --in exemplar-001/ --stop-at registration --viz
```

Visualization is written to `exemplar-001/viz`. A separate subdirectory will be created for each OME-TIFF in the `registration/` folder.

### 2022-06-02

* Consolidated Roadie scripts
* Dynamic range calculation is now folded inside Auto-minerva story generation and can be executed both inside MCMICRO with

```
nextflow run labsyspharm/mcmicro --in exemplar-001/ --stop-at registration --story
```

and as a standalone Roadie script with

```
nextflow run labsyspharm/mcmicro/roadie.nf --do story --in exemplar-001.ome.tif
```

### 2022-05-24
* Adding single channel image support and improving logging in recyze

### 2022-05-23

* Module specs have been migrated to a stand-alone file in standard YAML format.
  * Default specs can be overwritten with the new `--module myspecs.yml` parameter. In this example, `myspecs.yml` only needs to specify the fields being overwritten; all other values will stay at default.
  * MCMICRO will output the module specs used during a run to a new `qc/modules.yml` file to maintain provenance. The file can be fed back to the pipeline with `--module`, closing the reproducibility loop.
* Introduced a new `--segmentation-channel` parameter, which provides synchronized `--channel` control over all segmentation modules
  * MCMICRO will forward the value to every segmentation module, properly accounting for 0-based and 1-based indexing.
  * When supplying multiple channels, enclose them with single quotes (e.g., `--segmentation-channel '1 5'`). Only the first value will be passed to s3seg.
* Cleaned up what gets written to `qc/params.yml`, ensuring that the file can be reused with MCMICRO via `-params-file`.

### 2022-05-20

* Added channel and pixel cropping tool `recyze` to `roadie`.
View instructions with:
```
nextflow run labsyspharm/mcmicro/roadie.nf --help
```
Example:
```
nextflow run labsyspharm/mcmicro/roadie.nf --do recyze --in-path exemplar-001.ome.tif --x 0 --y 0 --w 1024 --h 1024 --channels 1 2 4
```

To process multiple files in parallel, file masks have to be enclosed by single quotes:
```
nextflow run labsyspharm/mcmicro/roadie.nf --do recyze --in-path '*.ome.tif' --x 0 --y 0 --w 1024 --h 1024 --channels 1 2 4
```

### 2022-05-07

* Docker containers are now always executed as root, which solves the permission problem for BaSiC illumination
* Added a new CI test for illumination
* Cleaned up CI test definitions

### 2022-04-29

* [registration] Updated Ashlar to v1.15.3.
  * Slightly non-square pixels (relative difference between width and height of <= 0.0001) are now tolerated.

### 2022-04-27

* [registration] Updated Ashlar to v1.15.2.
  * OME-TIFF output now conforms to the official [OME-TIFF pyramid spec](https://docs.openmicroscopy.org/ome-model/6.0.0/ome-tiff/specification.html#sub-resolutions).
  * Memory usage is dramatically reduced -- registration now only requires enough memory to hold all tiles in the first cycle's reference channel plus a fixed overhead of about 400 MB.

### 2022-04-22

* By default, MCMICRO was copying `qc/*` files from work directories to the project directory. This was creating unnecessary duplication of potentially large files. The new `--qc-files` option allows users to `copy`, `move` or `symlink` all QC files, providing more flexibility. Example:

```
nextflow run labsyspharm/mcmicro --in exemplar-001 --qc-files move
```

### 2022-04-21

* Added a script for automatically detecting dynamic range of the signal in each channel. The script is not executed by default but can be triggered with `--dynrange`. For example,

```
nextflow run labsyspharm/mcmicro --in exemplar-001 --dynrange
```

The output will be written to `qc/dynrange`.

### 2022-03-31

* Added exemplar-003 for spot detection

### 2022-03-28

* Complete rework of the mcmicro.org

### 2022-03-04

* The pipeline now correctly carries through image names with `.` in them, e.g., `slide0.ROI7.ome.tif`.

### 2022-03-01

* [illumination] CZI files are now loaded correctly.

### 2022-02-24

* Added more flexibility to `exemplar.nf`, which allows for downloading any contiguous set of cycles. For more information, see

```
nextflow run labsyspharm/mcmicro/exemplar.nf --help
```

### 2022-02-22

* [s3seg] Fixed an bug that caused the module to crash when generating pyramids for images of smaller size.

### 2022-02-21

* [UnMicst] Updated the Tensorflow base to `2.7.1-gpu`
* [UnMicst] The code for automatic GPU selection is now more robust. It no longer relies on parsing `nvidia-smi` output with a regular expression and uses `pynvml` instead.

### 2022-02-11

* Added a CHANGES file
* Reworked GPU config profile to expose all GPUs across all platforms
  * When running MCMICRO on O2, use `-profile O2,GPU` (comma, no space) instead of `-profile O2gpu`
* `quantification` is now the default stopping point

### 2022-01-04

* Coreograph now supports splitting of large tissue chunks and will split them into individual files for faster downstream segmentation. If your image sizes were too large for s3segmenter because they contained multiple tissue sections, this should help. To turn Coreograph on, include `--tma` as if you had a TMA. By default, Coreograph is set to deal with TMAs, so you will need to tweak `--core-opts` to have it handle multiple tissue sections instead:

```
nextflow run labsyspharm/mcmicro --in /my/project --tma --core-opts '--tissue --downsampleFactor 6'
```
