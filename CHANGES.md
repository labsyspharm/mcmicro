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
