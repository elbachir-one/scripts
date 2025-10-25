#!/usr/bin/env bash

dir=$1
find "$dir" -type f -exec wc -l {} + | awk '{s+=$1} END {print s}'
