---
layout: default
title: UnMICST
nav_order: 33
parent: Modules
---

# UnMICST - Universal Models for Identifying Cells and Segmenting Tissue <br>
![UnMICST banner image]({{ site.baseurl }}/images/unmicstbannerv2.png) <br>
<p align="center"> 
  (pronounced un-mixed)
</p>

## Introduction
Nuclei segmentation, especially for tissues, is a challenging and unsolved problem. Convolutional neural networks are particularly well-suited for this task: separating the foreground class (nuclei pixels) from the background class. [UnMICST](https://labsyspharm.github.io/UnMICST-info/){:target="_blank"} generates probability maps where the intensity at each pixel defines how confident the pixel has been correctly classified to the aforementioned classes. UnMICST can utilize a nuclear envelope channel (lamin B and nucleoporin 98) alongside a DNA channel to improve segmentation accuracy, in addition to more standard single-channel segmentation.

These probability maps can make downstream image binarization more accurate using tools such as [S3segmenter](https://github.com/HMS-IDAC/S3segmenter) [(Saka et al., 2019)](https://doi.org/10.1038/s41587-019-0207-y){:target="_blank"}. UnMICST currently uses the UNet architecture [(Ronneberger et al., 2015)](https://arxiv.org/abs/1505.04597){:target="_blank"} but Mask R-CNN and Pyramid Scene Parsing (PSP) Net are coming very soon!

## Training data
Quality machine learning algorithms can only be generated from quality training data. 

*UnMICST has been trained on 6 issue types that encapsulate the different morphologies of the entire tissue microarray:*
1) lung adenocarcinoma, 
2) non-neoplastic prostate
3) non-neoplastic small intestine, 
4) tonsil, 
5) glioblastoma, and 
6) colon adenocarcinoma. 

UnMICST also trained on **real augmentations** - such as intentionally de-focused planes and saturated pixels - to further improve segmentation accuracy relative to real-world experimental artifacts. 

**For more information about accessing the training data visit:** [https://github.com/HMS-IDAC/UnMicst](https://github.com/HMS-IDAC/UnMicst){:target="_blank"}
<br>
**or read the publication here:** [(Yapp et al., 2021)](https://doi.org/10.1101/2021.04.02.438285){:target="_blank"}

![Image of a single TMA core with two insets that show single cells that have been segmented]({{ site.baseurl }}/images/unmicst2.png)

## Input

{: .fs-3 }
An ```.ome.tif``` or ```.tif```  

{: .text-center}
{: .fs-3 }
{: .fw-300 }
(preferably flat field corrected, minimal saturated pixels, and in focus. The model is trained on images acquired at a pixelsize of 0.65 microns/px. If your settings differ, you can upsample/downsample to some extent.

## Expected output files

{: .fs-3 }
1. a ```.tif``` stack where the different probability maps for each class are concatenated in the Z-axis in the order: nuclei foreground, nuclei contours, and background.
2. a QC image with the DNA image concatenated with the nuclei contour probability map with suffix *Preview*

## Usage

`--unmicst-opts`

## Parameter list

### Required arguments

### Optional arguments

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


	
## Troubleshooting Scenarios
**1. I just wanted to get started.** <br>
set `--tool unmicst-solo` and choose a channel that has your DNA stain. If this is in the first channel, use `--channel 1`. <br>
`unmicst-opts: '--tool unmicst-solo --channel 1'` <br>
![]({{ site.baseurl }}/images/unmicst3.png) <br>

**2. My tissue images have very packed nuclei. What do I do??**<br>
unmicst-solo uses a single DNA channel whereas unmicst-duo uses a DNA channel and a nuclear envelope stain, which can help the model discriminate between tightly-packed nuclei. This additional stain can come from markers such as lamin B1, B2, nucleoporin 98 or some additive combination. 
Set `--tool unmicst-duo` and choose channels that have your DNA and nuclear envelope stains. If your DNA and envelope stains are in the 1st and 5th channel respectively, use `--channel 1 5`. <br>
`unmicst-opts: '--tool unmicst-duo --channel 1 5'` <br>
![]({{ site.baseurl }}/images/unmicst4.png) <br>

**3. My tissue images are blurry. What do I do??**<br>
Again, consider using *unmicst-duo* with a nuclear envelope stain.<br>
*without nuclear envelope stain*<br>
![]({{ site.baseurl }}/images/unmicst5.png) <br>
<br>
<br>
*with nuclear envelope stain*<br>
![]({{ site.baseurl }}/images/unmicst6.png) <br>

**4. You said the training data is sampled at 0.65microns/pixel and acquired with a 20x/0.75NA objective lens. What do I do if my data was acquired with a 40x lens?**<br>
First of all, check what is your pixel size since that is more relevant. If your pixel size is about half of the training data (ie. 0.325 microns/pixel), use a `--scalingFactor` of 0.5. If your pixel size is double (ie. 1.3 microns/pixel), then set your `--scalingFactor` to 2.

**5. I heard unmicst-legacy is spectacular.**<br>
You mean spectacularly **bad**. unmicst-legacy is deprecated. Use unmicst-solo or unmicst-duo if you have a nuclear envelope staining.

