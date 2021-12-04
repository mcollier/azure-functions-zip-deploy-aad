#!/bin/bash -v

SCOPE='/subscriptions/[SUBSCRIPTION-ID]/resourceGroups/rg-azure-function-zip-deploy/providers/Microsoft.Web/sites/[FUNCTION-APP-NAME]'
SERVICE_PRINCIPAL_NAME='azfuncdeploy-sp'

az ad sp create-for-rbac \
    --name "$SERVICE_PRINCIPAL_NAME" \
    --role "Website Contributor" \
    --scope "$SCOPE"

# Delete the service principal with `az ad sp delete -id [APP-ID]`