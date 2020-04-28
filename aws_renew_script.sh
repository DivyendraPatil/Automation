#!/bin/bash
set -e

echo "Enter aws IAM user-name (not email)"
read user_name

echo "
This script takes a few assumtions

1] That you are not going to read this

2] That your aws credential file, located at
/Users/$USER/.aws/credentials, is in format:

[default]
aws_access_key_id = something
aws_secret_access_key = something

3] That you have jq installed on your system.
If not, please run \`brew install jq\` in your terminal.

4] You do not have 2 keys already on your aws account.
Since a AWS IAM user is allowed only 2 keys, you wont be able to run this script. 
"

echo "Enter \"yes\" to continue, Anything else to exit"
read answer

if [ "$answer" == "yes" ]; then
    echo -e "Proceeding..."
else
    exit 0
fi

aws_output=$(aws iam list-access-keys --user-name $user_name)

# Check for valid amount of keys
count_keys=$(echo $aws_output | jq . | grep AccessKeyId | wc -l | xargs)

if [ "$count_keys" -eq "1" ]; then
    echo -e "You have just one key. Thats good. Sit back, relax, have a beer or two."
else
	echo -e "
You have 2 or No keys. Delete old/unused keys for renewal. You can do so by visiting:
console.aws.amazon.com/iam/home?region=us-east-1#/security_credentials"
    exit 0
fi

# Capture old key in variable
get_accessKey_id=$(echo $aws_output | jq '.AccessKeyMetadata[].AccessKeyId' | xargs)

# Create new keys
create_new_keys=$(aws iam create-access-key --user-name $user_name)

# Capture new keys in variable
get_new_aws_access_key_id=$(echo $create_new_keys | jq '.AccessKey.AccessKeyId' | xargs)
get_new_aws_secret_access_key=$(echo $create_new_keys | jq '.AccessKey.SecretAccessKey' | xargs)

# Write file to location
cat > /Users/$USER/.aws/credentials <<- EOM
[default]
aws_access_key_id = $get_new_aws_access_key_id
aws_secret_access_key = $get_new_aws_secret_access_key
EOM

echo -e "\n
Your new AWS AccessKeyId is $get_new_aws_access_key_id
Your new AWS SecretAccessKey is $get_new_aws_secret_access_key

Success!

To delete your old key, please run the following command:
aws iam delete-access-key --access-key-id $get_accessKey_id --user-name $user_name
"

# divyendra.patil.personal