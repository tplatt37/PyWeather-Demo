#!/bin/bash
# Must pass in the bucket name you want to use.

# Must pass in an s3 bucket (private) where the source code zip can be stored...
if [ -z $1 ]; then
        echo "Need the S3 Bucket Name as a parameter. Exiting..."
        exit 0
fi
BUCKET=$1

PREFIX=PyWeather-Demo

# First, we create a Zip of the latest A-New-Startup app code from Github,
# and copy it into the S3 bucket.  Cloudformation will use that to seed the CC repo.

# Make sure we don't have this folder local
rm -rf PyWeather-Demo-github
# We'll create/re-create this - so make sure it isn't there. 
rm -f PyWeather-Demo.zip

echo "Attemping to retrieve latest PyWeather-Demo app source code from GitHub."
git clone https://github.com/tplatt37/PyWeather-Demo.git PyWeather-Demo-github
if [ $? -eq 128 ]; then
        echo "But... that failed, so we'll use a possibly out of date zip instead."
        cp PyWeather-Demo-fallback.zip PyWeather-Demo.zip
else
        # If it was successful, zip up what was cloned
        # NOTE: When we zip, we ignore .git folder, but include other hidden files and folders! 
        echo "Success! Let's zip it up!"
        cd PyWeather-Demo-github && zip -r --exclude=*.git/* ../PyWeather-Demo.zip ./* .[^.]* && cd ..
        # Save this for next time, in case we can't get the code live.
        # (This makes the maintainer's life easier)
        cp PyWeather-Demo.zip PyWeather-Demo-fallback.zip 
fi

echo "Copying application source zip to S3 bucket"
aws s3 cp PyWeather-Demo.zip s3://$BUCKET

echo "Setting up CodeCommit repo..."
STACK_NAME=$PREFIX-repo
aws cloudformation deploy --template-file repo.yaml --stack-name $STACK_NAME --parameter-overrides CodeBucketName=$BUCKET