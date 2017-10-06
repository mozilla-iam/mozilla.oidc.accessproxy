#!/bin/bash

STACK_NAME="OIDCAccessProxy"
STACK_NAME_ROLE="${STACK_NAME}-role"
STACK_ENV="dev"
SSH_KEYS="infosec-us-west-2-keys"
CREDSTASH_REGION="us-west-2"
export AWS_DEFAULT_PROFILE="infosec-dev-admin"
export AWS_DEFAULT_REGION="us-west-2"

# Need to delete some stacks ?
# aws cloudformation delete-stack --stack-name ${STACK_NAME}
# aws cloudformation delete-stack --stack-name ${STACK_NAME_ROLE}

function die() {
    echo "$1"
    exit $2
}

function create_check_wait_stack() {
    # Check if stack exists, if not, create it. Wait til all done.
    local cur_stack=$1 ; shift
    local stack_file=$1 ; shift
    aws cloudformation describe-stack-resources --stack-name ${cur_stack} > /dev/null 2>&1 || {
        echo Creating ${cur_stack} stack...
        aws cloudformation create-stack --stack-name ${cur_stack} --capabilities CAPABILITY_NAMED_IAM \
            --template-body ${stack_file} \
            $* \
            || die "Create stack failed" $?
        aws cloudformation wait stack-create-complete --stack-name ${cur_stack} \
            || die "Wait for stack complete failed" $?
    }
    aws cloudformation wait stack-exists --stack-name ${STACK_NAME_ROLE} || die "Wait stack exists failed" $?
}

create_check_wait_stack ${STACK_NAME_ROLE} "file://roles.yml"
create_check_wait_stack ${STACK_NAME} "us-west-2.yml" --parameters \
    ParameterKey=SSHKeyName,ParameterValue=${SSH_KEYS} \
    ParameterKey=EnvType,ParameterValue=${STACK_ENV} \
    ParameterKey=RoleName,ParameterValue=${STACK_NAME_ROLE}

local credstash_key_id="$(aws --region ${CREDSTASH_REGION} kms list-aliases --query "Aliases[?AliasName=='alias/credstash'].TargetKeyId | [0]" --output text)"
local role_arn="$(aws iam get-role --role-name ${STACK_NAME_ROLE} --query Role.Arn --output text)"
local constraints="EncryptionContextEquals={app=${STACK_NAME}}"

# Grant the IAM role permissions to decrypt
aws kms create-grant --key-id $credstash_key_id --grantee-principal $role_arn --operations "Decrypt" \
    --constraints $constraints --name ${STACK_NAME} \
    || exit $?
