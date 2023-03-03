RESTORE=$(echo '\033[0m')
RED=$(echo '\033[00;31m')
GREEN=$(echo '\033[00;32m')
YELLOW=$(echo '\033[00;33m')
CYAN=$(echo '\033[00;36m')
MAGENTA=$(echo '\033[00;35m')
for f in $(find . -name "*.gjf"); do
        filename="$(basename -s .gjf $f)"
        echo "${YELLOW}$filename${RESTORE} job started at $(date +%H:%M:%S)"
        g16 <$filename.gjf> $filename.log
        formchk $filename.chk $filename.fchk
        if grep -q Normal "$filename.log"; then
                if grep -qi freq "$filename.gjf"; then
                        ZPE_String=$(grep "Zero-point correction" $filename.log)
                        ZPE=$(echo $ZPE_String | grep -oE "\-?[0-9]+(\.[0-9]+)?" | sed -n '1p')
                        delH_String=$(grep "Thermal correction to Enthalpy" $filename.log)
                        delH=$(echo $delH_String | tr -cd '[:digit:].-')
                        delG_String=$(grep "Thermal correction to Gibbs Free Energy" $filename.log)
                        delG=$(echo $delG_String | tr -cd '[:digit:].-')
                        touch $filename"_result.txt"
                        printf "\n\n========== RESULTS ==========\nZPE Correction = ${ZPE}\nEnthalpy Correction = ${delH}\nGibbs Correction = ${delG}\n\n"
                        printf "========== RESULTS ==========\nZPE Correction = ${ZPE}\nEnthalpy Correction = ${delH}\nGibbs Correction = ${delG}" >> $filename"_result.txt"
                        last_string_line=$(grep -n "Standard orientation:" $filename.log | tail -1)
                        line_number=$(echo $last_string_line | cut -d':' -f1)
                        start_line_number=$((line_number+5))
                        last_line=$(grep -n "\------------------" $filename.log | awk -F':' -v start=$start_line_number '$1>=start{print;exit}')
                        line_number=$(echo $last_line | cut -d':' -f1)
                        last_line_number=$((line_number-1))
                        unordered_coordinates=$(sed -n "$start_line_number,$last_line_number p" $filename.log)
                        required_data=$(echo "$unordered_coordinates" | awk '{print $2, $4, $5, $6}')
                        echo "$required_data" | while read line; do
                            col1=$(echo "$line" | awk '{printf("%2d", $1)}')    
                            col2=$(echo "$line" | awk '{if ($2>=0) printf("   %f", $2); else printf("  %f", $2)}')
                            col3=$(echo "$line" | awk '{if ($3>=0) printf("   %f", $3); else printf("  %f", $3)}')
                            col4=$(echo "$line" | awk '{if ($4>=0) printf("   %f", $4); else printf("  %f", $4)}')    
                            formatted_line="$col1 $col2 $col3 $col4"    
                            echo "$formatted_line" >> $filename"_coordinates.txt"
                        done
                else
                        Energy_String=$(grep "SCF Done" $filename.log)
                        Energy=$(echo $Energy_String | grep -oE "\-?[0-9]+(\.[0-9]+)?" | sed -n '2p')
                        touch $filename"_result.txt"
                        printf "\n\n========== RESULTS ==========\nTotal Energy = ${Energy}\n\n"
                        printf "========== RESULTS ==========\nTotal Energy = ${Energy}" >> $filename"_result.txt"
                fi
                mkdir ~aritra/gaussian/output/success/$(basename -s .gjf $f)
                echo "${MAGENTA}=>${RESTORE} Ongoing job${GREEN} FINISHED SUCCESSFULLY${RESTORE} at $(date +%H:%M:%S)"
                if grep -qi freq "$filename.gjf"; then
                        mv $filename"_coordinates.txt" ~aritra/gaussian/output/success/$filename
                        mv $filename.log ~aritra/gaussian/output/success/$filename
                        mv $filename.chk ~aritra/gaussian/output/success/$filename
                        mv $filename.gjf ~aritra/gaussian/output/success/$filename
                        mv $filename.fchk ~aritra/gaussian/output/success/$filename
                        mv $filename"_result.txt" ~aritra/gaussian/output/success/$filename
                        echo "\n${YELLOW}$filename.gjf${RESTORE}, ${YELLOW}$filename.log${RESTORE}, ${YELLOW}$filename.chk${RESTORE}, ${YELLOW}$filename.fchk${RESTORE}, ${YELLOW}${filename}_result.txt${RESTORE} & ${YELLOW}${filename}_coordinates.txt${RESTORE} files have been moved into the ${CYAN}output/success/$filename${RESTORE} folder\n-----------------\n"
                else
                        mv $filename.log ~aritra/gaussian/output/success/$filename
                        mv $filename.chk ~aritra/gaussian/output/success/$filename
                        mv $filename.gjf ~aritra/gaussian/output/success/$filename
                        mv $filename.fchk ~aritra/gaussian/output/success/$filename
                        mv $filename"_result.txt" ~aritra/gaussian/output/success/$filename
                        echo "\n${YELLOW}$filename.gjf${RESTORE}, ${YELLOW}$filename.log${RESTORE}, ${YELLOW}$filename.chk${RESTORE}, ${YELLOW}$filename.fchk${RESTORE} & ${YELLOW}${filename}_result.txt${RESTORE} files have been moved into the ${CYAN}output/success/$filename${RESTORE} folder\n-----------------\n"
                fi
        else
                if grep -qi formbx "$filename.log"; then
                        last_string_line=$(grep -n "Standard orientation:" $filename.log | tail -1)
                        line_number=$(echo $last_string_line | cut -d':' -f1)
                        start_line_number=$((line_number+5))
                        last_line=$(grep -n "\------------------" $filename.log | awk -F':' -v 
                        start=$start_line_number '$1>=start{print;exit}')
                        line_number=$(echo $last_line | cut -d':' -f1)
                        last_line_number=$((line_number-1))
                        unordered_coordinates=$(sed -n "$start_line_number,$last_line_number p" 
                        $filename.log)
                        required_data=$(echo "$unordered_coordinates" | awk '{print $2, $4, $5, $6}
                        ')
                        echo "$required_data" | while read line; do
                        col1=$(echo "$line" | awk '{printf("%2d", $1)}')    
                        col2=$(echo "$line" | awk '{if ($2>=0) printf("   %f", $2); else printf
                        ("  %f", $2)}')
                        col3=$(echo "$line" | awk '{if ($3>=0) printf("   %f", $3); else printf
                        ("  %f", $3)}')
                        col4=$(echo "$line" | awk '{if ($4>=0) printf("   %f", $4); else printf
                        ("  %f", $4)}')    
                        formatted_line="$col1 $col2 $col3 $col4"    
                        echo "$formatted_line" >> $filename"_coordinates.txt"
                        done
                        mkdir ~aritra/gaussian/output/error/$(basename -s .gjf $f)
                        echo "${MAGENTA}=>${RESTORE} Ongoing job ${RED}TERMINATED${RESTORE} at $(date +%H:%M:%S)"
                        mv $filename.log ~aritra/gaussian/output/error/$filename
                        mv $filename.chk ~aritra/gaussian/output/error/$filename
                        mv $filename.gjf ~aritra/gaussian/output/error/$filename
                        mv $filename.fchk ~aritra/gaussian/output/error/$filename
                        mv $filename"_coordinates.txt" ~aritra/gaussian/output/error/$filename
                        echo "\n${YELLOW}$filename.gjf${RESTORE}, ${YELLOW}$filename.log${RESTORE}, ${YELLOW}$filename.chk${RESTORE}, ${YELLOW}$filename.fchk${RESTORE}, ${YELLOW}${filename}_result.txt${RESTORE} & ${YELLOW}${filename}_coordinates.txt${RESTORE} files have been moved into the ${CYAN}output/error/$filename${RESTORE} folder\n-----------------\n"
                else
                        mkdir ~aritra/gaussian/output/error/$(basename -s .gjf $f)
                        echo "${MAGENTA}=>${RESTORE} Ongoing job ${RED}TERMINATED${RESTORE} at $(date +%H:%M:%S)"
                        mv $filename.log ~aritra/gaussian/output/error/$filename
                        mv $filename.chk ~aritra/gaussian/output/error/$filename
                        mv $filename.gjf ~aritra/gaussian/output/error/$filename
                        mv $filename.fchk ~aritra/gaussian/output/error/$filename
                        echo "\n${YELLOW}$filename.gjf${RESTORE}, ${YELLOW}$filename.log${RESTORE}, ${YELLOW}$filename.chk${RESTORE}, ${YELLOW}$filename.fchk${RESTORE} & ${YELLOW}${filename}_result.txt${RESTORE} files have been moved into the ${CYAN}output/error/$filename${RESTORE} folder\n-----------------\n"
                fi
        fi
        sleep 10
done
