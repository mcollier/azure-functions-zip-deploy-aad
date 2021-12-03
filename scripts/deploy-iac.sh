#!/bin/bash

RESOURCE_GROUP_NAME="rg-azure-function-zip-deploy"

az deployment sub create \
    --template-file ../iac/main.bicep \
    --parameter resourceGroupName="$RESOURCE_GROUP_NAME" \
    --location eastus \
    --confirm-with-what-if