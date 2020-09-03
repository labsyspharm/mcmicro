#!/bin/bash

cp -r ~/data/downloads/exemplar-001 ~/data/exemplar-001-ss
./nextflow main.nf --in ~/data/exemplar-001-ss --start-at registration --stop-at registration
./nextflow main.nf --in ~/data/exemplar-001-ss --start-at probability-maps --stop-at probability-maps --probability-maps ilastik
./nextflow main.nf --in ~/data/exemplar-001-ss --start-at segmentation --stop-at segmentation --probability-maps ilastik
./nextflow main.nf --in ~/data/exemplar-001-ss --start-at probability-maps --stop-at probability-maps --probability-maps unmicst
./nextflow main.nf --in ~/data/exemplar-001-ss --start-at segmentation --stop-at segmentation --probability-maps unmicst
