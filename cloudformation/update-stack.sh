#!/bin/bash
aws cloudformation update-stack --stack-name mcmicro-nextflow --template-body file://$PWD/mcmicro-nextflow.yml --parameters file://$PWD/parameters.json --capabilities CAPABILITY_NAMED_IAM
