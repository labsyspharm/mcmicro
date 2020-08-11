# Instructions how to configure AWS resources for mcmicro

## Install AWS CLI tool
This folder contains the AWS CloudFormation template to create the needed AWS resources for running mcmicro pipeline in AWS. To create the stack, you need to have AWS command line tools installed and configured. Follow the official instructions from here:
- https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html

## Configure parameters.json
You also have to configure a few things in the parameters.json file. Here is a list of the parameters, star denotes a parameter that must be changed from its default value.

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

## Create CloudFormation stack
After everything is configured, run the bash script `create-stack.sh`

If later on you need to change something, e.g. project tag, you need to run the bash script `update-stack.sh`

You should be all set now to run mcmicro in AWS!

