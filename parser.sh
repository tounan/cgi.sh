#!/bin/bash

# log to stderr
err() { printf "%s\n" "$*" >&2; }

# deletes only trailing CRLF
function trim_crlf {
        if [ $# -eq 1 ]
        then
                echo "$1" | sed -z 's/\r\n$//'
        else
                sed -z 's/\r\n$//'
        fi
}

# save _GET from query string
function parse_query {
        local query_string="$1"
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
                        err "\$_GET[$key] = $value"
                        _GET[$key]="$value"
                else
                        break
                fi
        done <<< "$query_lines"
}

# save _POST from body
function read_body {
        local query_string="$1"
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
                        err "\$_POST[$key] = $value"
                        _POST[$key]="$value"
                else
                        break
                fi
        done <<< "$query_lines"
}

# save _METHOD _PATH _QUERY
# and parse _QUERY
function read_first {
        read first_line
        local first=$(trim_crlf "$first_line" | tr -s " ")
        unset first_line
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

        err "M=$method P=$path Q=$query"
        _METHOD="$method"
        _PATH="$path"
        _QUERY="$query"
        
        parse_query "$query"
}

# save _HEAD from headers
function read_headers {
        while true
        do
                read header_line
                header_line=$(trim_crlf "$header_line")

                if [ -n "$header_line" ]
                then
                        local name=$(echo "$header_line" | cut -d ":" -f 1)
                        # remove leading whitespace
                        local value=$(echo "$header_line" | cut -d ":" -f 2- | sed 's/^ //')
                        err "\$_HEAD[$name] = $value"
                        _HEAD[$name]="$value"
                else
                        break
                fi
        done
        unset header_line
}

declare -A _HEAD
declare -A _GET
declare -A _POST
