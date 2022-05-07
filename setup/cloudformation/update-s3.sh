#!/bin/bash
aws cloudformation update-stack --stack-name mcmicro-nextflow-s3 --template-body file://$PWD/mcmicro-nextflow-s3.yml --parameters file://$PWD/parameters-s3.json