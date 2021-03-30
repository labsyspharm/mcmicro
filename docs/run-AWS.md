---
layout: default
title: AWS configuration
nav_order: 32
parent: Running mcmicro
---

# AWS configuration

## Install AWS CLI tool
The folder `cloudformation` contains the AWS CloudFormation template to create the needed AWS resources for running mcmicro pipeline in AWS. To create the stack, you need to have AWS command line tools installed and configured. Follow the official instructions from here:
- https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html

## Configure parameters-batch.json
You also have to configure a few things in the parameters-batch.json file. Here is a list of the parameters, star denotes a parameter that must be changed from its default value.

| ParameterKey | ParameterValue |
| ------------ | -------------- |
| VpcId*        | VPC ID (Select Services->VPC from AWS console, look up the VPC ID) |
| BatchSubnets* | Subnet IDs (comma separated) Select Services->VPC->Subnets from AWS console. Private subnets are more secure and preferred. |
| NextflowAMI  | AMI ID of the EC2 image (Select Services-EC2->AMIs from AWS console, look up the AMI ID) |
| BucketPrefix | Prefix for S3 buckets Nextflow will use. If the prefix is "mcmicro", buckets will be named "mcmicro-in", "mcmicro-out", "mcmicro-work" |
| ProjectTag | Adds a tag named "project" which tracking of AWS costs |
| ComputeEnvironmentNamePrefix | Prefix for the AWS Batch Compute Environments |
| BatchClusterEC2Min/Max/DesiredCpus | These parameters control what type of EC2 instances will be created for the pipeline jobs. Best to leave them as-is, and let Nextflow have the control. |
| BatchClusterSpotBidPercentage | Bid percentage, i.e. how much you are prepared to pay for the Spot instances |

## Create CloudFormation stacks
After everything is configured, run the bash scripts (in this order)
- `create-s3.sh`
- `create-batch.sh`

If later on you need to change something, e.g. project tag, you need to run the bash script `update-s3.sh` and `update-batch.sh` 
(When updating AWS Batch resources you might need to delete the stack from AWS console first and then recreate it from scratch)

You should be all set now to run mcmicro in AWS!

## Running mcmicro with an EC2 instance

### Create and configure EC2 instance
When using AWS, it's recommended to run Nextflow within an EC2 instance. Network access to S3 work bucket will be much faster. Follow these steps to create and configure the EC2 instance:
- Create a new EC2 instance. The instance is used only to run Nextflow and orchestrate the pipeline, it will not be used to run actual jobs. Hence a low performance type such as t3.small/medium should suffice.
- The instance needs an IAM role which allows access to AWS Batch and S3. You can use the provided IAM role: mcmicro-nextflow-batch-McmicroEC2ClientProfile
- Start the instance, and install AWS CLI, Nextflow and mcmicro

### Run mcmicro pipeline
Input data can either be in local computer or in S3 bucket. If the data is local, Nextflow will
upload it automatically to S3 anyway (staging).

Log in EC2 instance

Run mcmicro pipeline according to normal instructions, but with a few changes:
- use one of the AWS profiles, e.g. AWSTMA
- give the S3 work bucket with parameter -bucket-dir
- give the S3 out bucket with parameter --out
- give the S3 in bucket with parameter --in (if input data was copied to S3)
`nextflow run labsyspharm/mcmicro -profile AWSTMA -bucket-dir s3://mcmicro-work/imagename --in s3://mcmicro-in/imagename --out s3://mcmicro-out/imagename`

