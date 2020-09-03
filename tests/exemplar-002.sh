#!/bin/bash

if [ -d ~/data/downloads/exemplar-002 ]; then
  echo "Using cached exemplar-002 download";
else
  ./nextflow exemplar.nf --name exemplar-002 --path ~/data/downloads;
fi
cp -r ~/data/downloads/exemplar-002 ~/data/
./nextflow main.nf --in ~/data/exemplar-002 --tma --probability-maps all
