#!/bin/bash

APP_NAME='[FUNCTION-APP-NAME]'
SERVICE_PRINCIPAL_NAME='[SERVICE-PRINCIPAL-APP-ID]'
SERVICE_PRINCIPAL_PASSWORD='[SERVICE-PRINCIPAL-PASSWORD]'
SERVICE_PRINCIPAL_TENANT_ID='[SERVICE-PRINCIPAL-TENANT-ID]'

dotnet publish --configuration Release "../src/MyFunctionApp"

(cd ../src/MyFunctionApp/bin/Release/netcoreapp3.1/publish/ && zip -r ../../../../code.zip .)

az login --service-principal \
    --username "$SERVICE_PRINCIPAL_NAME" \
    --password "$SERVICE_PRINCIPAL_PASSWORD" \
    --tenant "$SERVICE_PRINCIPAL_TENANT_ID"

TOKEN=$(az account get-access-token -o tsv --query accessToken)

curl -X POST \
    --data-binary @../src/MyFunctionApp/code.zip \
    -H "Authorization: Bearer $TOKEN" \
    "https://${APP_NAME}.scm.azurewebsites.net/api/zipdeploy"

az logout
