# convert UBX to RINEX 2.11
./convert_GNSS.sh -i /my/path/rover -e ubx -rv 2.11
./convert_GNSS.sh -i /my/path/base -e ubx -rv 2.11

# process rover data with base in Post-Processed Kinematics (PPK)
./process_PPK.sh -p /my/path/RTKLIB\
		 -b /my/path/base\
		 -r /my/path/rover\
		 -o /my/path/PPK_results\
		 -c /my/path/rtklib-cli/data/PPK.conf
