#!/bin/bash
aws cloudformation create-stack --stack-name mcmicro-nextflow-s3 --template-body file://$PWD/mcmicro-nextflow-s3.yml --parameters file://$PWD/parameters-s3.json

retVal=$?
if [ $retVal -ne 0 ]; then
    echo "* If the stack has been previously created, run update-stack.sh instead"
fi