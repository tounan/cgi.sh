#!/bin/bash

function trim_crlf {
        if [ $# -eq 1 ]
        then
                echo "$1" | sed -z 's/\r\n$//'
        else
                sed -z 's/\r\n$//'
        fi
}

function parse_query {
        local query_string="$1"
        declare -A _GET

        local query_lines=$(echo "$query_string" | tr "&" "\n")
        while true
        do
                local pair
                read pair
                pair=$(echo "$pair" | sed -z 's/\n//')
                if [ -n "$pair" ]
                then
                        local key=$(echo "$pair" | cut -d "=" -f 1)
                        local value=$(echo "$pair" | cut -d "=" -f 2-)

                        echo "$key => $value"
                        _GET[$key]="$value"
                else
                        break
                fi
        done <<< "$query_lines"
}

function parse_body {
        local query_string="$1"
        declare -A _POST

        local query_lines=$(echo "$query_string" | tr "&" "\n")
        while true
        do
                local pair
                read pair
                pair=$(echo "$pair" | sed -z 's/\n//')
                if [ -n "$pair" ]
                then
                        local key=$(echo "$pair" | cut -d "=" -f 1)
                        local value=$(echo "$pair" | cut -d "=" -f 2-)

                        echo "$key => $value"
                        _POST[$key]="$value"
                else
                        break
                fi
        done <<< "$query_lines"
}

function parse_first {
        local first=$(trim_crlf "$1" | tr -s " ")
        local method=$(echo "$first" | cut -d " " -f 1)
        local uri=$(echo "$first" | cut -d " " -f 2)
        local sig=$(echo "$first" | cut -d " " -f 3)

        if [[ "$uri" == *"?"* ]]
        then
                local path=$(echo "$uri" | cut -d "?" -f 1)
                local query=$(echo "$uri" | cut -d "?" -f 2-)
        else
                local path="$uri"
                local query=""
        fi
        parse_query "$query"

        echo "method: $method"
        echo "path: $path"
        echo "query: $query"
}

function parse_header {
        local header_line="$1"
        local name=$(echo "$header_line" | cut -d ":" -f 1)
        # remove leading space
        local value=$(echo "$header_line" | cut -d ":" -f 2- | sed 's/^ //')

        echo "header $name => $value"
}

read first_line
parse_first "$first_line"
unset first_line

# reading the request
while true
do
        read header_line
        header_line=$(trim_crlf "$header_line")

        if [ -n "$header_line" ]
        then
                parse_header "$header_line"
        else
                break
        fi
done
unset header_line

# pass the rest to application