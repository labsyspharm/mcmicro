# Parameter reference

## Parameters controlling the pipeline behavior

The following parameters control the pipeline as a whole. These can be specified on the command line using the double-dash format (e.g., `--in`), or inside a YAML file as key-value pairs. Parameters that don't require an explicit value because their presence controls the behavior (e.g., `--tma`) should instead be assigned to `true` in the YAML file. For example,

Example: `nextflow run labsyspharm/mcmicro --in /my/data --tma`

or equivalently: `nextflow run labsyspharm/mcmicro -params-file myparams.yml`, where `myparams.yml` contains
```
in: /my/data
tma: true
```

### Mandatory parameters:

| Parameter | Description |
| --- | --- |
| `--in /local/path` | Location of the data |

### Optional parameters:

| Parameter | Default | Description |
| --- | --- | --- |
| `--sample-name <myname>` | Directory name supplied to `--in` | The name of the experiment/specimen |
| `--start-at <step>` | `registration` | Name of the first step to be executed by the pipeline. Must be one of `illumination`, `registration`, `dearray` (TMA only), `probability-maps`, `segmentation`, `quantification`, `cell-states` |
| `--stop-at <step>` | `quantification` | Name of the final step to be executed by the pipeline. Spans the same vocabulary as `--start-at`. |
| `--tma` | Omitted | If specified, mcmicro treats input data as a TMA. If omitted, the input is assumed to be a whole-slide image. |
| `--ilastik-model <model.ilp>` | None | A custom `.ilp` file to be used as the classifier model for ilastik. |
| `--probability-maps <choice>` | `unmicst` | Which module(s) to use for probability map computation. Must be one of `unmicst`, `ilastik`, `all` (`unmicst` AND `ilastik`), and `cypository` for cytoplasm segmentation |

## Parameters for individual modules

Module-specific parameters can be specified using the various `opts` arguments, followed by the parameters enclosed inside single quotes `'`:

Example 1: `nextflow run labsyspharm/mcmicro --in /my/data --ashlar-opts '-m 30 --pyramid'`

Example 2: `nextflow run labsyspharm/mcmicro --in /my/data --nstates-opts '--log no --plots pdf'`

Example 3: `nextflow run labsyspharm/mcmicro --in /my/data --quant-opts '--masks cytoMask.tif nucleiMask.tif'`

### Arguments to ASHLAR (`--ashlar-opts`):

