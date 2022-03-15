---
layout: default
title: S3segmenter
nav_order: 34
parent: Parameter tuning
---

![]({{ site.baseurl }}/images/segbannerv8.png)<br>
<p align="center">
  "So... you want to do single-cell image segmentation?"
</p>


## Input

1.  An ``.ome.tif`` (preferably flat field corrected)
2.  A 3-class probability map (derived from a deep learning model such as [UnMICST](./unmicst.html) or [Ilastik](./other.html#ilastik)).

[S3segmenter](https://github.com/HMS-IDAC/S3segmenter) assumes that you have:

{: .fs-3}
1. Acquired images of your sample with optimal acquisition settings.
2. Stitched and registered the tiles and channels respectively (if working with a large piece of tissue) and saved it as a Bioformats compatible tiff file.
3. Processed your image in some way so as to increase contrast between individual nuclei using classical or machine learning methods such as [Ilastik](./other.html#ilastik) (a random forest model) or [UnMICST](./unmicst.html) (a deep learning semantic segmentation model based on the UNet architecture). MCMICRO supports both.

## Output
**1) 32-bit label masks for each compartment of the cell:**  

{: .fs-3}
  >* `nuclei.ome.tif` (nuclei) 
  >* `cytoplasm.ome.tif` (cytoplasm) 
  >* `cell.ome.tif` (whole cell)
  >* If only nuclei segmentation was carried out, `cell.ome.tif` is identical to `nuclei.ome.tif`
 
**2) Two-channel quality control files with outlines overlaid on gray scale image of channel used for segmentation**  

{: .fs-3}
  >* `nucleiOutlines.tif` (nuclei),
  >* `cytoplasmOutlines.tif` (cytoplasm) 
  >* `cellOutlines.tif` (whole cell)
  >* If only nuclei segmentation was carried out, `cellOutlines.tif` is identical to `nucleiOutilnes.tif`

{: .fs-3}
**NOTE:** There are at least 2 ways to segment cytoplasm: i) using a watershed approach or ii) taking an annulus/ring around nuclei. Files generated using the annulus/ring method will have ‘Ring’ in the filename whereas files generated using watershed segmentation will not. It is important that these two groups of files are NOT combined and analyzed simultaneously as cell IDs will be different between them.

## Usage

 `--s3seg-opts`
 
 Example: ``nextflow run labsyspharm/mcmicro --in /my/data --s3seg-opts``

 
## Parameter list

### Required arguments

### Optional arguments

| Parameter | Default | Description |
| --- | --- | --- |
| `--probMapChan <index>` | `1` | which channel is used for nuclei segmentation. **Coincides with the channel used in upstream semantic segmentation modules. Must specify when different from default.**  |
| `--crop <selection>` | `noCrop` | Type of cropping: `interactiveCrop` - a window will appear for user input to crop a smaller region of the image; `plate` - this is for small fields of view such as from a multiwell plate; `noCrop`, the default, is to use the entire image |

#### Nuclei parameters:

| Parameter | Default | Description |
| --- | --- | --- |
| `--nucleiFilter <selection>` | `IntPM` | Method to filter false positive nuclei: `IntPM` - filter based on probability intensity; `Int` - filted based on raw image intensity |
| `--logSigma <value> <value>` | `3 60` | A range of nuclei diameters to search for. |

#### Cytoplasm parameters:

| Parameter | Default | Description |
| --- | --- | --- |
| `--segmentCytoplasm <selection>` | `ignoreCytoplasm` | Select whether to `segmentCytoplasm` or `ignoreCytoplasm` |
| `--CytoMaskChan <index>` | `2` | One or more channels to use for segmenting cytoplasm, specified as 1-based indices (e.g., `2` is the 2nd channel). |
| `--cytoMethod <selection>` | `distanceTransform` | The method to segment cytoplasm: `distanceTransform` - take the distance transform outwards from each nucleus and mask with the tissue mask; `ring` - take an annulus of a certain pixel size around the nucleus (see `cytoDilation`); `hybrid` - uses a combination of greyscale intensity and distance transform to more accurately approximate the extent of the cytoplasm. Similar to Cellprofiler's implementation. |
| `--cytoDilation <value>` | `5` | The number of pixels to expand from the nucleus to get the cytoplasm ring. |
| `--TissueMaskChan <index>` | Union of `probMapChan` and `CytoMaskChan` | One or more channels to use for identifying the general tissue area for masking purposes. |

---

## Troubleshooting scenarios
### **1. I’m new to this whole segmentation thingy. And I have a deadline. Just get me started with finding nuclei!**<br>
In its simplest form, s3segmenter by default will identify primary objects only (usually nuclei) and assumes this is in channel 1 (the first channel). In this case, no settings need to be specified.<br>

`s3seg-opts: <leave blank>`<br>
![]({{ site.baseurl }}/images/segmentation1.png)<br>

If you had used a different channel other than channel 1 for any preprocessing steps, then specify this using `--probMapChan <channel>`. For example, if you had used channel 5 in UnMICST, set `--probMapChan 5` so that the two steps remain in sync. <br>

### **2. It’s a disaster. It’s not finding all the nuclei**<br>
Depending on the type of pre-processing that was done, you may need to use a different method of finding cells. Let’s add `--nucleiRegion localMax` to the options:<br>
`s3seg-opts: ’--nucleiRegion localMax’`<br>
![]({{ site.baseurl }}/images/segmentation2.png)<br>
### **3. Looks good! I want to filter out some objects based on size**<br>
You can specify a range of nuclei diameters that you expect your nuclei to be. Using `--logSigma <low end of range> <high end of range>`
Ie. `--logSigma 10 50` will retain all nuclei that have diameters between 10 and 50 pixels. Default is 3 60

