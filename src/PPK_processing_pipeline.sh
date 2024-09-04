# convert UBX to RINEX 2.11
./convert_GNSS.sh -i /scratch3/armin/work_adri/rover -e ubx -rv 2.11
./convert_GNSS.sh -i /scratch3/armin/work_adri/base -e ubx -rv 2.11

# process rover data with base in Post-Processed Kinematics (PPK)
./process_PPK.sh -b /scratch3/armin/work_adri/base\
		 -r /scratch3/armin/work_adri/rover\
		 -o /scratch3/armin/work_adri/PPK_results/\
		 -c /home/guschti/COEBELI/rtklib-cli/data/PPK.conf


