---
layout: default
title: UnMICST
nav_order: 33
parent: Modules
---

# UnMICST - Universal Models for Identifying Cells and Segmenting Tissue <br>
![]({{ site.baseurl }}/images/unmicstbannerv2.png) <br>
<p align="center"> 
  (pronounced un-mixed)
</p>

## Introduction
Nuclei segmentation, especially for tissues, is a challenging and unsolved problem. Convolutional neural networks are particularly well-suited for this task: separating the foreground class (nuclei pixels) from the background class. [UnMICST](https://labsyspharm.github.io/UnMICST-info/){:target="_blank"} generates probability maps where the intensity at each pixel defines how confident the pixel has been correctly classified to the aforementioned classes. These maps can make downstream image binarization more accurate using tools such as [S3segmenter](https://github.com/HMS-IDAC/S3segmenter) [(Saka et al., 2019)](https://doi.org/10.1038/s41587-019-0207-y){:target="_blank"}. UnMICST currently uses the UNet architecture [(Ronneberger et al., 2015)](https://arxiv.org/abs/1505.04597){:target="_blank"} but Mask R-CNN and Pyramid Scene Parsing (PSP)Net are coming very soon!

**For more information about accessing the training data visit:** [https://github.com/HMS-IDAC/UnMicst](https://github.com/HMS-IDAC/UnMicst){:target="_blank"}
<br>
**or read the article here:** [(Yapp et al., 2021)](https://doi.org/10.1101/2021.04.02.438285){:target="_blank"}

![]({{ site.baseurl }}/images/unmicst2.png)
This model has been trained on 6 issue types that appeared to encapsulate the different morphologies of the entire tissue microarray: 1) lung adenocarcinoma, 2) non-neoplastic prostate, 3) non-neoplastic small intestine, 4) tonsil, 5) glioblastoma, and 6) colon adenocarcinoma. Also, single and dual channels are possible through a DNA channel and nuclear envelope staining (lamin B and nucleoporin 98) for improved accuracy. Intentionally defocused planes and saturated pixels were also added for better dealing with real-world artifacts.


## Prerequisite files
-an .ome.tif or .tif  (preferably flat field corrected, minimal saturated pixels, and in focus. The model is trained on images acquired at a pixelsize of 0.65 microns/px. If your settings differ, you can upsample/downsample to some extent.

## Expected output files
1. a tiff stack where the different probability maps for each class are concatenated in the Z-axis in the order: nuclei foreground, nuclei contours, and background.
2. a QC image with the DNA image concatenated with the nuclei contour probability map with suffix *_Preview*

## Parameter list
1. `--tool` : specify which UnMICST version you want to use (ie. unmicst-legacy, unmicst-solo, unmicst-duo). *unmicst-legacy* is deprecated. *unmicst-solo* only uses the DNA channel. *unmicst-duo* uses DNA and a nuclear envelope stain for better accuracy.
2. `--channel` : specify the channel(s) to be used. 1-based indexing is used here.
3. `--scalingFactor` : an upsample or downsample factor if your pixel sizes are mismatched from the dataset.
4. `--mean` and `--std` : If your image is vastly different in terms of brightness/contrast, enter the image mean and standard deviation here.

## Scenarios
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

