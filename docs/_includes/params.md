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

| Parameter | Default | Description |
| --- | --- | --- |
| `--in /local/path` | | Location of the data |

### Optional parameters:

| Parameter | Default | Description |
| --- | --- | --- |
| `--sample-name <myname>` | Directory name supplied to `--in` | The name of the experiment/specimen |
| `--start-at <step>` | `registration` | Name of the first step to be executed by the pipeline. Must be one of `illumination`, `registration`, `dearray` (TMA only), `probability-maps`, `segmentation`, `quantification`, `cell-states` |
| `--stop-at <step>` | `quantification` | Name of the final step to be executed by the pipeline. Spans the same vocabulary as `--start-at`. |
| `--tma` | Omitted | If specified, mcmicro treats input data as a TMA. If omitted, the input is assumed to be a whole-slide image. |
| `--ilastik-model <model.ilp>` | None | A custom `.ilp` file to be used as the classifier model for ilastik. |

**Module selection**
* `--probability-maps <unmicst|ilastik|all>` - which module(s) to use for probability map computation. Default: `unmicst`

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

* `--tool` - the name of the UnMicst version. Version 1 is the old single channel model. Version 2 uses DAPI and lamin. Default is UnMicst version 1 (ONE).
* `--model` - the name of the UNet model. By default, this is the human nuclei model that identifies nuclei centers, nuclei contours, and background from a DAPI channel. Other models include mouse nuclei from DAPI, and cytoplasm from stains resembling WGA
* `--channel` - the channel used to infer and generate probability maps from. Default is the first channel (channel 0). If using UnMicst2, then specify 2 channels. If only 1 channel is specified, it will simply be duplicated.
* `--classOrder` - if your training data isn't in the order 1. background, 2. contours, 3. foreground, you can specify the order here. For example, if you had trained the class order backwards, specify `--classOrder 2 1 0`. If you only have background and contours, use `--classOrder 0 1 0`
* `--mean` - override the trained model's mean intensity. Useful if your images are significantly dimmer or brighter.
* `--std` - override the trained model's standard deviation intensity. Useful if your images are significantly dimmer or brighter.
* `--scalingFactor` - an upsample or downsample factor used to resize the image. Useful when the pixel sizes of your image differ from the model (ie. 0.65 microns/pixel for human nuclei model)
* `--stackOutput` - if selected, UnMicst will write all probability maps as a single multipage tiff file. By default, this is off causing UnMicst to write each class as separate files
* `--GPU` - explicitly specify which GPU (0 indexing) you want to use. Useful for running on local workstations with multiple GPUs

### Arguments to Ilastik(`--ilastik-opts`):

* `--nonzero_fraction` - Indicates fraction of pixels per crop above global threshold to ensure
* `--nuclei_index` - Index of nuclei channel to use for nonzero_fraction argument
* `--crop` - Include if you choose to crop regions for ilastik training, if not, do not include this argument
* `--num_channels` - Number of channels to export per image (Ex: 40 corresponds to a 40 channel ome.tif image)
* `--channelIDs` - Integer indices specifying which channels to export (Ex: 1 2 4)
* `--ring_mask` - Include if you have a ring mask in the same directory to use for reducing size of hdf5 image. do not include if not
* `--crop_amount` -  Number of crops you would like to extract

Up-to-date list can be viewed at [https://github.com/labsyspharm/mcmicro-ilastik](https://github.com/labsyspharm/mcmicro-ilastik)

### Arguments to S3Segmenter(`--s3seg-opts`):

* `--probMapChan` - override the channel to use for nuclei segmentation. By default, this is extracted from the filename in the probabilty map 
* `--crop` - select type of cropping to use. interactiveCrop - a window will appear for user input to crop a smaller region of the image. plate - this is for small fields of view such as from a multiwell plate. noCrop default option to use the entire image

**Nuclei parameters:**
* `--nucleiFilter` - the method to filter false positive nuclei. IntPM - filter based on probability intensity. Int - filted based on raw image intensity
* `--logSigma` - a range of nuclei diameters to search for. Default is 3 to 60 pixels.

**Cytoplasm parameters:**
* `--segmentCytoplasm` - select whether to : segmentCytoplasm - segment the cytoplasm or ignoreCytoplasm - do NOT segment cytoplasm
* `--CytoMaskChan` - select one or more channels to use for segmenting cytoplasm. Default is the 2nd channel.
* `--cytoMethod` - select the method to segment cytoplasm. distanceTransform - take the distance transform outwards from each nucleus and mask with the tissue mask. ring - take an annulus of a certain pixel size around the nucleus (see next argument). Default ring thickness is 5 pixels. hybrid - this uses a combination of greyscale intensity and distance transform to more accurately approximate the extent of the cytoplasm. Similar to Cellprofiler's implementation.
* `--cytoDilation` - the number of pixels to expand from the nucleus to get the cytoplasm ring. Default is 5 pixels.
* `--TissueMaskChan` - select one or more channels to use for identifying the general tissue area for masking purposes. Default is to use a combination of nuclei and cytoplasm channels.

### Arguments to quantification(`--quant-opts`):

Up-to-date list can be viewed at [https://github.com/labsyspharm/quantification](https://github.com/labsyspharm/quantification)

### Arguments to naivestates(`--nstates-opts`):

Up-to-date list can be viewed at [https://github.com/labsyspharm/naivestates](https://github.com/labsyspharm/naivestates)
