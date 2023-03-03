RESTORE=$(echo '\033[0m')
RED=$(echo '\033[00;31m')
GREEN=$(echo '\033[00;32m')
YELLOW=$(echo '\033[00;33m')
CYAN=$(echo '\033[00;36m')
MAGENTA=$(echo '\033[00;35m')
for f in $(find . -name "*.chk"); do
        filename="$(basename -s .chk $f)"
        echo "${YELLOW}${filename}_3${RESTORE} job started at $(date +%H:%M:%S)"
        g16 <$(basename -s .chk $f)_3.gjf> $(basename -s .chk $f)_3.log
        formchk $(basename -s .chk $f).chk $(basename -s .chk $f).fchk
        if grep -q Normal "${filename}_3.log"; then
		mkdir ~aritra/gaussian/output/success/$(basename -s .chk $f)_3
                echo "${MAGENTA}=>${RESTORE} Ongoing job${GREEN} FINISHED SUCCESSFULLY${RESTORE} at $(date +%H:%M:%S)"
                mv $(basename -s .chk $f)_3.log ~aritra/gaussian/output/success/$(basename -s .chk $f)_3
                mv $(basename -s .chk $f)_3.gjf ~aritra/gaussian/output/success/$(basename -s .chk $f)_3
                mv $(basename -s .chk $f).chk ~aritra/gaussian/output/success/$(basename -s .chk $f)_3
                mv $(basename -s .chk $f).fchk ~aritra/gaussian/output/success/$(basename -s .chk $f)_3
                echo "\n${YELLOW}${filename}_3.gjf${RESTORE}, ${YELLOW}${filename}_3.log${RESTORE}, ${YELLOW}$filename.chk${RESTORE} & ${YELLOW}$filename.fchk${RESTORE} files have been moved into the ${CYAN}output/success/${filename}_3${RESTORE} folder\n-----------------\n"
        else
		mkdir ~aritra/gaussian/output/error/$(basename -s .chk $f)_3
                echo "${MAGENTA}=>${RESTORE} Ongoing job ${RED}TERMINATED${RESTORE} at $(date +%H:%M:%S)"
                mv $(basename -s .chk $f)_3.log ~aritra/gaussian/output/error/$(basename -s .chk $f)_3
                mv $(basename -s .chk $f)_3.gjf ~aritra/gaussian/output/error/$(basename -s .chk $f)_3
                mv $(basename -s .chk $f).chk ~aritra/gaussian/output/error/$(basename -s .chk $f)_3
                mv $(basename -s .chk $f).fchk ~aritra/gaussian/output/error/$(basename -s .chk $f)_3
                echo "\n${YELLOW}${filename}_3.gjf${RESTORE}, ${YELLOW}${filename}_3.log${RESTORE}, ${YELLOW}$filename.chk${RESTORE} & ${YELLOW}$filename.fchk${RESTORE} files have been moved into the ${CYAN}output/error/${filename}_3${RESTORE} folder\n-----------------\n"
        fi
	sleep 0.5
done
