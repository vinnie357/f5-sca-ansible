#!/usr/bin/bash
buckets=$(aws s3api list-buckets --query 'Buckets[?contains(Name, `mazza-sca-test`) == `true`].Name' | awk '{ print $0}')
buckets=$(aws s3api list-buckets --query 'Buckets[?contains(Name, `mazza-sca-test`) == `true`].Name' | awk '{ print $0}')
aws s3api delete-buckets mazza-sca-test-f5bigip1-blnrj69i48a5-s3bucket-89gq1cevie2a

aws s3api delete-bucket --bucket my-bucket --region us-east-1