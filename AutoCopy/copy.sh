#!/bin/bash

# Declare the two arrays
array1=(
    "D:\Quantum\Quantum Project\Collaboration\Ca12O12, Saeedeh\Geom Opt" 
    "D:\Quantum\Quantum Project\Collaboration\Ca12O12, Saeedeh\Single Point"
    "D:\Quantum\Quantum Project\Collaboration\Ca12O12, Saeedeh\Temperature"  
    
    
    "D:\Quantum\Quantum Project\Collaboration\NIT Shilchar\Geom Opt"
    "D:\Quantum\Quantum Project\Collaboration\NIT Shilchar\SP"
    "D:\Quantum\Quantum Project\Collaboration\NIT Shilchar\TD-DFT"
)


array2=(
    "D:\Quantum\Quantum Project\Collaboration\Ca12O12, Saeedeh\Ca12O12 BackUp\Output Files\Geom Opt" 
    "D:\Quantum\Quantum Project\Collaboration\Ca12O12, Saeedeh\Ca12O12 BackUp\Output Files\Single Point"
    "D:\Quantum\Quantum Project\Collaboration\Ca12O12, Saeedeh\Ca12O12 BackUp\Output Files\Temperature"

    "D:\Quantum\Quantum Project\Collaboration\NIT Shilchar\NIT Silchar BackUp\Output Files\Geom Opt" 
    "D:\Quantum\Quantum Project\Collaboration\NIT Shilchar\NIT Silchar BackUp\Output Files\Single Point"
    "D:\Quantum\Quantum Project\Collaboration\NIT Shilchar\NIT Silchar BackUp\Output Files\TD-DFT"
)

# Start an infinite loop
while true
do
    # Loop over both arrays simultaneously
    for i in "${!array1[@]}"
    do
        # Copy all .log files from array1 path to array2 path
        find "${array1[$i]}" -name '*.log' -exec sh -c 'for file do [ ! -e "${2}/${file##*/}" ] && cp -n "$file" "$2"; done' sh {} "${array2[$i]}" \;
    done
    
    # Wait for 1 hr before running again
    sleep 3600
done
