#! /bin/sh

fw_source "parse-args.sh" "sh/fatal.sh"

parse_args () \
  {
    local _name

    local cmd="$1"
    shift

    while test ! -z "$1"
      do
        case "$1" in
          --help)
            help=1
            shift
          ;;
          --trace)
            set -x
            FW_TRACE=1
            export FW_TRACE
            shift
          ;;
          --*=*)
            _name=`echo "$1" | perl -ne 'm%^--([^=]*)=% && print $1'`
            _value=`echo "$1" | perl -ne 'm%^--[^=]*=(.*)% && print $1'`
            eval ${_name}=\"\${_value}\"
            shift
          ;;
          --*)
            _name=`echo "$1" | perl -pe 's%^--%%;'`
            shift
            eval ${_name}=\"\$1\"
            shift
          ;;
          *)
            echo "$cmd: unrecognized option $1" 1>&2
            fatal "$cmd"
          ;;
        esac
      done
  }
