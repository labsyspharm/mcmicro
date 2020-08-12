#!/bin/bash
aws cloudformation create-stack --stack-name mcmicro-nextflow-batch --template-body file://$PWD/mcmicro-nextflow-batch.yml --parameters file://$PWD/parameters-batch.json --capabilities CAPABILITY_NAMED_IAM

retVal=$?
if [ $retVal -ne 0 ]; then
    echo "* If the stack has been previously created, run update-stack.sh instead"
fi