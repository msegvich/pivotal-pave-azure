#!/bin/bash

set -e # exit immediately if a simple command exits with a non-zero status
set -u # report the usage of uninitialized variables
set -o pipefail

PROGNAME=$(basename $0)
CWD=$PWD
TERRAFORM_OUTPUT_FILE=$CWD/azure-tanzu-automation/terraform-output.json
TERRAFORM_INPUT_FILE=$CWD/tanzu.tfplan # https://github.com/pivotal/paving-pks.git
OS=$(uname)
export PATH=.:$PATH
function abort()
{
    echo >&2 '
***************
*** ABORTED ***
***************
'
    echo "An error occurred. Exiting..." >&2
		exit 1
}
function get_terrform()
{
	if [ $OS == "Linux" ]; then
		TERRAFORM_FILE="https://releases.hashicorp.com/terraform/0.13.3/terraform_0.13.3_linux_amd64.zip"
	elif [ $OS == "Darwin" ]; then
		TERRAFORM_FILE="https://releases.hashicorp.com/terraform/0.13.3/terraform_0.13.3_darwin_amd64.zip"
	fi
	WGET_CMD="wget -q $TERRAFORM_FILE -O $CWD/terraform.zip"
	if `$WGET_CMD`; then
		unzip -o $CWD/terraform.zip && chmod 755 $CWD/terraform
	fi
}
trap 'abort' 0
echo "Staring to unpave Azure tanzu installation"

if [ -f "$TERRAFORM_INPUT_FILE" ]; then
	get_terrform
#  cd azure-tanzu-automation
#  ./delete-pks.sh
#  cd ..
  $CWD/terraform destroy -auto-approve
  rm -rf $CWD/tanzu.tfplan $CWD/jq $CWD/terraform.zip $CWD/terraform $CWD/terraform.tfstate $CWD/terraform.tfstate.backup $CWD/.terraform
fi
trap : 0

echo >&2 '
************
*** DONE ***
************
'
