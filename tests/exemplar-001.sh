#!/bin/bash

cp -r ~/data/downloads/exemplar-001 ~/data/
./nextflow main.nf --in ~/data/exemplar-001 --probability-maps all
