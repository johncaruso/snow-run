#!/bin/bash
export SNOW_DIR=~/.snow-run
export SNOW_TMP_DIR=$SNOW_DIR/tmp/$snow_instance
export SNOW_COOKIE_FILE=$SNOW_TMP_DIR/cookies.txt
mkdir -p $SNOW_TMP_DIR

export SNOW_INCLUDE_DIR=$(dirname ${BASH_SOURCE})
export SNOW_BIN_DIR=$SNOW_INCLUDE_DIR/../bin
export SNOW_JS_DIR=$SNOW_INCLUDE_DIR/../js

function ensure_instance_set() {
    if [[ -z ${snow_instance} ]];
    then
        echo Set snow_instance ENV variable to something like dev123.service-now.com first! >&2
        exit 1
    fi
}

function check_arguments() {
    # if less than one arguments supplied, display usage 
    if [[  $x -lt $1 ]]
    then 
        display_usage
        exit 1
    fi
}

function tabularize {
    max_len=$(tput cols)
    column -t -s $'\t' | cut -c -$max_len
}


function join_by { local IFS="$1"; shift; echo "$*"; }

function get_script {
    script_name=$1
    shift
    args="$@"
    args=$(join_by , $args)

    echo_function="
    function \$echo() {
        var \$arg = arguments;
        switch (arguments.length) {
            case 0:
                gs.print("");
                break;
            case 1:
                gs.print(arguments['0']);
                break;
            default:
                gs.print(Object.keys(\$arg).map(function (key) {return \$arg[key];}).join('\t').replace('\\\r', '').replace('\\\n', ' '));
        }
        
    }
    "
    script=$(cat $SNOW_JS_DIR/$script_name)
    if [[ -z $show_script_help ]]
    then
        echo -e "$echo_function\n$script\n\$exec($args)"
    else
        echo -e "$echo_function\n$script\n\$help()"
    fi
}
function run_script {
    # Execute script file using arguments given
    get_script "$@" | $SNOW_BIN_DIR/snow-run.sh -
}