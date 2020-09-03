#!/bin/bash

cp -r ~/data/downloads/exemplar-002 ~/data/
travis_wait ./nextflow main.nf --in ~/data/exemplar-002 --tma --stop-at registration
./nextflow main.nf --in ~/data/exemplar-002 --tma --start-at dearray --probability-maps all
