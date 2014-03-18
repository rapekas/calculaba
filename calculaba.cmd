@echo off

:: Uncomment if you want to see where the script runs
::set direct=%~dp1
::cd %direct%
  
  set denydir=%cd:~-5%
  if /i %denydir% equ therm goto :warnexec

:: Checking permissions
  if not exist "e:\usr\%username%" mkdir "e:\usr\%username%"
  if not exist "e:\usr\%username%" goto :warnperm

:: Unpacking executables & setting path
  unzip -qo therm.zip -d "e:\usr\%username%"
  set PATH=e:\usr\%username%\therm;E:\usr\%username%\therm\bin64_Abaqus611;E:\usr\%username%\therm\bin64_Abaqus67;%PATH%

:: development command
rem call run.cmd 2>&1 | mtee /c/t calculaba.ses

:: production command
call run.cmd