#!/bin/sh 

sed -i "s/_MY_SECRET_/${MY_SECRET}/" ./outputs.tf

echo "Replacement of MY_SECRET done"
