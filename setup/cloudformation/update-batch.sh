#!/bin/bash
aws cloudformation update-stack --stack-name mcmicro-nextflow-batch --template-body file://$PWD/mcmicro-nextflow-batch.yml --parameters file://$PWD/parameters-batch.json --capabilities CAPABILITY_NAMED_IAM
