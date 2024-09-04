#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

function print_usage() {
    echo ""
    echo "./process_PPK.sh -b base_input_path -r rover_input_path
              -o outpath -c file.conf [-h -v -t]"
    echo "  -b: Full path to folder containing base RINEX files v2.11"
    echo "  -r: Full path to folder containing rover RINEX files v2.11"
    echo "  -o: Full path to store outputs (POS files)"
    echo "  -c: Configuration file containing processing parameters.
                An example is given in data/PPK.conf"
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
    -b)
        base_input_path="$2"
        shift # past argument
        shift # past value
        ;;
    -r)
        rover_input_path="$2"
        shift # past argument
        shift # past value
        ;;
    -o)
        output_path="$2"
        shift
        shift
        ;;
    -c)
        config_file="$2"
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

if [[ -z ${base_input_path:-} ]]; then
    log_err "Base input path not set (-b)"
    print_usage
    exit 1
fi
if [[ -z ${rover_input_path:-} ]]; then
    log_err "Rover input path not set (-r)"
    print_usage
    exit 1
fi
if [[ -z ${output_path:-} ]]; then
    log_err "Output path not set (-o)"
    print_usage
    exit 1
fi
if [[ -z ${config_file:-} ]]; then
    log_warn "Config file not set (-c). Using data/PPK.conf by default, pass your own file
    instead if needed."
    print_usage
fi

rover_obsfiles=${rover_input_path}/\*.obs
base_obsfiles=${base_input_path}/\*.obs
base_navfiles=${base_input_path}/\*.nav
output_file=${output_path}/PPK_results_$(date '+%Y%m%d_%H%M%S').pos

echo "${base_obsfiles} ${base_navfiles}"

command="rnx2rtkp ${rover_obsfiles} ${base_obsfiles} ${base_navfiles} -o ${output_file} -k ${config_file}"

log_info "PPK processing starting... Process can take hours to days depending on the size of your dataset.\n"
log_info "${command}\n"
log_info "Once GNSS files are loaded (which can take several minutes/tens of minutes depending on your dataset), the processing quality level Q will be printed and updated at high rate. Q=1: fixed solution (the highest quality position solution). Q=2: float solution (lower quality, can be due to some noisy satellite retrievals). Q=5: single solution, meaning RTKLIB couldn't use your base files. In that case, check your base input folder.\n"

[[ $(which rnx2rtkp) ]] || (
    log_err "rnx2rtkp not found. Make sure RTKLIB is in your PATH or pass the full path to binary."
    exit 1
)
eval "${command}"
log_info "PPK processing done. Check ${output_file}.\n"
