#!/bin/bash

grep "text" ./*.js | awk -F'"text" :' '{print $2}' | sed -e 's/-&gt;/==>/g' -e 's/^ "//g' -e 's/",$//g' -e 's/\\u2013/-/g' -e 's/\\\//\//g' | sort
