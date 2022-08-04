#!/usr/bin/env bash
# Deepdep.sh - Find deprecated API calls in your Java code.
#
# Copyright 2022 Paolo Perego <paolo@codiceinsicuro.it>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

VERSION="1.1"
APPNAME=`basename $0`

set -o noglob
set -e

if [ "$#" -ne 1 ]; then
    echo "usage: $APPNAME javafile"
    exit 1
fi

if [ ! -e $1 ]; then
    echo "$APPNAME: file not found"
    exit 1
fi

if [ ! -f $1 ]; then
    echo "$APPNAME: $1 is not a file"
    exit 1
fi

API_DIR_ARRAY=( "./" "$HOME/.deepdep/" "$HOME/" "/usr/share/deepdep/" )
API_FILENAME="api.txt"

for str in ${API_DIR_ARRAY[@]}; do
    API_FILE="$str$API_FILENAME"
    if [ -f $API_FILE ]; then
        break
    fi
done

if [ -z $API_FILE ]; then
    echo "$APPNAME: api.txt file not found"
    exit
fi

strings=`cat $1 | grep import | cut -f 2 -d ' ' | tr -d ';' `

for string in $strings;
do
    exact_match=`grep "\<$string\>" $API_FILE`
    if [ ! -z "$exact_match" ]; then
        if [ "$exact_match" == "$string" ]; then
            echo "$1: $string is deprecated"
        fi
    else
        # no an explicit import org.package.DeprecatedClass call
        # let's say the source file is written this way:
        # import org.package.*;
        # ...
        # DeprecatedClass foo = new DeprecatedClass()
        IFS='.' read -r -a tokens <<< "$string"
        if [ ${tokens[-1]} == "*" ]; then
            to_search=`echo $string | tr -d "*" | sed 's/.$//'`
            back_strings=`cat $API_FILE | grep $to_search | tr -d ';'`
            for back_string in $back_strings;
            do
                # 1. tokenize the FQDN of the deprecated API
                # 2. last token is the deprecated Class
                # 3. grep the source file for the deprecated class only
                IFS='.' read -r -a deprecated_tokens <<< "$back_string"
                deprecated_class=${deprecated_tokens[-1]}
                found=`grep $deprecated_class $1`
                if [ ! -z $found ]; then
                    echo "$1: $string is deprecated"
                fi
            done
        fi
    fi
done
set +o noglob
