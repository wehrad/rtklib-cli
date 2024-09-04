#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

function print_usage() {
    echo ""
    echo "./convert_RINEX.sh -i files -vi old_rinex_version -vo new_rinex_version [-h -v -t]"
    echo "  -i: Full path to files listed with wildcard"
    echo "  -vi: RINEX version of inputs" # in the future can be directly parsed from header
    echo "  -vo: Desired RINEX version"
    echo "  -v: Print verbose messages during processing"
    echo "  -t: Print timing messages during processing"
    echo "  -h: print this help"
    echo ""
}

red='\033[0;31m'
orange='\033[0;33m'
green='\033[0;32m'
nc='\033[0m' # No Color
log_info() { echo -e "${green}[$(date --iso-8601=seconds)] [INFO] ${@}${nc}"; }
log_warn() { echo -e "${orange}[$(date --iso-8601=seconds)] [WARN] ${@}${nc}"; }
log_err() { echo -e "${red}[$(date --iso-8601=seconds)] [ERR] ${@}${nc}" 1>&2; }

debug() { if [[ ${debug:-} == 1 ]]; then
    log_warn "debug:"
    echo $@
fi; }

readonly t_0=$(date +%s)
declare t_last=$(date +%s)
timing() {
    if [[ ${timing:-} ]]; then
        log_info "Timing..."
        local t_now=$(date +%s)
        echo "    Time since start:" $((${t_now} - ${t_0}))"s"
        echo "    Time since last:" $((${t_now} - ${t_last}))"s"
        t_last=$(date +%s)
    fi
}

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
    -h | --help)
        print_usage
        exit 1
        ;;
    -i)
        files="$2"
        shift # past argument
        shift # past value
        ;;
    -vi)
        input_rinex_version="$2"
        shift # past argument
        shift # past value
        ;;
    -vo)
        output_rinex_version="$2"
        shift
        shift
        ;;
    -v | --verbose)
        verbose=1
        set -o xtrace
        shift
        ;;
    -t)
        timing=1
        shift
        ;;
    *) # unknown option
        log_err "An unkown option was passed."
        print_usage
        exit 1
        shift
        ;;
    esac
done

if [[ -z ${files:-} ]]; then
    log_err "Path to files not set (-i)"
    print_usage
    exit 1
fi
if [[ -z ${input_rinex_version:-} ]]; then
    log_err "Current version of RINEX files not set (-vi)"
    print_usage
    exit 1
fi
if [[ -z ${output_rinex_version:-} ]]; then
    log_err "Desired version of RINEX files not set (-vo)"
    print_usage
    exit 1
fi

file_list=eval "${files}"

for file in ${file_list[@]}; do
    command="convbin -od -os -oi -ot -ol -f ${output_rinex_version} -v ${input_rinex_version} ${file}"
fi
    
log_info "RINEX conversion starting...\n"
log_info "${command}\n"

[[ $(which convbin) ]] || (
    log_err "convbin not found. Make sure RTKLIB is in your PATH or pass the full path to binary."
    exit 1
)
eval "${command}"
log_info "RINEX conversion done. Check ${files}.\n"
