#!/bin/bash

source ./parser.sh

read_first
read_headers

echo "HTTP/1.1 200 OK"
echo "Content-Length: 1000"
echo
echo "_METHOD: $_METHOD"
echo "_PATH: $_PATH"
echo "_QUERY: $_QUERY"
echo
echo "_HEAD:"
echo "${!_HEAD[@]}"
echo "${_HEAD[@]}"
echo
echo "_GET:"
echo "${!_GET[@]}"
echo "${_GET[@]}"
echo 
