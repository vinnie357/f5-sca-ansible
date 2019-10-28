@echo off 
set list= 52.54.227.6 18.207.29.15 34.234.8.123 3.224.101.130
(for %%a in (%list%) do ( 
   echo %%a
   cmd.exe /c start wsl.exe ssh -i ~/keys/aws admin@%%a
))
