#!/bin/bash

HTTP_STR="HTTP/1.1"

function Header {
        local CRLF=$'\r\n'

        if [ $# -ge 2 ]
        then
                local pair="$1: $2$CRLF"
                shift 2
                local rest=$(Header $*)
                
                echo "$pair$rest"
        fi
}

function Query {
        if [ $# -ge 2 ]
        then
                local pair="?$1=$2&"
                shift 2
                local rest=$(Query $*)
                rest=${rest:1:-1}

                echo "$pair$rest"
        fi
}

function Post {
        local query=$(Query $*)
        
        echo ${query:1}
}

function strlen {
        echo ${#1}
}

function ContentLength {
        local len=$(strlen "$1")
        echo "Content-Length: $len"
}

function StatusCode {
        local code="$1"

        echo -n "$HTTP_STR $code "
        case "$code" in
        200) echo "OK"
        400) echo "Bad Request"
        403) echo "Forbidden"
        404) echo "Not Found"
        503) echo "Service Not Available"
        esac
}

function example_request {
        local query=$(Query \
                version 1.0.1 \
                a       login \
        )
        local post=$(Post \
                username admin \
                password admin888 \
        )
        local headers=$(Header \
                Content-Type    "application/x-www-form-urlencoded" \
                User-Agent      "bash shell" \
        )
        local content_length=$(ContentLength "$post")

        cat << EOF
GET /router${query} HTTP/1.1
$headers
$content_length

$post
EOF
}
