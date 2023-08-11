# Define color and helper variables
RESTORE=$(echo '\033[0m')
RED=$(echo '\033[00;31m')
GREEN=$(echo '\033[00;32m')
YELLOW=$(echo '\033[00;33m')
CYAN=$(echo '\033[00;36m')
MAGENTA=$(echo '\033[00;35m')

# Define runCalculation function to run one Gaussian job
runCalculation() {
    # Get filename passed as argument
    # Print start message with filename and timestamp
    # Run Gaussian job for the input file
    filename=$1
    echo "${YELLOW}$filename${RESTORE} job started at $(date +%H:%M:%S)"
    g16 <$filename.gjf> $filename.log

    # Check if calculation completed successfully
    if grep -q Normal "$filename.log"; then
        # If optimization + frequency calculation
        if grep -qi freq "$filename.gjf"; then
            # Extract ZPE, enthalpy, free energy
            ZPE_String=$(grep "Zero-point correction" $filename.log)
            ZPE=$(echo $ZPE_String | grep -oE "\-?[0-9]+(\.[0-9]+)?" | sed -n '1p')
            delH_String=$(grep "Thermal correction to Enthalpy" $filename.log)
            delH=$(echo $delH_String | tr -cd '[:digit:].-')
            delG_String=$(grep "Thermal correction to Gibbs Free Energy" $filename.log)
            delG=$(echo $delG_String | tr -cd '[:digit:].-')
            # Extract final SCF energy
            last_Energy_line=$(grep -n "SCF Done" $filename.log | tail -1)
            Last_Energy=$(echo $last_Energy_line | grep -oE "\-?[0-9]+(\.[0-9]+)?" | sed -n '3p')
            # Store in result file
            touch $filename"_result.txt"
            printf "\n\n========== RESULTS ==========\nZPE Correction = ${ZPE}\nEnthalpy Correction = ${delH}\nGibbs Correction = ${delG}\nSCF Energy = ${Last_Energy}\n\n"
            printf "========== RESULTS ==========\nZPE Correction = ${ZPE}\nEnthalpy Correction = ${delH}\nGibbs Correction = ${delG}\n\nSCF Energy = ${Last_Energy}" >> $filename"_result.txt"
            # Extract optimized coordinates
            last_string_line=$(grep -n "Standard orientation:" $filename.log | tail -1)
            line_number=$(echo $last_string_line | cut -d':' -f1)
            start_line_number=$((line_number+5))
            last_line=$(grep -n "\------------------" $filename.log | awk -F':' -v start=$start_line_number '$1>=start{print;exit}')
            line_number=$(echo $last_line | cut -d':' -f1)
            last_line_number=$((line_number-1))
            unordered_coordinates=$(sed -n "$start_line_number,$last_line_number p" $filename.log)
            required_data=$(echo "$unordered_coordinates" | awk '{print $2, $4, $5, $6}')
            # Format coordinates nicely for next calculation and store in coordinates file
            echo "$required_data" | while read line; do
                col1=$(echo "$line" | awk '{printf("%2d", $1)}')
                col2=$(echo "$line" | awk '{if ($2>0) printf("   %f", $2); else if ($2 == 0) printf("  % .6f", $2); else printf("  %f", $2)}')
                col3=$(echo "$line" | awk '{if ($3>0) printf("   %f", $3); else if ($3 == 0) printf("  % .6f", $3); else printf("  %f", $3)}')
                col4=$(echo "$line" | awk '{if ($4>0) printf("   %f", $4); else if ($4 == 0) printf("  % .6f", $4); else printf("  %f", $4)}')
                formatted_line="$col1 $col2 $col3 $col4"
                echo "$formatted_line" >> $filename"_coordinates.txt"
            done
        # If single point energy calculation
        else
            # Extract final SCF energy
            Energy_String=$(grep "SCF Done" $filename.log)
            Energy=$(echo $Energy_String | grep -oE "\-?[0-9]+(\.[0-9]+)?" | sed -n '2p')
            # Store in result file
            touch $filename"_result.txt"
            printf "\n\n========== RESULTS ==========\nTotal Energy = ${Energy}\n\n"
            printf "========== RESULTS ==========\nTotal Energy = ${Energy}" >> $filename"_result.txt"
        fi
        # Move files to success folder with corresponding filename depeneding on job type (1.(geometry optimization + freqyecy) or 2.single point energy)
        mkdir ~aritra/gaussian/output/success/$(basename -s .gjf $f)
        echo "${MAGENTA}=>${RESTORE} Ongoing job${GREEN} FINISHED SUCCESSFULLY${RESTORE} at $(date +%H:%M:%S)"
        if grep -qi freq "$filename.gjf"; then
            mv $filename"_coordinates.txt" ~aritra/gaussian/output/success/$filename
            mv $filename.log ~aritra/gaussian/output/success/$filename
            mv $filename.chk ~aritra/gaussian/output/success/$filename
            mv $filename.gjf ~aritra/gaussian/output/success/$filename
            mv $filename"_result.txt" ~aritra/gaussian/output/success/$filename
            echo "\n${YELLOW}$filename.gjf${RESTORE}, ${YELLOW}$filename.log${RESTORE}, ${YELLOW}$filename.chk${RESTORE}, ${YELLOW}${filename}_result.txt${RESTORE} & ${YELLOW}${filename}_coordinates.txt${RESTORE} files have been moved into the ${CYAN}output/success/$filename${RESTORE} folder\n-----------------\n"
        else
            mv $filename.log ~aritra/gaussian/output/success/$filename
            mv $filename.chk ~aritra/gaussian/output/success/$filename
            mv $filename.gjf ~aritra/gaussian/output/success/$filename
            mv $filename"_result.txt" ~aritra/gaussian/output/success/$filename
            echo "\n${YELLOW}$filename.gjf${RESTORE}, ${YELLOW}$filename.log${RESTORE}, ${YELLOW}$filename.chk${RESTORE} & ${YELLOW}${filename}_result.txt${RESTORE} files have been moved into the ${CYAN}output/success/$filename${RESTORE} folder\n-----------------\n"
        fi
    # If calculation failed
    else
        # Try to extract coordinates if available (Error message: FormBX had a problem)
        if grep -qi formbx "$filename.log"; then
            # Extract last standard coordinates
            last_string_line=$(grep -n "Standard orientation:" $filename.log | tail -1)
            line_number=$(echo $last_string_line | cut -d':' -f1)
            start_line_number=$((line_number+5))
            last_line=$(grep -n "\------------------" $filename.log | awk -F':' -v start=$start_line_number '$1>=start{print;exit}')
            line_number=$(echo $last_line | cut -d':' -f1)
            last_line_number=$((line_number-1))
            unordered_coordinates=$(sed -n "$start_line_number,$last_line_number p" $filename.log)
            required_data=$(echo "$unordered_coordinates" | awk '{print $2, $4, $5, $6}')
            # Format coordinates nicely for redo calculation and store in coordinates file
            echo "$required_data" | while read line; do
                col1=$(echo "$line" | awk '{printf("%2d", $1)}')
                col2=$(echo "$line" | awk '{if ($2>0) printf("   %f", $2); else if ($2 == 0) printf("  % .6f", $2); else printf("  %f", $2)}')
                col3=$(echo "$line" | awk '{if ($3>0) printf("   %f", $3); else if ($3 == 0) printf("  % .6f", $3); else printf("  %f", $3)}')
                col4=$(echo "$line" | awk '{if ($4>0) printf("   %f", $4); else if ($4 == 0) printf("  % .6f", $4); else printf("  %f", $4)}')
                formatted_line="$col1 $col2 $col3 $col4"
                echo "$formatted_line" >> $filename"_coordinates.txt"
            done
            # Move files to error folder for FormBX failed job
            mkdir ~aritra/gaussian/output/error/$(basename -s .gjf $f)
            echo "${MAGENTA}=>${RESTORE} Ongoing job ${RED}TERMINATED${RESTORE} at $(date +%H:%M:%S)"
            mv $filename.log ~aritra/gaussian/output/error/$filename
            mv $filename.chk ~aritra/gaussian/output/error/$filename
            mv $filename.gjf ~aritra/gaussian/output/error/$filename
            mv $filename"_coordinates.txt" ~aritra/gaussian/output/error/$filename
            echo "\n${YELLOW}$filename.gjf${RESTORE}, ${YELLOW}$filename.log${RESTORE}, ${YELLOW}$filename.chk${RESTORE}, ${YELLOW}${filename}_result.txt${RESTORE} & ${YELLOW}${filename}_coordinates.txt${RESTORE} files have been moved into the ${CYAN}output/error/$filename${RESTORE} folder\n-----------------\n"
        # If extracting coordinates is not necessary or possible
        else
            # Move files to error folder for other type of failed job
            mkdir ~aritra/gaussian/output/error/$(basename -s .gjf $f)
            echo "${MAGENTA}=>${RESTORE} Ongoing job ${RED}TERMINATED${RESTORE} at $(date +%H:%M:%S)"
            mv $filename.log ~aritra/gaussian/output/error/$filename
            mv $filename.chk ~aritra/gaussian/output/error/$filename
            mv $filename.gjf ~aritra/gaussian/output/error/$filename
            echo "\n${YELLOW}$filename.gjf${RESTORE}, ${YELLOW}$filename.log${RESTORE}, ${YELLOW}$filename.chk${RESTORE} & ${YELLOW}${filename}_result.txt${RESTORE} files have been moved into the ${CYAN}output/error/$filename${RESTORE} folder\n-----------------\n"
        fi
    fi
    # Wait 10 seconds before starting a new calculation
    sleep 10
}

