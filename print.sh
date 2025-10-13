#!/bin/bash

# Check if a name is provided, otherwise default to 'anyname'
name="${1:-anyname}"

# Generate the figlet banner with lolcat colors
figlet -c -f "ANSI Shadow.flf" "$name" -t | lolcat
