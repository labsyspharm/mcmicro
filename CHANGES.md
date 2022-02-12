### 2022-02-11

* Added a CHANGES file
* Reworked GPU config profile to expose all GPUs across all platforms
  * When running MCMICRO on O2, use `-profile O2,GPU` (command, no space) instead of `-profile O2gpu`
* `quantification` is now the default stopping point