# Initialize filenames tracking file for automating single point energy calculation from previous result
touch "filenames.txt"
filenames="./filenames.txt"

# Main loop to run jobs for available input files (script starting time) or new input files 
while true; do
    # Get all the gaussian input files (.gjf files)
    files=$(find . -name "*.gjf")
    # Break the loop if no file is there
    if [ -z "$files" ]; then
        break
    fi
    # Run the available input files. Store the name if only it is not a single point energy calculation
    for f in $files; do
        filename="$(basename -s .gjf $f)"
        runCalculation $filename
        if echo "$filename" | grep -q "\_SP$" > /dev/null 2>&1; then
            continue
        else
            echo $filename >> $filenames
        fi
    done
    # Search in the folder if new input file is available
    new_files=$(find . -name "*.gjf" | diff -u $filenames -)
    if [ -n "$new_files" ]; then
        echo "🔍🔍🔍  Found New ${GREEN}.𝐠𝐣𝐟 𝐈𝐧𝐩𝐮𝐭${RESTORE} File for Calculation.\n"
    fi
done

# Function to generate single point calculation input files from completed normal jobs
filenameStorage(){
    # Loop through tracked finished jobs using "filenames.txt"
    while read p; do
        filename="$p"
        # Get info from previous job
        coordinateFile="../output/success/"$filename"/"$filename"_coordinates.txt"
        previousInputFile="../output/success/"$filename"/"$filename".gjf"
        chargemultiplicity=$(sed -n '8p' "$previousInputFile")
        # Get SP job theory and other data from "energy.txt"
        energyCodeFile="./energy.txt"
        # Write %section from "energy.txt" file data
        echo "%chk=${filename}_SP.chk" >> $filename"_SP.gjf"
        head -n 2 "$energyCodeFile" >> $filename"_SP.gjf"
        # If "gen" keyword is used for basis set (basis set, charge & multiplicity, coordinates, basis sets description)
        if grep -qPoi '[\s\/]+gen[\s\/]+' "$previousInputFile"; then
            sed -n '4p' "$energyCodeFile" >> $filename"_SP.gjf"
            echo "" >> $filename"_SP.gjf"
            sed -n '6p' "$energyCodeFile" >> $filename"_SP.gjf"
            echo "" >> $filename"_SP.gjf"
            echo "$chargemultiplicity" >> $filename"_SP.gjf"
            cat "$coordinateFile" >> $filename"_SP.gjf"
            echo "" >> $filename"_SP.gjf"
            sed -n '7,$p' "$energyCodeFile" >> $filename"_SP.gjf"
            echo "\n\n" >> $filename"_SP.gjf"
        # If "gen" keyword is not used for basis set (basis set, charge & multiplicity, coordinates)
        else
            sed -n '3p' "$energyCodeFile" >> $filename"_SP.gjf"
            echo "" >> $filename"_SP.gjf"
            sed -n '5p' "$energyCodeFile" >> $filename"_SP.gjf"
            echo "" >> $filename"_SP.gjf"
            echo "$chargemultiplicity" >> $filename"_SP.gjf"
            cat "$coordinateFile" >> $filename"_SP.gjf"
            echo "\n" >> $filename"_SP.gjf"
        fi
    done < $filenames
    # Run calculation for all the newly generated input files
    for f in $(find . -name "*.gjf"); do
        filename="$(basename -s .gjf $f)"
        runCalculation $filename
    done
    # Delete the filename tracking file 
    rm $filenames
}

