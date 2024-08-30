#!/usr/bin/env bash
# Example of PPK processing with one single base and several rovers running simultaneously

# set -o errexit
# set -o nounset
# set -o pipefail

red='\033[0;31m'
orange='\033[0;33m'
green='\033[0;32m'
nc='\033[0m' # No Color
log_info() { echo -e "${green}[$(date --iso-8601=seconds)] [INFO] ${*}${nc}"; }
log_warn() { echo -e "${orange}[$(date --iso-8601=seconds)] [WARN] ${*}${nc}"; }
log_err() { echo -e "${red}[$(date --iso-8601=seconds)] [ERR] ${*}${nc}" 1>&2; }

rinex_conversion=true

base_path="/path/to/base" 

# either write the paths directly
rover_paths=("/path/to/rover1" "/path/to/rover2" "/path/to/rover3")

# or list them from a folder
rover_folder_path="/path/to/rovers"
rover_paths=$(find "${rover_folder_path}"/*rover* -type d)

results_path="/path/to/results"
config_path="/path/to/PPK.conf"

if [ "${rinex_conversion}" = true ]; then
    ./convert_RINEX.sh -i ${base_path} -vi 3 -vo 2.11
fi	

for rover_path in ${rover_paths[@]}; do

    if [ "${rinex_conversion}" = true ]; then
	./convert_RINEX.sh -i ${rover_path} -vi 3 -vo 2.11
    fi	
	
    ./process_PPK.sh -b ${base_path} -r ${rover_path} -o ${results_path} -c ${config_path}
done