Up-to-date list can be viewed at [https://github.com/labsyspharm/ashlar](https://github.com/labsyspharm/ashlar)

### Arguments to Coreograph(`--core-opts`):

Up-to-date list can be viewed at [https://github.com/HMS-IDAC/UNetCoreograph](https://github.com/HMS-IDAC/UNetCoreograph)

### Arguments to UnMicst(`--unmicst-opts`):

| Parameter | Default | Description |
| --- | --- | --- |
| `--tool <version>` | `unmicst-solo` | UnMicst version: *unmicst-legacy* is the old single channel model. *unmicst-solo* uses DAPI. *unmicst-duo* uses DAPI and lamin. |
| `--model` | human nuclei from DAPI | The name of the UNet model. By default, this is the human nuclei model that identifies nuclei centers, nuclei contours, and background from a DAPI channel. Other models include mouse nuclei from DAPI, and cytoplasm from stains resembling WGA |
| `--channel <number>` | `1` | The channel used to infer and generate probability maps from. If using UnMicst2, then specify 2 channels. If only 1 channel is specified, it will simply be duplicated. **NOTE: If not using default value, the 1st channel must be specified to S3segmenter as --probMapChan in --s3seg-opts**|
| `--classOrder` | None | If your training data isn't in the order 1. background, 2. contours, 3. foreground, you can specify the order here. For example, if you had trained the class order backwards, specify `--classOrder 3 2 1`. If you only have background and contours, use `--classOrder 1 2 1`. |
| `--mean <value>` | Extracted from the model | Override the trained model's mean intensity. Useful if your images are significantly dimmer or brighter. |
| `--std <value>` | Extracted from the model | Override the trained model's standard deviation intensity. Useful if your images are significantly dimmer or brighter. |
| `--scalingFactor <value>` | `1` | An upsample or downsample factor used to resize the image. Useful when the pixel sizes of your image differ from the model (ie. 0.65 microns/pixel for human nuclei model) |
| `--stackOutput` | Specified | If selected, UnMicst will write all probability maps as a single multipage tiff file. Otherwise, UnMicst will write each class as a separate file. |
| `--GPU <index>` | Automatic | Explicitly specify which GPU (1-based indexing) you want to use. Useful for running on local workstations with multiple GPUs. |

### Arguments to Ilastik(`--ilastik-opts`):

| Parameter | Default | Description |
| --- | --- | --- |
| `--nonzero_fraction <value>` |`None` | Indicates fraction of pixels per crop above global threshold to ensure tissue and not only background is selected |
| `--nuclei_index <index>` |`1` | Index of nuclei channel to use for nonzero_fraction argument |
| `--crop` | Omitted | If specified, crop regions for ilastik training |
| `--num_channels <value>` | `None`| Number of channels to export per image (Ex: 40 corresponds to a 40 channel ome.tif image) |
| `--channelIDs <indices>` |`None` | Integer indices specifying which channels to export (Ex: 1 2 4). **NOTE: You must specify a channel to use for filtering in S3segmenter as --probMapChan in --s3seg-opts**|
| `--ring_mask`| Omitted | Specify if you have a ring mask in the same directory to use for reducing size of hdf5 image |
| `--crop_amount <integer>`| `None`| Number of crops you would like to extract |

Up-to-date list can be viewed at [https://github.com/labsyspharm/mcmicro-ilastik](https://github.com/labsyspharm/mcmicro-ilastik)

### Arguments to S3Segmenter(`--s3seg-opts`):

| Parameter | Default | Description |
| --- | --- | --- |
| `--probMapChan <index>` | `1` | which channel is used for nuclei segmentation. **Coincides with the channel used in upstream semantic segmentation modules. Must specify when different from default.**  |
| `--crop <selection>` | `noCrop` | Type of cropping: `interactiveCrop` - a window will appear for user input to crop a smaller region of the image; `plate` - this is for small fields of view such as from a multiwell plate; `noCrop`, the default, is to use the entire image |

**Nuclei parameters:**

| Parameter | Default | Description |
| --- | --- | --- |
| `--nucleiFilter <selection>` | `IntPM` | Method to filter false positive nuclei: `IntPM` - filter based on probability intensity; `Int` - filted based on raw image intensity |
| `--logSigma <value> <value>` | `3 60` | A range of nuclei diameters to search for. |

**Cytoplasm parameters:**

| Parameter | Default | Description |
| --- | --- | --- |
| `--segmentCytoplasm <selection>` | `ignoreCytoplasm` | Select whether to `segmentCytoplasm` or `ignoreCytoplasm` |
| `--CytoMaskChan <index>` | `2` | One or more channels to use for segmenting cytoplasm, specified as 1-based indices (e.g., `2` is the 2nd channel). |
| `--cytoMethod <selection>` | `distanceTransform` | The method to segment cytoplasm: `distanceTransform` - take the distance transform outwards from each nucleus and mask with the tissue mask; `ring` - take an annulus of a certain pixel size around the nucleus (see `cytoDilation`); `hybrid` - uses a combination of greyscale intensity and distance transform to more accurately approximate the extent of the cytoplasm. Similar to Cellprofiler's implementation. |
| `--cytoDilation <value>` | `5` | The number of pixels to expand from the nucleus to get the cytoplasm ring. |
| `--TissueMaskChan <index>` | Union of `probMapChan` and `CytoMaskChan` | One or more channels to use for identifying the general tissue area for masking purposes. |

### Arguments to quantification(`--quant-opts`):

Up-to-date list can be viewed at [https://github.com/labsyspharm/quantification](https://github.com/labsyspharm/quantification)

### Arguments to naivestates(`--nstates-opts`):

Up-to-date list can be viewed at [https://github.com/labsyspharm/naivestates](https://github.com/labsyspharm/naivestates)