# Pass "filenames.txt" to filenameStorage() function
filenameStorage $filenames

# Loop for starting new calculations for new input files provided at the time of SP jobs
while true; do
    # Get all the gaussian input files (.gjf files)
    files=$(find . -name "*.gjf")
    # Break the loop if no file is there
    if [ -z "$files" ]; then
        break
    fi
    # Run the available input files & store the name if only it is not a single point energy calculation
    for f in $files; do
        filename="$(basename -s .gjf $f)"
        if echo "$filename" | grep -q "\_SP$" > /dev/null 2>&1; then
            continue
        else
            runCalculation $filename
            echo $filename >> $filenames
        fi
    done
    # Pass updated "filenames.txt" to filenameStorage() function
    filenameStorage $filenames
    # Run the available left over SP input files
    for f in $files; do
        filename="$(basename -s .gjf $f)"
        if echo "$filename" | grep -q "\_SP$" > /dev/null 2>&1; then
            runCalculation $filename
        fi
    done
    # Check if "filenames.txt" file is available and search in the folder to get those new input files
    if [ -f "./filenames.txt" ]; then
        new_files=$(find . -name "*.gjf" | diff -u $filenames -)
        if [ -n "$new_files" ]; then
            echo "🔍🔍🔍  Found New ${GREEN}.𝐠𝐣𝐟 𝐈𝐧𝐩𝐮𝐭${RESTORE} File for Calculation.\n"
        fi
    fi
done


