#!/usr/bin/env bash

set -euxo pipefail

while read f
do
    gh workflow run package.yml -f name=$f
done < packages.txt
