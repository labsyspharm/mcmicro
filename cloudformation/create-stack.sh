#!/bin/bash
aws cloudformation create-stack --stack-name mcmicro-nextflow --template-body file://$PWD/mcmicro-nextflow.yml --parameters file://$PWD/parameters.json --capabilities CAPABILITY_NAMED_IAM

retVal=$?
if [ $retVal -ne 0 ]; then
    echo "* If the stack has been previously created, run update-stack.sh instead"
fi