#!/bin/bash

cp -r ~/data/downloads/exemplar-001 ~/data/
./nextflow main.nf --in ~/data/exemplar-001 --probability-maps all
rm -r ~/data/exemplar-001

cp -r ~/data/downloads/exemplar-001 ~/data/
./nextflow main.nf --in ~/data/exemplar-001 --start-at registration --stop-at registration
./nextflow main.nf --in ~/data/exemplar-001 --start-at probability-maps --stop-at probability-maps --probability-maps ilastik
./nextflow main.nf --in ~/data/exemplar-001 --start-at segmentation --stop-at segmentation --probability-maps ilastik
./nextflow main.nf --in ~/data/exemplar-001 --start-at probability-maps --stop-at probability-maps --probability-maps unmicst
./nextflow main.nf --in ~/data/exemplar-001 --start-at segmentation --stop-at segmentation --probability-maps unmicst
