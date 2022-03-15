---
layout: default
title: Modules
nav_order: 4
has_children: true
---
{: .text-center }
# The Modular MCMICRO pipeline

![Schematic of the mcmicro pipeline. Level 1 image data is illumination corrected with basic, stitched and registered with ASHLAR, TMA cores can be isolated with Coreograph, then single cells can be segmented with UnMICST and S3segmenter, quantified with MCQuant, checked for quality control with CyLinter, analyzed with SciMap, and visualized with the Minerva Suite]({{ site.baseurl }}/images/pipeline-no-microscope.png)

<br>

# Current modules

## Click image to learn more:
<div class="row">

<div class="col-xs-0 col-sm-2">
<div markdown="1">
</div>
</div>
	
<div class="col-xs-3 col-sm-2">
<div markdown="1">
[![illumination correction "basic"](../images/modules/basic.png)](./basic.html)
</div>
</div>

<div class="col-xs-3 col-sm-2">
<div markdown="1">
[![stitching - ashlar](../images/modules/ashlar.png)](https://labsyspharm.github.io/ashlar){:target="_blank"}
</div>
</div>

<div class="col-xs-3 col-sm-2">
<div markdown="1">
[![TMA core detection - coreograph](../images/modules/coreo.png)](./coreograph.html)
</div>
</div>

<div class="col-xs-3 col-sm-2">
<div markdown="1">
[![segmentation - un-micst](../images/modules/unmicst.png)](./unmicst.html)
</div>
</div>
	
</div><!-- end grid -->

<div class="row">
	
<div class="col-xs-0 col-sm-2">
<div markdown="1">
</div>
</div>
	
<div class="col-xs-3 col-sm-2">
<div markdown="1">
[![segmentation - s3segmenter](../images/modules/s3seg.png)](./s3seg.html)
</div>
</div>
	
<div class="col-xs-3 col-sm-2">
<div markdown="1">
[![quantification - MC Quant](../images/modules/mcquant.png)](./mcquant.html)
</div>
</div>
	
<div class="col-xs-3 col-sm-2">
<div markdown="1">
[![quality control - cylinter](../images/modules/cylinter.png)](https://labsyspharm.github.io/cylinter/){:target="_blank"}
</div>
</div>
	
<div class="col-xs-3 col-sm-2">
<div markdown="1">
[![analysis- sci map](../images/modules/SCIMAP.png)](https://scimap.xyz){:target="_blank"}
</div>
</div>
	
</div><!-- end grid -->

<div class="row">
	
<div class="col-xs-0 col-sm-2">
<div markdown="1">
</div>
</div>

<div class="col-xs-3 col-sm-2">
<div markdown="1">
</div>
</div>

<div class="col-xs-3 col-sm-2">
<div markdown="1">
[![visualization - minerva](../images/modules/minerva.png)](https://github.com/labsyspharm/minerva-story/wiki){:target="_blank"}
</div>
</div>

<div class="col-xs-3 col-sm-2">
<div markdown="1">
[![Additional modules in progress!](../images//modules/others.png)](./#add-a-module)
</div>
</div>
	
</div><!-- end grid -->

## Other modules

| Name | Purpose | References |
| :-- | :-- | :-- | :-- |
| [Ilastik](./other.html#ilastik) | Probability map generator | [Code](https://github.com/labsyspharm/mcmicro-ilastik) - [DOI](https://doi.org/10.1038/s41592-019-0582-9) |
| [Cypository](./other.html#ilastik) | Probability map generator (cytoplasm only) | [Code](https://github.com/HMS-IDAC/Cypository) |
| [naivestates](./other.html#naivestates) | Cell type calling | [Code](https://github.com/labsyspharm/naivestates) |
| [FastPG](./other.html#fastpg) | Cell type calling | [Code](https://github.com/labsyspharm/celluster) - [DOI](https://www.biorxiv.org/content/10.1101/2020.06.19.159749v2) |


# Suggest a module

Module suggestions can be made by posting to [https://forum.image.sc/](https://forum.image.sc/) and tagging your post with the `mcmicro` tag.

# Add a module

MCMICRO allows for certain module types to be specified dynamically through a configuration file. If you already have a containerized method with a command-line interface, follow [our instructions]({{ site.baseurl }}/instructions/advanced-topics/adding.html) to incorporate your module into the pipeline.

{: .no_toc }