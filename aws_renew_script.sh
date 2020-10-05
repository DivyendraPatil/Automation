#!/bin/bash
set -e

echo "Enter aws IAM user-name (not email)"
read user_name

echo "
This script makes an assumptions that
you have generated aws credentials at least once.
"

# Install jq if not installed
check_jq=$(command -v jq | wc -l)

if [ "$check_jq" -ne "1" ]; then
	brew install jq
fi

# Check for valid amount of keys
aws_output=$(aws iam list-access-keys --user-name $user_name)
count_keys=$(echo $aws_output | jq . | grep AccessKeyId | wc -l | xargs)

if [ "$count_keys" -eq "1" ]; then
    echo -e "You have one key. Proceeding..."
elif [[ $count_keys -eq "2" ]]; then
	
	two_keys=$(echo $aws_output | jq '.AccessKeyMetadata | .[] | .AccessKeyId' | xargs)
	for word in $two_keys
	do
		echo "Please press q when you see \"END\""
		sleep 2
	    aws iam delete-access-key --access-key-id $word --user-name $user_name
	    break
	done
else
	echo "You have no aws credentials. You need to create some.
	You can do so by visiting: console.aws.amazon.com/iam/home?region=us-east-1#/security_credentials"
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

echo -e "
Success!
Your new AWS AccessKeyId is $get_new_aws_access_key_id
Your new AWS SecretAccessKey is $get_new_aws_secret_access_key

To delete your old key, please run the following command:
aws iam delete-access-key --access-key-id $get_accessKey_id --user-name $user_name
"

# divyendra.patil.personal