# Parameter reference

## Parameters controlling the pipeline behavior

The following parameters control the pipeline as a whole. These can be specified on the command line using the double-dash format (e.g., `--in`), or inside a YAML file as key-value pairs. Parameters that don't require an explicit value because their presence controls the behavior (e.g., `--tma`) should instead be assigned to `true` in the YAML file. For example,

Example: `nextflow run labsyspharm/mcmicro-nf --in /my/data --tma`

or equivalently: `nextflow run labsyspharm/mcmicro-nf -params-file myparams.yml`, where `myparams.yml` contains
```
in: /my/data
tma: true
```

**Mandatory parameters:**

* `--in /local/path` - specifies location of the data

**Optional parameters:**

* `--sample-name <myname>` - the name of the experiment/specimen. By default, mcmicro extracts this from the path supplied to `--in`.
* `--start-at <step>` - name of the first step to be executed by the pipeline. The value `<step>` must be one of `raw`, `illumination`, `registration`, `dearray` (TMA only), `probability-maps`, `segmentation`, `quantification`, `cell-states`. Default: `registration`.
* `--stop-at <step>` - name of the final step to be executed by the pipeline. Spans the same vocabulary as `--start-at`. Default: `cell-states`.
* `--tma` - if specified, mcmicro treats input data as a TMA. If omitted, the input is assumed to be a whole-slide image. Default: omitted.
* `--raw-formats <formats>` - one or more file formats that mcmicro should look for. Default: `{.ome.tiff,.ome.tif,.rcpnl,.xdce,.nd,.scan,.htd,.btf,.nd2,.tif,.czi}`
* `--probability-maps <unmicst|ilastik|all>` - which module(s) to use for probability map computation. Default: `unmicst`

## Parameters for individual modules

It is important to make a distinction between parameters that control behavior of individual modules, and parameters that specify which files the modules operate on. Because all file management is done at the level of the pipeline, special treatment is required for the latter set (e.g., specifying a different mask to use for quantification).

**Arguments to handle file-referencing parameters:**

* `--mask-spatial <filename>` - which segmentation mask should be used for extracting spatial features. Must be a filename produced by the s3segmenter. Default: `cellMask.tif`
* `--mask-add <filenames>` - one or more filenames referencing masks produced by the s3segmenter that should also be quantified. The filenames should be surrounded with single quotes (`'`). For example, `--mask-add 'cytoMask.tif nucleiMask.tif'`. Default: none.

**Plain arguments for individual modules:**

Parameters that don't reference any files can be fed directly to each module through the `--*-opts` arguments in mcmicro:

| Module | mcmicro Argument |
| --- | --- |
| ASHLAR | `--ashlar-opts` |
| UnMicst | `--unmicst-opts` |
| S3Segmenter | `--s3seg-opts` |
| quantification | `--quant-opts` |
| naivestates | `--nstates-opts` |

Surround module parameters with single quotes `'`.

Example 1: `nextflow run labsyspharm/mcmicro-nf --in /my/data --ashlar-opts '-m 30 --pyramid'`

Example 2: `nextflow run labsyspharm/mcmicro-nf --in /my/data --nstates-opts '--log no --plots pdf'`

**ASHLAR arguments:** Up-to-date list can be viewed at https://github.com/labsyspharm/ashlar

**Coreograph arguments:** Up-to-date list can be viewed at https://github.com/HMS-IDAC/UNetCoreograph

**UnMicst arguments:**
*--model - the name of the UNet model. By default, this is the human nuclei model that identifies nuclei centers, nuclei contours, and background from a DAPI channel. Other models include mouse nuclei from DAPI, and cytoplasm from stains resembling WGA
--channel - the channel used to infer and generate probability maps from. Default is the first channel (channel 0)
--classOrder - if your training data isn't in the order 1. background, 2. contours, 3. foreground, you can specify the order here. For example, if you had trained the class order backwards, specify --classOrder 2 1 0. If you only have background and contours, use --classOrder 0 1 0
-- mean - override the trained model's mean intensity. Useful if your images are significantly dimmer or brighter.
--std - override the trained model's standard deviation intensity. Useful if your images are significantly dimmer or brighter.
--scalingFactor - an upsample or downsample factor used to resize the image. Useful when the pixel sizes of your image differ from the model (ie. 0.65 microns/pixel for human nuclei model)
--stackOutput (NEW) - if selected, UnMicst will write all probability maps as a single multipage tiff file. By default, this is off causing UnMicst to write each class as separate files

**S3Segmenter arguments:** 
*--probMapChan - override the channel to use for nuclei segmentation. By default, this is extracted from the filename in the probabilty map 
--crop - select type of cropping to use. interactiveCrop - a window will appear for user input to crop a smaller region of the image. plate - this is for small fields of view such as from a multiwell plate. noCrop default option to use the entire image

Nuclei parameters:
--nucleiFilter - the method to filter false positive nuclei. IntPM - filter based on probability intensity. Int - filted based on raw image intensity
--logSigma - a range of nuclei diameters to search for. Default is 3 to 60 pixels.

Cytoplasm parameters:
--segmentCytoplasm - select whether to : segmentCytoplasm - segment the cytoplasm or ignoreCytoplasm - do NOT segment cytoplasm
--CytoMaskChan - select one or more channels to use for segmenting cytoplasm. Default is the 2nd channel.
--cytoMethod - select the method to segment cytoplasm. distanceTransform - take the distance transform outwards from each nucleus and mask with the tissue mask. ring - take an annulus of a certain pixel size around the nucleus (see next argument). Default ring thickness is 5 pixels. hybrid - this uses a combination of greyscale intensity and distance transform to more accurately approximate the extent of the cytoplasm. Similar to Cellprofiler's implementation.
--cytoDilation - the number of pixels to expand from the nucleus to get the cytoplasm ring. Default is 5 pixels.
--TissueMaskChan - select one or more channels to use for identifying the general tissue area for masking purposes. Default is to use a combination of nuclei and cytoplasm channels.

**quantification arguments:** TODO: Denis, fill this out

**naivestates arguments:** Up-to-date list can be viewed at https://github.com/labsyspharm/naivestates
