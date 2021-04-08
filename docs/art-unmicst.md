# UnMICST - Universal Models for Identifying Cells and Segmenting Tissue <br>
![](/images/unmicstbannerv2.png) <br>
<p align="center"> 
  (pronounced un-mixed)
</p>

## Introduction
Nuclei segmentation, especially for tissues, is a challenging and unsolved problem. Convolutional neural networks are particularly well-suited for this task: classifying image pixels into nuclei centers, nuclei contours and background. UnMICST generates probability maps where the intensity at each pixel defines how confident the pixel has been correctly classified to the aforementioned classes. These maps that can make downstream image binarization more accurate using tools such as s3segmenter. https://github.com/HMS-IDAC/S3segmenter. UnMICST currently uses the UNet architecture (Ronneberger et al., 2015) but Mask R-CNN and Pyramid Scene Parsing (PSP)Net are coming very soon! The concept, models, and training data are features here: https://www.biorxiv.org/content/10.1101/2021.04.02.438285v1

![](/images/unmicst2.png)
- training images from 7 tissue types that appeared to encapsulate the different morphologies of the entire tissue microarray: 1) lung adenocarcinoma, 2) non-neoplastic prostate, 3) non-neoplastic small intestine, 4) non-neoplastic ovary, 5) tonsil, 6) glioblastoma, and 7) colon adenocarcinoma. 
- manual annotations of the nuclei centers, contours, and background of the abovementioned tissue types<br>
- DNA channel and nuclear envelope staining (lamin B and nucleoporin 98) for improved accuracy<br>


## Prerequisite files
-an .ome.tif or .tif  (preferably flat field corrected, minimal saturated pixels, and in focus. The model is trained on images acquired at a pixelsize of 0.65 microns/px. If your settings differ, you can upsample/downsample to some extent.

## Expected output files
1. a tiff stack where the different probability maps for each class are concatenated in the Z-axis in the order: nuclei foreground, nuclei contours, and background with suffix *_Probabilities*
2. a QC image with the DNA image concatenated with the nuclei contour probability map with suffix *_Preview*

## Parameter list
1. `--tool` : specify which UnMICST version you want to use (ie. UnMicst, UnMicst1-5, UnMicst2). v1 is deprecated. v1.5 uses the DNA channel only. v2 uses DNA and nuclear envelope staining.
2. `--channel` : specify the channel(s) to be used. 
3. `--scalingFactor` : an upsample or downsample factor if your pixel sizes are mismatched from the dataset.
4. `--mean` and `--std` : If your image is vastly different in terms of brightness/contrast, enter the image mean and standard deviation here.

## Scenarios
**1. What's with all the different versions?? Why should I use a 2nd nuclei stain.**<br>
UnMicst1-5 (v1.5) uses a single DNA channel whereas UnMicst2 (v2) uses a DNA channel and a nuclear envelope stain. This can come from markers such as lamin B1, B2, nucleoporin 98 or some additive combination. 

**2. You said the training data is sampled at 0.65microns/pixel and acquired with a 20x/0.75NA objective lens. What do I do if my data was acquired with a 40x lens?**
First of all, check what is your pixel size since that is more relevant. If your pixel size is about half of the training data (ie. 0.325 microns/pixel), use a `--samplingFactor` of 0.5. If your pixel size is double (ie. 1.3 microns/pixel), then set your `--scalingFactor` to 2.




## References: <br/>
Clarence Yapp, Edward Novikov, Won-Dong Jang, Yu-An Chen, Marcelo Cicconet, Zoltan Maliga, Connor A. Jacobson, Donglai Wei, Sandro Santagata, Hanspeter Pfister, Peter K. Sorger, 2021, UnMICST: Deep learning with real augmentation for robust segmentation of highly multiplexed images of human tissues

S Saka, Y Wang, J Kishi, A Zhu, Y Zeng, W Xie, K Kirli, C Yapp, M Cicconet, BJ Beliveau, SW Lapan, S Yin, M Lin, E Boyde, PS Kaeser, G Pihan, GM Church, P Yin, 2020, Highly multiplexed in situ protein imaging with signal amplification by Immuno-SABER, Nat Biotechnology 


