---
layout: default
title: Overview
nav_order: 2
has_children: true
---

# Overview Video

{% include youtube.html id="fnxBvgJQmtY" autoplay=false mute=false controls=true loop=false related=false %}

A general introduction [video](https://www.youtube.com/watch?v=fnxBvgJQmtY){:target="_blank"} that provides a high-level overview of the pipeline.

---
# Overview of multiplexed tissue imaging collection, processing, and analysis

Multiplexed tissue imaging has three distinct phases. In the first phase, tissue samples are collected in clinics, brought into a laboratory, and stained to highlight specific proteins and molecules within the tissue. In the second phase, these samples are imaged on a microscope. In the third phase these images need to be processed and analyzed. Processing and analyzing multiplexed images - which can encompass massive amounts of data - is a computationally intensive task. MCMICRO provides a modular solution to this problem. 

In the following pages, we introduce some key background information relevant to highly multiplexed tissue imaging. These sections provide context on tissue imaging and highlight the need for MCMICRO -- **jump around as needed!**

<div class=" row center-xs">

<div class="col-xs-4 col-sm-4">
{% assign imageUrl = site.baseurl | append: "/images/main-menu-1.png" %} {% include image-card.html 
	image=imageUrl
	link="./exp.html"
%} 
</div>
<div class="col-xs-4 col-sm-4">
{% assign imageUrl = site.baseurl | append: "/images/main-menu-2.png" %} {% include image-card.html
	image=imageUrl 
	link="./exp.html#phase-2-immunofluorescence-imaging-for-biological-samples"
%} 
</div>
<div class="col-xs-4 col-sm-4">
{% assign imageUrl = site.baseurl | append: "/images/main-menu-3.png" %} {% include image-card.html
	image=imageUrl 
	link="./mcmicro.html"
%} 
</div>
</div><!-- end grid -->

