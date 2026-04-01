# Update placeholders in Terraform files

## Motivation

When using `Terraform`, most secrets are usually passed as environment variables to when using various providers. There are times however, when you want to inject secrets in resource parameters. Environment variables do not work any more in such scenarios. So how to avoid putting your secrets in code?

## Prerequisites

A Linux or MacOS machine for local development. If you are running Windows, you first need to set up the *Windows Subsystem for Linux (WSL)* environment.

You need `docker cli` on your machine for testing purposes, and/or on the machines that run your pipeline.
You can verify this by running the following command:
```sh
docker --version
```

Optional environment variable for your secret:
- MY_SECRET

## Implementation

First of all, let's create an output where we want to avoid using secrets in code. For example, if you have something like:
```sh
output "myOutput" {
  value = "My special secret is: mySpecialSecretValue"
}
```
, you want to somehow avoid using the value of your secret in code.

What you want to have is something like:
```sh
output "myOutput" {
  value = "My special secret is: _MY_SECRET_"
}
```
But now we must update the `_MY_SECRET_` placeholder.

To do this, you can write a simple script to do that:
```sh
#!/bin/sh 

sed -i "s/_MY_SECRET_/${MY_SECRET}/" ./outputs.tf

echo "Replacement of MY_SECRET done"
```
Now you only want to provide the `MY_SECRET` environment variable to the container running your code, and call the previous script.

If your initial `docker compose` file was written as:
```sh
services:
  mainservice:
    image: terraform-update-placeholders
    network_mode: host
    working_dir: /infrastructure
    entrypoint: ["sh", "-c"]
    command: ["cd terraform && terraform init && terraform validate && terraform apply -auto-approve"]
```
, you now have to add the `MY_SECRET` environment variable and add the script call:
```sh
services:
  mainservice:
    image: terraform-update-placeholders
    network_mode: host
    working_dir: /infrastructure
    environment:
      #- MY_SECRET=${MY_SECRET}
      - MY_SECRET=mySpecialSecretValue
    entrypoint: ["sh", "-c"]
    command: ["cd terraform && sh updateVariables.sh && terraform init && terraform validate && terraform apply -auto-approve"]
```
If you already prepared a `MY_SECRET` environment variable, use the commented line `- MY_SECRET=${MY_SECRET}` instead.

## Usage

Just run the necessary docker commands:
```sh
docker build -f docker/dockerfile -t terraform-update-placeholders .
docker compose -f docker/docker-compose.yml run --rm mainservice
```
and observe the output. The `_MY_SECRET_` placeholder should be updated with your desired value.
