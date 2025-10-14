#!/usr/bin/env bash

# Print any name

name="${1:-anyname}"

figlet -c -f "ANSI Shadow.flf" "$name" -t | lolcat
