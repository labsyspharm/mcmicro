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
### 2022-01-04

* Adding channel and pixel cropping tool `recyze` to `roadie`
* Can be run on docker as follows
```
docker run --rm -v "$PWD":/recyze labsyspharm/roadie:2022-03-14 bin/bash -c "cd /recyze; python recyze.py --in-path exemplar-001.ome.tif --out-path crop.ome.tif --x 0 --y 0 --w 1024 --h 1024 --channels 1 2 4" 
```


