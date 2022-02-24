### 2022-02-24

* Added more flexibility to `exemplar.nf`, which allows for downloading any contiguous set of cycles. For more information, see

```
nextflow labsyspharm/mcmicro/exemplar.nf --help
```

### 2022-02-22

* [s3seg] Fixed an bug that caused the module to crash when generating pyramids for images of smaller size.

### 2022-02-21

* [UnMicst] Updated the Tensorflow base to `2.7.1-gpu`
* [UnMicst] The code for automatic GPU selection is now more robust. It no longer relies on parsing `nvidia-smi` output with a regular expression and uses `pynvml` instead.

### 2022-02-11

* Added a CHANGES file
* Reworked GPU config profile to expose all GPUs across all platforms
  * When running MCMICRO on O2, use `-profile O2,GPU` (command, no space) instead of `-profile O2gpu`
* `quantification` is now the default stopping point
