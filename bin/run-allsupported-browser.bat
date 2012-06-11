@echo off

rm -rf ../archived
mkdir ..\archived

ruby run_testcases --verbose -b ie
mv ../log ../archived/log.ie

ruby run_testcases --verbose -b firefox
mv ../log ../archived/log.firefox

ruby run_testcases --verbose -b chrome
mv ../log ../archived/log.chrome

:end

