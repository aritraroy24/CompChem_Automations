RESTORE=$(echo '\033[0m')
RED=$(echo '\033[00;31m')
GREEN=$(echo '\033[00;32m')
YELLOW=$(echo '\033[00;33m')
CYAN=$(echo '\033[00;36m')
MAGENTA=$(echo '\033[00;35m')
for f in $(find . -name "*.chk"); do
        filename="$(basename -s .chk $f)"
        echo "${YELLOW}${filename}_2${RESTORE} job started at $(date +%H:%M:%S)"
        g16 <$(basename -s .chk $f)_2.gjf> $(basename -s .chk $f)_2.log
        if grep -q Normal "${filename}_2.log"; then
		mkdir ~aritra/gaussian/output/success/$(basename -s .chk $f)_2
                echo "${MAGENTA}=>${RESTORE} Ongoing job${GREEN} FINISHED SUCCESSFULLY${RESTORE} at $(date +%H:%M:%S)"
                mv $(basename -s .chk $f)_2.log ~aritra/gaussian/output/success/$(basename -s .chk $f)_2
                mv $(basename -s .chk $f)_2.gjf ~aritra/gaussian/output/success/$(basename -s .chk $f)_2
                mv $(basename -s .chk $f).chk ~aritra/gaussian/output/success/$(basename -s .chk $f)_2
                echo "\n${YELLOW}${filename}_2.gjf${RESTORE}, ${YELLOW}${filename}_2.log${RESTORE} & ${YELLOW}$filename.chk${RESTORE} files have been moved into the ${CYAN}output/success/${filename}_2${RESTORE} folder\n-----------------\n"
        else
		mkdir ~aritra/gaussian/output/error/$(basename -s .chk $f)_2
                echo "${MAGENTA}=>${RESTORE} Ongoing job ${RED}TERMINATED${RESTORE} at $(date +%H:%M:%S)"
                mv $(basename -s .chk $f)_2.log ~aritra/gaussian/output/error/$(basename -s .chk $f)_2
                mv $(basename -s .chk $f)_2.gjf ~aritra/gaussian/output/error/$(basename -s .chk $f)_2
                mv $(basename -s .chk $f).chk ~aritra/gaussian/output/error/$(basename -s .chk $f)_2
                echo "\n${YELLOW}${filename}_2.gjf${RESTORE}, ${YELLOW}${filename}_2.log${RESTORE} & ${YELLOW}$filename.chk${RESTORE} files have been moved into the ${CYAN}output/error/${filename}_2${RESTORE} folder\n-----------------\n"
        fi
	sleep 0.5
done
