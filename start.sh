#!/bin/bash

set -e -o pipefail

cd "$(dirname "$0")" && exec vagrant up
