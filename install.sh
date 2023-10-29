#!/bin/bash

# Best way to install is just create the pipeline and let it do all the work

# Must pass in an s3 bucket (private) where the source code zip can be stored...
if [ -z $1 ]; then
        echo "Need the S3 Bucket Name as a parameter. Exiting..."
        exit 0
fi
BUCKET=$1

./00-repo.sh $BUCKET

./03-deploy-pipeline.sh