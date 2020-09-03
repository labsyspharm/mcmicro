#!/bin/bash

cp -r ~/data/downloads/exemplar-002 ~/data/
./nextflow main.nf --in ~/data/exemplar-002 --tma --probability-maps all