**Examples:**
a) <br>
`s3seg-opts: ‘--nucleiRegion localMax --logSigma 3 10’`<br>
![]({{ site.baseurl }}/images/segmentation3.png)<br>
b) <br>
`s3seg-opts: ‘--nucleiRegion localMax --logSigma 30 60’`<br>
![]({{ site.baseurl }}/images/segmentation3b.png)<br>
c) default: <br>
`s3seg-opts: ‘--nucleiRegion localMax --logSigma 3 60’` <br>
![]({{ site.baseurl }}/images/segmentation3c.png)<br>
### **4. a) How do I segment the cytoplasm as well?**<br>
To do this, you will need to:
1. look at your image and identify a suitable cytoplasm channel such as the example below. <br>
![]({{ site.baseurl }}/images/segmentation4aa.png)<br>
Nuclei and cytoplasm stained with Hoechst (purple) and NaK ATPase (green) respectively.
Notice how the plasma membrane is distinctive and separates one cell from another. It also has good signal-to-background (contrast) and is in-focus.

Specify `--CytoMaskChan <channel number(s) of cytoplasm>`. For example, to specify the 10th channel, use  `--CytoMaskChan 10`. To combine and sum the 10th and 11th channels, use `--CytoMaskChan 10 11`. Doing this maximizes the ability to capture more cells.

2. Also, specify this to activate cytoplasm segmentation:
`--segmentyCytoplasm segmentCytoplasm`

`s3seg-opts: ‘--nucleiRegion localMax --CytoMaskChan 10 --segmentCytoplasm segmentCytoplasm’`<br>
![]({{ site.baseurl }}/images/segmentation4ab.png)<br>
**4. b) I don’t have a suitable cytoplasm channel…..**<br>
That’s ok. Cytoplasm segmentation is hard because there isn’t a universal marker. It’s generally acceptable to sample some number of pixels around the nucleus to approximate the cytoplasm.
1. Choose `--cytoMethod ring`
2. Then, specify the width of this ring `--cytoDilation <thickness of ring in pixels>` ie. `--cytoDilation 3` will surround the nuclei with a 3-pixel thick cytoplasmic ring. The default is 5 pixels.

**Examples**<br>
i) <br>
`s3seg-opts: ’--nucleiRegion localMax --CytoMaskChan 10 --segmentCytoplasm segmentCytoplasm --cytoMethod ring --cytoDilation 15’`<br>
![]({{ site.baseurl }}/images/segmentation4bi.png)<br>
Cytoplasm spilling beyond cytoplasm stain. Possibly too large `--cytoDilation` parameter.

ii) <br>
`s3seg-opts: ‘--nucleiRegion localMax --CytoMaskChan 10 --segmentCytoplasm segmentCytoplasm --cytoMethod ring --cytoDilation 6’`<br>
![]({{ site.baseurl }}/images/segmentation4bii.png)<br>
Much better. Cytoplasm outlines now just within the marker stain.

**4. c) Are there other ways to detect the cytopolasm?**<br>
There’s a hybrid approach that combines a cytoplasm channel and the ring around the nuclei to deal with tissues that have sporadic cytoplasm staining.
Try changing --cytoMethod to ‘hybrid’.<br>

`s3seg-opts: ‘--nucleiRegion localMax --CytoMaskChan 10 --segmentCytoplasm segmentCytoplasm --cytoMethod hybrid’`<br>
![]({{ site.baseurl }}/images/segmentation4c.png)<br>
This is still a very experimental technique and may not yield better results!

### **5. I have an instance segmentation model, which already produces a mask. How do I incorporate this in?.**
S3segmenter can accept pre-made instance segmentation primary object masks and still run some of the later functions we talked about above. To bypass nuclei segmentation, specify `--nucleiRegion bypass`. Then, you can still use `--logSigma` to filter overly small/large objects.

`s3seg-opts: ’--logSigma 45 300 --nucleiRegion bypass’`<br>
![]({{ site.baseurl }}/images/segmentation5ii.png)
![]({{ site.baseurl }}/images/segmentation5i.png)

### **6. Nuclei…. Cytoplasm… NOW GIVE ME INTRACELLULAR SPOTS**
This is a very complexed operation and requires several parameters.
1. Detail which channels you want to run spot detection on.
`--detectPuncta <channel number(s)>` . ie. `--detectPuncta 1 2 3` will look for spots in the 1st, 2nd, and 3rd channels.

2. `--punctaSigma <the sigma(s) of the spots in each channel>`. This is equivalent to the standard deviation of a fitted Gaussian curve through one of your spots. 
Select custom values for each channels. 
Ie. `--punctaSigma 1.5 2 1.75`
 If you specify one value, it will use that for all channels

3. Lastly, choose the sensitivity of the spot detector.
`--punctaSD <standard deviations for each channel>`. 

Lower numbers increase sensitivity at the expense of  more false positives. Not advisable when images are very noisy. May need to work out SD empirically. 

Select custom values for each channels. 
i) ie. `--punctaSD 10 12 10` (more stringent)
Note:  If you specify one value, it will use that for all channels<br>
![]({{ site.baseurl }}/images/segmentation5ci.png)<br>
Hmmm….only 4 puncta are being detected shown by the green dots, but there are clearly other spots not being picked up.

ii)  `--punctaSD 3 3 3` (more sensitive)<br>
![]({{ site.baseurl }}/images/segmentation5cii.png)<br>
Perfect! All visible spots appear to be detected with the more sensitive option.

`s3seg-opts: ’--logSigma 45 300 --detectPuncta 1 2 3 --punctaSigma 1.5 2 1.75 --punctaSD 3'`
