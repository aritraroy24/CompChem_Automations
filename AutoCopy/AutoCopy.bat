@echo off
cd /d "D:\scripts\AutoCopy"
start "" /B "C:\Program Files\Git\bin\bash.exe" -c "./copy.sh &" > NUL 2>&1