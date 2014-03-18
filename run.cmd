@echo off
title C a l c u l A b a
goto :beg

:: This does not allow to run script in C:\Windows folder
:: set direct=%~dp1  >nul 2>&1
:: cd %direct%  >nul 2>&1

  set denydir=%cd:~-5%
  if /i %denydir% equ therm goto :warnexec

:: check permissions
  if not exist "e:\usr\%username%" mkdir "e:\usr\%username%"
  if not exist "e:\usr\%username%" goto :warnperm

:: unpack executables & set path
  unzip -qo therm.zip -d "e:\usr\%username%"
  set PATH=e:\usr\%username%\therm;%PATH%
  
  :beg
:: support mail (beta)
  set smtp_ip=192.168.77.2

  set isfirstrun=single
  
:: History

:: Next major release:

:: !added md5 hash sum creation for ODB
:: !added select % of memory for 6.7
:: !removed gpu=nvidia for 6.7
:: !added infinitesimal=1000 to inp if error # appeared
:: !turned back to token check using utils from 6.7 (6.11 has not them)
:: !added ability to change params (cpus, mem) for next calculs in batch
:: !turned back Tinit check
:: !added analyze for stabi and make cpus=1
:: !added sorting calculs by type: first stab points
:: !allowed parallel calculs: up to 2 stabi (5+1 tokens each, cpus=2) or 1 stab (5 tokens) + 1 transient (5+2 tokens, cpus=3)

  set calculaba=v1.5g9 Crimea freedom edition

:: released on Github

:: CAT version
  set vcat=v03b02r06_c
  :: set vcat=v03b02r06

:: run key.js to prevent lock screen
  taskkill /IM wscript.exe /F /T >nul 2>&1
  start wscript //B e:\usr\%username%\therm\key.js >nul 2>&1
  del calculaba.ses tmp.conf mech.out mech.txt last.out lines.out >nul 2>&1
  set imode=config
  set curline= 1
  set last=1

  cls
  color 3b

  echo +
  echo +
  echo +    #####                                        #                 
  echo +   #     #   ##   #       ####  #    # #        # #   #####    ##  
  echo +   #        #  #  #      #    # #    # #       #   #  #    #  #  # 
  echo +   #       #    # #      #      #    # #      #     # #####  #    #
  echo +   #       ###### #      #      #    # #      ####### #    # ######
  echo +   #     # #    # #      #    # #    # #      #     # #    # #    #
  echo +    #####  #    # ######  ####   ####  ###### #     # #####  #    #
  echo +
  echo +
  echo +                  calculABA %calculaba%
  echo +
  echo +-------------------------------------------------------------------------
  echo +
  echo +    For interactive mode press Y (N)
  choice /c YN /t 4 /d n
    if /i %errorlevel%==1 (
      set src=.
      set imode=inter
      set attach1=
        goto :intermode
        )

  :chkconfig
:: check in config exists else switch to interactive mode (nocfg)
    if not exist config.txt goto :nocfg
:: if config exists make a temporary copy and clean current folder from old files
  :: SAFELY DEPRECATED. NEXT LINE IS DANGEROUS. IF YOU RUN IT IN WORKDIR CONTAINS WRONG CONFIG, THE LINE WILL REMOVE ALL!
  rem del *.inp *.bca *.cca *chamandb *.cid *.com *.csv abaqus.dat *.debug *.env *.fca *.gca *.lck *.mdl abaqus.msg *.odb *.par *.pes *.pmg *.prt *.rca *.sca *.sta *.stt *.trace *.xml *.023 *.aapresults *.rpy *.csv sed* *.out *.sim tmp.conf>nul 2>&1
  copy /y config.txt tmp.conf >nul 2>&1
    :: remove name and email from config and read 3rd string 'source='
    sed -i -e "1d" tmp.conf
    sed -i -e "1d" tmp.conf
  set /p src=<tmp.conf
    :: generating input list using CCA files
    dir abaqus.cca %src% /s /b /-p /o:gn | sort | grep \\abaqus.cca> mech.txt
    :: if exist abaqus.inp in temporary directory, delete it and start automatic mode (prereadinp) 
    if exist abaqus.inp sed -i -e "$d" mech.txt
  goto :prereadinp

  :nocfg
:: if inp exists & config does not exist, set current folder as working directory, generate simple mech.txt and start automatic mode (prereadinp)
:: if inp & config do not exist, create new config and open it in notepad, then return to check if config exist (chkconfig)
    if exist abaqus.inp (
      set src=.
      echo %src%>mech.txt
      goto :prereadinp
      )
    :mechgen
    :: input list generator
    set src=.
    echo .>mech.txt
    rem dir abaqus.inp /s /b /-p /o:gn | sort > mech.txt
  :: add hare tag to the end of list
  rem  echo hare>> mech.txt
  rem  uniq -i dd.txt > mech.txt
  :: remove abaqus.inp from all strings
  sed -i "s/abaqus.cca//g" mech.txt
  :: check if mech.txt is empty
  set /p src<=mech.txt
    if /i %src% equ hare goto :newconf else goto :prereadinp
    
  :newconf
:: Config generator
    echo name=> config.txt
    echo email=>> config.txt
    echo source=>> config.txt
    echo comment=>> config.txt
    echo abaqus=6.11>> config.txt
    echo memory=50>> config.txt
    echo log=yes>> config.txt
    echo mail=>> config.txt
    echo cpus=8 gpu=nvidia>> config.txt
    echo backup=>> config.txt
    echo ##################>> config.txt
    echo # ������ ������� #>> config.txt
    echo ##################>> config.txt
    echo name=������ �������  *������������� ��� ������>> config.txt
    echo email=email@dosmartec.ru  *������������� ��� ������>> config.txt
    echo source=\\ws100500\d\users\md100500\work\test_project_files\dp0\SYS-1\MECH\>> config.txt
    echo comment=�����������>> config.txt
    echo abaqus=6.7/6.11>> config.txt
    echo memory=8000/50>> config.txt
    echo log=yes/no>> config.txt
    echo mail=mail1@dosmartec.ru,mail2@samara.dosmartec.ru>> config.txt
    echo cpus=8 gpu=nvidia>> config.txt
    echo backup=\\wsrv-4\PRJ\S_CT\backup>> config.txt
    echo #>> config.txt
    echo CPUS   1   2  4   8  12  16  24  32  64  128>> config.txt
    echo TOKENS 5   6  8  12  14  16  19  21  28   38>> config.txt
  notepad config.txt
  goto :chkconfig

:: DO NOT USE FUNCTION 'IF EXIST' BCZ set /p src=<file DOES NOT WORK!!
:: USE 'IF NOT EXIST' EXACTLY!!
  :prereadinp
  :: if inp exist BUT config does not exist, switch to interactive mode
  if not exist config.txt set imode=inter & goto :intermode
  
    :: add end of input list
    echo hare>> mech.txt
    copy /y mech.txt mech.out /a >nul 2>&1
    :: remove duplicates
    uniq -i mech.out > mech.txt
    sed -i "s/abaqus.cca//g" mech.txt
      :: line numbering, add numbers to lines in mech.txt (just copied)
      copy /y mech.txt lines.out /a >nul 2>&1
	  :: create a file only with numbers lines.out
	  ::   TIP. The utility reads first line in lines.out/ and the variable from /last.out (1/18 for example)
	  ::   then it removes the first line in lines.out each time before next batch calculation and read new first line (2/18 etc).
      sed = mech.txt | sed "N; s/^/     /; s/ *\(.\{6,\}\)\n/\1  /" > lines.out
        :: remove unnecessary last line
        sed -i -e "$d" lines.out
          :: count lines
          sed -n "$=" lines.out > last.out
          set /p last=<last.out
  
  :readinp
          :: read number of current line 
          set /p curline=<lines.out
          :: show first 7 symbols from var
          set curline=%curline:~0,7%

  echo +
  echo +    To modify mech.txt press Y (N)
  if %isfirstrun% equ batch (
  choice /c YN /t 120 /d n
  goto :modmechtxt
  )
    choice /c YN /t 10 /d n
	:modmechtxt
    if /i %errorlevel%==1 (
	  notepad mech.txt
		:: renew counter
			sed = mech.txt | sed "N; s/^/     /; s/ *\(.\{6,\}\)\n/\1  /" > lines.out
			sed -i -e "$d" lines.out
			:: reread count lines
			sed -n "$=" lines.out > last.out
			set /p last=<last.out
	)
    set attach1=-attach mech.txt
      copy /y config.txt tmp.conf >nul 2>&1
        chcp 1251 >nul 2>&1
          set /p name=<tmp.conf
          set name=%name:~5%
            sed -i -e "1d" tmp.conf

  :mail_
:: read mail from config
      set /p email=<tmp.conf
      set email=%email:~6%
        sed -i -e "1d" tmp.conf
      
:: clear variables (possible should be depricated since 1.5g6)
      set calcul=
      set freq=
      set temoin=
      set period=
      set wallh=
      set ram2=
      set diskc2=
      set diskd2=
      set diske2=
      set prj=
      set statok=
      set errses=
      set errdat=
      set errmsg=
      set abamem=
      set ncpu=
      set equat=
      set flops=
      set chkmess1=
      set chkmess2=
      set chkmess3=
      set chkmess4=
      
  :src
:: read source
      set /p src=<mech.txt
        sed -i -e "1d" tmp.conf
          goto :modsrc

  :intermode
:: name and path are filled by user
    if %imode% equ inter (
    echo +
      set /p name="+    TYPE YOUR NAME - "
            
    echo +
      echo + SOURCE directory is a current folder.
      echo + To change SOURCE press Y
    )    
      choice /c YN /t 7 /d n
         if /i %errorlevel%==1 (
         set /p src="+    PROJECT SOURCE PATH - "
         )
           if not exist abaqus.cca goto :warn_no_cca 
           goto :modsrc

  :modsrc
:: check for existance of ending backslash and adding \\ws at the beginning
  echo +
  echo + SOURCE%curline%/%last%:
  echo + %src%
  set prjd=%src%\*
  set prjd=%prjd:\\=\%
  set prjdws=%prjd:\ws=\\ws%
    set srcuns=\\%computername%\%src%
    set srcuns=%srcuns::=%

:: copy input data from source to calcul folder
  if %src% neq . (
  echo +
  xcopy /y /q /c /exclude:exclude.txt %prjdws% .
  )
    :: read titre
    for /F "tokens=*" %%x in ('grep -i "TITRE" abaqus.cca') do set calcul=%%x
      set calcul=%calcul:~8%
        :: read max element id
        for /F "tokens=*" %%x in ('grep -i "maxelementid" abaqus.inp') do set maxelementid=%%x
          set maxelementid=%maxelementid:~15%

:: user comment
  if not exist config.txt goto :comment
  if %imode% equ inter goto :comment
    chcp 1251 >nul 2>&1
    set /p comm=<tmp.conf
    set comm=%comm:~8%
      sed -i -e "1d" tmp.conf
      goto :checkdomain

  :comment
:: interactive comment
sleep 1 s
echo +
echo +    To add comment press Y (N)
  choice /c YN /t 4 /d n /m "+ 4s"
    if /i %errorlevel%==2 (
      set comm=
      ) else (
        set /p comm="+    COMMENT - "
        )

  :checkdomain
:: check domain, city is temporary set to Samara
  if /i %userdomain% EQU SMARTEC (
    :: for Moscow
    set smtp_ip=192.168.2.9
    set city=samara.
    set var=s_ct
    )

  if /i %userdomain% EQU SMARTEC-SAM (
    :: For Samara
    set smtp_ip=192.168.77.2
    set city=samara.
    set var=s_ct
  :: COMMENT LINE BELOW FOR PRODUCTION
 rem set var=irabkesov
    ) else (
    :: secure run
    rem blat.exe -server %smtp_ip% %attach1% -f %from% -t %to% -q -subject "Unauthorized access detected" -body "Unauthorized execution attempt by %username% from %computername%. Local time: %dt1% at %tm1%"
  rem goto :warndomain
    )

:: select abaqus
  if %imode% equ inter goto :veraba
  if not exist tmp.conf goto :veraba else (
    set /p ver=<tmp.conf
    set ver=%ver:~7%
      sed -i -e "1d" tmp.conf
      goto :abaselect
      )

  :veraba
:: abaqus version select
  echo +
  echo +
  echo +    To change abaqus [6.11] to 6.7 press Y (N)
  echo +
  sleep 1 s
  echo +
  choice /c YNh /t 7 /d n /m "+ 7s"
  if /i %errorlevel%==1 set ver=6.7
  if /i %errorlevel%==2 set ver=6.11
  if /i %errorlevel%==3 set ver=6.12

  :abaselect
  if /i %ver% equ 6.7 goto :aba673
  if /i %ver% equ 6.12 goto :aba612


:: FIRST modify path in therm//bin(64)_abaqus//abaqus_v6.env THEN copy it to workdir ELSE CAT will not work!
:: This block changes path to CAT library in abaqus_v6.env (makes CAT portable, install independent)

  :aba611
  set PATH=E:\usr\%username%\therm\bin64_Abaqus611;%PATH%
  set aba_home=D:\ABAQUS\6.11-2
  set path=%aba_home%\exec;%aba_home%\exec\lbr;%aba_home%\Python\lib;%aba_home%\External;%path%
  set abqexe=D:\ABAQUS\6.11-2\exec\abq6112.exe
    if not exist %abqexe% goto :warnaba
    echo %abqexe% > abqx.bat
  
  sed -i -e "/os.environ\[libPathName\]/d" "E:\usr\%username%\therm\bin64_Abaqus611\abaqus_v6.env"
  sed -i -e "/del libPathName/i\os.environ[libPathName] =r\"E:\\usr\\%username%\\therm\\bin64_Abaqus611;\"+os.environ[libPathName]" "E:\usr\%username%\therm\bin64_Abaqus611\abaqus_v6.env"
  
  sed -i -e "/abaquslm_license_file/d" "E:\usr\%username%\therm\bin64_Abaqus67\abaqus_v6.env"
  :: sed -i -e "/abaquslm_license_file/d" "E:\usr\%username%\therm\bin_Abaqus67\abaqus_v6.env"
  sed -i -e "/abaquslm_license_file/d" "E:\usr\%username%\therm\bin64_Abaqus611\abaqus_v6.env"
  xcopy /y /q /c e:\usr\%username%\therm\bin64_Abaqus611\abaqus_v6.env . >nul 2>&1
    goto :checkfreq

  :aba612
  set PATH=E:\usr\%username%\therm\bin_Abaqus611;%PATH%
  set aba_home=C:\simulia\Abaqus\6.12-3
  set path=%path%;C:\simulia\Abaqus\6.12-3\code\bin;C:\simulia\Abaqus\6.12-3\code\python\lib
  set abqexe=C:\simulia\Abaqus\6.12-3\code\bin\abq6123.exe
    if not exist %abqexe% goto :warnaba
    echo %abqexe% > abqx.bat
  
  sed -i -e "/os.environ\[libPathName\]/d" "E:\usr\%username%\therm\bin_Abaqus611\abaqus_v6.env"
  sed -i -e "/del libPathName/i\os.environ[libPathName] =r\"E:\\usr\\%username%\\therm\\bin_Abaqus611;\"+os.environ[libPathName]" "E:\usr\%username%\therm\bin_Abaqus611\abaqus_v6.env"
  
  sed -i -e "/abaquslm_license_file/d" "E:\usr\%username%\therm\bin64_Abaqus67\abaqus_v6.env"
  :: sed -i -e "/abaquslm_license_file/d" "E:\usr\%username%\therm\bin_Abaqus67\abaqus_v6.env"
  sed -i -e "/abaquslm_license_file/d" "E:\usr\%username%\therm\bin64_Abaqus611\abaqus_v6.env"
  xcopy /y /q /c e:\usr\%username%\therm\bin_Abaqus611\abaqus_v6.env . >nul 2>&1
    goto :checkfreq

  :aba673
  set PATH=E:\usr\%username%\therm\bin64_Abaqus67;%PATH%
  set aba_home=D:\ABAQUS\6.7-3
  set path=%path%;%aba_home%;%aba_home%\exec\lbr;%aba_home%\Python\Obj\lbr;%aba_home%\External\Acis;%aba_home%\External;%aba_home%\exec;%aba_home%\External\Interop_32;%aba_home%\External\32;%aba_home%\External\Elysium;C:\IFOR\WIN\BIN;C:\IFOR\WIN\BIN\EN_US
  set abqexe=D:\ABAQUS\6.7-3\exec\abq673.exe
    if not exist %abqexe% goto :warnaba
    echo %abqexe% > abqx.bat
  sed -i -e "/os.environ\[libPathName\]/d" "E:\usr\%username%\therm\bin64_Abaqus67\abaqus_v6.env"
  sed -i -e "/del libPathName/i\os.environ[libPathName] =r\"E:\\usr\\%username%\\therm\\bin64_Abaqus67;\"+os.environ[libPathName]" "E:\usr\%username%\therm\bin64_Abaqus67\abaqus_v6.env"
  
  sed -i -e "/abaquslm_license_file/d" "E:\usr\%username%\therm\bin64_Abaqus67\abaqus_v6.env"
  :: sed -i -e "/abaquslm_license_file/d" "E:\usr\%username%\therm\bin_Abaqus67\abaqus_v6.env"
  sed -i -e "/abaquslm_license_file/d" "E:\usr\%username%\therm\bin64_Abaqus611\abaqus_v6.env"
  xcopy /y /q /c e:\usr\%username%\therm\bin64_Abaqus67\abaqus_v6.env . >nul 2>&1
    goto :checkfreq

  :checkfreq
:: check if string 'frequency = ' exists
  sleep 1 s
  if not exist abaqus.cca goto :warn_no_cca
::    for /F "tokens=*" %%x in ('grep -i "FREQUENCY" abaqus.cca') do set freq=%%x
::    set freq=%freq:~-4%
rem This block detects point and skips checkfreq (dangerous, commented)
rem      for /f "tokens=*" %%x in ('grep -i "*HEAT TRANSFER, DELTMX=5, END=PERIOD" abaqus.inp') do set chkinp=%%x
rem        set period=%chkinp:~-6%
rem          if /i %period% NEQ PERIOD (
rem            set ctype=Stable-state point
rem            goto :checktemoin
rem        ) else (
rem        goto :modfreq
rem        )
rem
rem        :modfreq
::        if /i %freq% NEQ 1000 (
::          sed -i -e "/FREQUENCY/d" abaqus.cca
::          sed -i -e "/COE/i\FREQUENCY = 1000" abaqus.cca
::            set chkmess1=FREQUENCY set to 1000
::            ) else (
::              set chkmess1=FREQUENCY is 1000
::              )

  :checktemoin
:: check parameter temoin = non
  for /F "tokens=*" %%x in ('grep -i "TEMOIN" abaqus.cca') do set temoin=%%x
  set temoin=%temoin:~9%
    if /i %temoin% NEQ NON (
      sed -i -e "/TEMOIN/d" abaqus.cca
      sed -i -e "/VIT/i\TEMOIN = NON" abaqus.cca
      set chkmess2=TEMOIN/DEBUG switched to NON
    ) else (
      set chkmess2=TEMOIN is off
      )

  :checkstate
:: check for transient
  if not exist abaqus.inp goto :warn_no_inp
  for /f "tokens=*" %%x in ('grep -i "END=PERIOD" abaqus.inp') do set period=%%x
    set period=%period:~-6%
      if /i %period% EQU PERIOD (
        set ctype=transient mission
        goto :checkcontrol
    ) else (
      set ctype=stable-state point
      set chkmess1=FREQUENCY has been skipped!
      goto :main
      )

  :checkcontrol
:: check frequency for transient
  for /F "tokens=*" %%x in ('grep -i "FREQUENCY" abaqus.cca') do set freq=%%x
    set freq=%freq:~-4%

          if /i %freq% NEQ 1000 (
          sed -i -e "/FREQUENCY/d" abaqus.cca
          sed -i -e "/COE/i\FREQUENCY = 1000" abaqus.cca
            set chkmess1=FREQUENCY set to 1000
            ) else (
              set chkmess1=FREQUENCY is 1000
              )

:: check controls 30 for transient
  sleep 1 s
  for /F "tokens=*" %%x in ('grep -i "CONTROLS" abaqus.inp') do set ctrl=%%x
    set ctrl=%ctrl:~1%
    set ctrl=%ctrl:~0,8%
      if /i %ctrl% NEQ CONTROLS (
  sleep 2 s
  sed -i -e "/SOLVE FOR STEP 1 -/{:a;n;n;n;n;/**/!ba;i\*CONTROLS, PARAMETERS=TIME INCREMENTATION" -e "}" abaqus.inp
  sed -i -e "/CONTROLS/a ,,,,,,,30," abaqus.inp
    set chkmess3=CONTROLS parameter added to STEP 1
  ) else (
    set chkmess3=CONTROLS parameter is OK
    )

  :main
:: THIS STRING & TIME MUST BE ONLY AFTER SED INP!!! This might be a cause of controls 30 not insert problem in batch
:: setlocal enableextensions enabledelayedexpansion

:: THIS STRING & TIME MUST BE ONLY AFTER SED INP TOO!!!
  :: get start date and time
  set dt1=%date%
  set time1=%time%
  :: cut 6 symbols from the end
  set tm=%time1:~0,-6%
  :: replace : to .
  set tm1=%tm::=.%
  set tm1=%tm1: =0%

  :: get folder name based on date YYYYMMDD format
  set ddmmyy=%date%
  set yy=%date:~6%
  set mm=%date:~3,-5%
  set dd=%date:~0,-8%
  set yyyymm=%yy%%mm%
  set yyyymmdd=%yy%%mm%%dd%

:: remove current ENV in user profile ELSE we get double string of CAT initialization
  del "%userprofile%\abaqus_v6.env" >nul 2>&1

:: remove lock file
  del abaqus.lck >nul 2>&1

  :project
:: get project name from INP
  sleep 1 s
    for /F "tokens=*" %%x in ('grep -i project abaqus.inp') do set prj=%%x
      set prj=%prj:~17%
:: replace :, ,; to underscore _ in project name (also ),( but %!)
rem setlocal DisableDelayedExpansion
  set prj=%prj: =_%
  set prj=%prj:,=_%
  set prj=%prj:;=_%
  set prj=%prj:(=_%
  set prj=%prj:)=%
  set prj=%prj:__=_%
  set wbmodule=%prj:~-3%

  title %curline%/%last% - %calcul% (%ver%) - %prj%


  :ifortran
:: Intel fortran libraries (beta)
  :: call "C:\Program Files\Microsoft Platform SDK\SetEnv" /X64 /RETAIL
  SET IFORT_COMPILER91=C:\Program Files (x86)\Intel\Compiler\Fortran\9.1
  SET INTEL_LICENSE_FILE=C:\Program Files (x86)\Common Files\Intel\Licenses
  Set Path=%IFORT_COMPILER91%\EM64T\Bin;%path%
  Set Lib=%IFORT_COMPILER91%\EM64T\Lib;%LIB%
  SET Include=%IFORT_COMPILER91%\EM64T\Include;%Include%
  if exist "C:\Program Files (x86)\Intel\Compiler\Fortran\9.1\EM64T\Bin\imsl.bat" call "C:\Program Files (x86)\Intel\Compiler\Fortran\9.1\EM64T\Bin\imsl.bat"

  :: set current directory without ":"
  set curdir=%cd::=%



  :checkuser
  call private\checkuser.cmd

:: This block was moved to private since 1.5g9

  if exist config.txt (
    set from=%email%
    goto :welcome
  )

:: enter user mailbox
  echo +
  sleep 1 s
  echo +
  echo +    Enter your e-mail [nsurname@%city%dosmartec.ru] (N)
  echo +    If you don't know your mail, skip this step
  echo +    or wait 4 sec...
    choice /c yn /t 4 /d n /m "+ 4s"
      if /i %errorlevel%==1 goto :entermail
      if /i %errorlevel%==2 (
        set from=%supmail%
        set comm=Unauthorized execution detected
        goto :welcome
        )

  :entermail
:: interactive email setup
    set /p from="+    enter your e-mail <nsurname@%city%dosmartec.ru> - "
  sleep 1 s


  :welcome
:: welcome message
  sleep 1 s
  chcp 866 >nul 2>&1
  echo +
  echo +
  echo +                         WELCOME, %name%!
  sleep 1 s
  echo +
  echo +


:: select memory depending of abaqus version (beta)
  :abamem
  if /i %ver% equ 6.7 (
    for /F "tokens=*" %%x in ('grep -i standard_memory abaqus_v6.env') do set abamem=%%x
  )
  if /i %ver% neq 6.7 (
      for /F "tokens=*" %%x in ('grep memory abaqus_v6.env') do set abamem=%%x
  )

  :: change memory
  if %imode% equ inter goto :memaba
  rem if not exist config.txt goto :memaba
    set /p abamem=<tmp.conf
    set abamem=%abamem:~7%
    rem if %ver% neq 6.7 set abamem='%abamem%%%'
      sed -i -e "1d" tmp.conf
        set chkmess4=ABAQUS memory set to %abamem%
        
          if %ver% neq 6.7 (
          sed -i -e "/memory \=/d" abaqus_v6.env
          sed -i -e "/standard_/i\memory \= \'%abamem%%%\'" abaqus_v6.env
          set chkmess4=ABAQUS memory set to %abamem% %% in abaqus_v6.env
          ) else (
      sed -i -e "/pre_memory \=/d" abaqus_v6.env
      sed -i -e "/standard_memory \=/i\pre_memory \= \"%abamem% mb\"" abaqus_v6.env
      sed -i -e "/standard_memory \=/d" abaqus_v6.env
      sed -i -e "/pre_/i\standard_memory \= \"%abamem% mb\"" abaqus_v6.env
        set chkmess4=ABAQUS memory set to %abamem% MB in abaqus_v6.env
      )

  goto :chkinstall

  :memaba
:: interactive memory change
  if %ver% equ 6.7 echo +    To modify abaqus %abamem% press Y (N)
  if %ver% neq 6.7 (
  set abamem=%abamem:~10,-3%
  echo +    To modify abaqus %abamem% press Y [N]
  )
  sleep 1 s
  choice /c yn /t 4 /d n /m "+ 4s"
    if /i %errorlevel%==1 (
      echo +    For [6.7] type memory in MB, for [6.8 and above] type in % RAM
        set /p abamem="+    memory - "
        rem if %ver% neq 6.7 set abamem='%abamem%%%'
        )
    if /i %errorlevel%==2 goto :chkinstall
        
    if /i %ver% equ 6.7 (
      sed -i -e "/pre_memory \=/d" abaqus_v6.env
      sed -i -e "/standard_memory \=/i\pre_memory \= \"%abamem% mb\"" abaqus_v6.env
      sed -i -e "/standard_memory \=/d" abaqus_v6.env
      sed -i -e "/pre_/i\standard_memory \= \"%abamem% mb\"" abaqus_v6.env
        set chkmess4=ABAQUS memory set to %abamem% MB in abaqus_v6.env
        ) else (
          sed -i -e "/memory \=/d" abaqus_v6.env
          sed -i -e "/standard_/i\memory \= \'%abamem%%%\'" abaqus_v6.env
            set chkmess4=ABAQUS memory set to %abamem% %% in abaqus_v6.env
            )

:: check Abaqus installation
  :chkinstall
  echo %abqexe% info=system > abqx_req.bat
    call abqx_req > requir.out
    for /F "tokens=*" %%x in ('tail -3 requir.out') do set req=%%x

  :: save system info
  echo %abqexe% info=all > abqx_sys.bat
    call abqx_sys > system.out

  :: check system log
  for /F "tokens=*" %%x in ('grep -i error system.out') do set syserr=%%x

  :: read machine configuration
  for /F "tokens=*" %%x in ('sed -n "/System Host ID/{n;n;n;p}" requir.out') do set nproc=%%x
    set nproc=%nproc:~21%

  rem for /F "tokens=*" %%x in ('sed -n "/System Host ID/{n;n;n;n;p}" requir.out') do set nos=%%x

  if %ver% equ 6.7 (
    for /F "tokens=*" %%x in ('sed -n "/System Host ID/{n;n;n;n;n;n;n;p}" requir.out') do set nram1=%%x
    rem set nram1=%nram1:~0,-6%
    )
    if %ver% equ 6.11 (
      for /F "tokens=*" %%x in ('sed -n "/System Host ID/{n;n;n;n;n;n;p}" requir.out') do set nram1=%%x
      )
       
  rem for /F "tokens=*" %%x in ('sed -n "/Disk/{n;p}" requir.out') do set ndrives=%%x
  for /F "tokens=*" %%x in ('sed -n "/Disk/{n;n;p}" requir.out') do set ndiskc1=%%x
  for /F "tokens=*" %%x in ('sed -n "/Disk/{n;n;n;p}" requir.out') do set ndiskd1=%%x
  for /F "tokens=*" %%x in ('sed -n "/Disk/{n;n;n;n;p}" requir.out') do set ndiske1=%%x
  for /F "tokens=*" %%x in ('sed -n "/Video Processor/{p}" requir.out') do set vproc=%%x
    set vproc=%vproc:~21%

  :tokens
:: license status
  for /F "tokens=*" %%x in ('sed -n "/Users of standard/{p}" system.out') do set statok=%%x
    set curlic=%statok:~60,-17%
    set maxlic=%statok:~30,-46%
  for /F "tokens=*" %%x in ('sed -n "/Users of standard/{n;n;n;n;n;p}" system.out') do set stalic=%%x

:: T init
  for /F "tokens=*" %%x in ('grep -i nset_all_nodes, abaqus.inp') do set tempinit=%%x
    set tempinit=%tempinit:~16%
    set tinit=%tempinit:~-8%
    if /i %tinit% equ generate set tempinit=non-uniform

:: send logs
  set qlogs=qlogs
  set attach2=

  if %imode% equ inter goto :logs
  if not exist tmp.conf goto :logs else (
    set /p qlogs=<tmp.conf
    set qlogs=%qlogs:~4%
    )
      if /i %qlogs% equ yes (
         set attach2=-attach logs.tar.7z
          sed -i -e "1d" tmp.conf
          goto :mailbox
          )
            if /i %qlogs% equ no (
              set attach2=
                sed -i -e "1d" tmp.conf
                goto :mailbox
                )

  :logs
:: interactive log sending setup
  echo +
  echo +    Logs will send - OK? (Y)
  choice /c YN /t 4 /d y /m "+ 4s"
    if /i %errorlevel%==1 (
      set attach2=-attach logs.tar.7z
      )

  :mailbox
:: read sender from config
  if not exist tmp.conf goto :mailsend else (
    set /p tom=<tmp.conf
    set tom=%tom:~5%
      sed -i -e "1d" tmp.conf
  goto :defmail
  )

  :mailsend
:: define sender
  echo +
  echo +    Mail will be sent to %var%@%city%dosmartec.ru - OK? (Y)
    choice /c YN /t 4 /d y /m "+ 4s"
      if /i %errorlevel%==1 goto :defmail
      if /i %errorlevel%==2 goto :setrep

  :setrep
:: define recepients
  echo +
  echo +    Enter recepients using comma:
  sleep 1 s
  echo +
  echo +    [ex.]  aanikeev@dosmartec.ru,agubsky@dosmartec.ru
  echo +    [ex.] %supmail%
  sleep 1 s
  echo +
  echo +    default: %var%@%city%dosmartec.ru
  sleep 1 s
  echo +
  echo +    Type addresses using comma (,) as separator [addr1,addr2...]
    set /p tom="+    or press ENTER to skip - "

  :defmail
:: choosing e-mail depend on domain
    if /i %userdomain% NEQ SMARTEC-SAM (
      set to=%var%@dosmartec.ru,%tom%
      ) else (
        set to=%var%@samara.dosmartec.ru,%tom%
        )

  :maillist
:: mailbox list
  sleep 1 s
  echo +    Mailbox list:
  echo +    %to%
  sleep 1 s

:: create scratch folder
  if not exist "%cd%\scratch" mkdir "%cd%\scratch"

:: choose number of CPUs, default = max (before year 2014), =2 since JAN2014, =8 since MAR2014
  if not exist tmp.conf goto :numcpu else (
    set /p ncpu=<tmp.conf
    set ncpu=%ncpu:~5%
      sed -i -e "1d" tmp.conf
  goto :newtitle
  )

  :numcpu
  echo +
  :: set ncpu=%number_of_processors%
  :: cpus=2 since 1.5g7 due license limitation (JAN2014)
  :: cpus=8 (MAR2014)
  set ncpu=8
  echo +    Current CPUs: %ncpu% - OK? (Y)
    choice /c YN /t 4 /d y /m "+ 4s"
      if /i %errorlevel%==2 goto :setcpu
      if /i %errorlevel%==1 goto :newtitle

  :setcpu
:: manual select number of CPUs
  echo +
  echo +    Tokens:  %curlic%/%maxlic%
  echo +
  echo +    CPUS   1   2  4   8  12  16  24  32  64  128
  echo +    TOKENS 5   6  8  12  14  16  19  21  28   38
  echo +
    set /p ncpu="+    Select number of CPU(s) (max %number_of_processors%):"
  sleep 1 s

  :newtitle
:: change title
  set cdcd=%cd: =_%
  title %curline%/%last% - %calcul% (%ver% cpus=%ncpu%) - %prj%

:: choose backup folder. Default - no
  if /i %userdomain% EQU SMARTEC-SAM set bak=\\wsrv-4\PRJ\S_CT\backup\%yyyymm%
  if not exist tmp.conf goto :bakfolder else (
    set /p bakfold=<tmp.conf
    set bakfold=%bakfold:~7%
      sed -i -e "1d" tmp.conf
  goto :sendmail1
  )

  :bakfolder
:: folder for backups
  echo +    To enter backup folder press Y (N)
  echo +
    choice /c YN /t 4 /d n /m "+ 4s"
    if /i %errorlevel%==1 (
      set /p bak="+    Select folder for backup or press enter to skip -"
    )
  sleep 1 s
    
  echo +
  echo +    abort.bat   - ABORT
  echo +    suspend.bat - PAUSE
  echo +    resume.bat  - RESUME
  sleep 3 s

  :sendmail1
:: send 1st mail
    set nv=%ncpu:~-6%
    if /i %nv% equ nvidia set gpu=%vproc%

  chcp 1251 >nul 2>&1

  ::zip -9q input.zip abaqus.inp abaqus.cca mech.txt
  rem tar cf input.tar abaqus.cca abaqus.inp mech.txt
  rem lzma e input.tar input.tar.7z
  rem set attach1=-attach input.tar.7z

  blat.exe -server %smtp_ip% %attach1% -f %from% -t %to% -i CalculAba -charset utf-8 -q -subject "%computername% [%prj%] %dt1% %tm1% - S_CT report automatique" -body " %computername% now is busy by %name%/%username% %execmode%|-----------------------------------------------| %comm%|-----------------------------------------------| %chkmess4% | %chkmess1% | %chkmess2% | %chkmess3% ||                 S U M M A R Y%curline%/%last%:|| Server:               %computername% (cpus=%ncpu%)| Model:                %maxelementid% elm.| T init:               %tempinit% oC| WB module:            %wbmodule%| Calcul:               %calcul% (%ctype%)| Project:              %prj%| Abaqus/CAT:           %ver%/%vcat%|-----------------------------------------------| Started:              %dt1% at %tm1%|| S o u r c e   INP:    %srcuns%| W o r k       DIR:    \\%computername%\%curdir%||                 R E P O R T:|| %nproc%| %gpu%|-----------------------------------------------| %nram1%|-----------------------------------------------| %ndiskc1%| %ndiskd1%| %ndiske1%||                 S U P P O R T:||CalculABA %calculaba%|Online help: \\wsrv-1\sites\samara1\DocLib5\S_CT\capitalisation\calculaba||Cordialement|%sign%"

:: start ABAQUS

  echo +
  echo +
  echo +    AAAAAA     BBBBBBBBB      AAAAAA      QQQQQQQQ    U        U    SSSSSSSS
  echo +   A      A    B        B    A      A    Q        Q   U        U   S
  echo +  A        A   B        B   A        A   Q        Q   U        U   S
  echo +  A        A   B        B   A        A   Q        Q   U        U   S
  echo +  AAAAAAAAAA   BBBBBBBBB    AAAAAAAAAA   Q        Q   U        U    SSSSSSSS
  echo +  A        A   B        B   A        A   Q    Q   Q   U        U            S
  echo +  A        A   B        B   A        A   Q     Q  Q   U        U            S
  echo +  A        A   B        B   A        A   Q      Q Q   U        U            S
  echo +  A        A   BBBBBBBBB    A        A    QQQQQQQQ     UUUUUUUU     SSSSSSSS
  echo +
  echo +

  echo = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = >> requir.out

  if %ver% equ 6.7 (
  :: set nvidia=%ncpu:~10%
  :: set ncpu=%ncpu:~0,-10%
  echo %abqexe% job=abaqus ask_delete=off cpus=%ncpu% parallel=tree interactive scratch=scratch > abqx.bat
  )
  if %ver% equ 6.11 echo %abqexe% job=abaqus ask_delete=off cpus=%ncpu% parallel=tree interactive scratch=scratch > abqx.bat
  if %ver% equ 6.12 echo %abqexe% job=abaqus ask_delete=off cpus=%ncpu% parallel=tree interactive scratch=scratch > abqx.bat
  echo %abqexe% job=abaqus terminate > _abort.bat
  echo %abqexe% job=abaqus suspend > _suspend.bat
  echo %abqexe% job=abaqus resume > _resume.bat

  del sed* >nul 2>&1

  :: Starting solver with verbose logging enabled
  call abqx 2>&1 | mtee /c/t calculaba.ses

  echo +

  :cleandat
:: clean logs
  if exist abaqus.dat sed -i -e "/Legends/d" abaqus.dat
  if exist abaqus.msg sed -i -e "/Legends/d" abaqus.msg
  if exist abaqus.dat sed -i -e "/LND/d" abaqus.dat
  if exist abaqus.dat sed -i -e "/Team AWXS/d" abaqus.dat
  if exist abaqus.msg sed -i -e "/Team AWXS/d" abaqus.msg
  if exist abaqus.dat sed -i "s/>/*/g" abaqus.dat
  if exist abaqus.dat sed -i "s/</*/g" abaqus.dat
  if exist abaqus.msg sed -i "s/>/*/g" abaqus.msg
  if exist abaqus.msg sed -i "s/</*/g" abaqus.msg

:: cut logs for errors (100 strings)
  if exist abaqus.msg sed -e :a -e "$q;N;101,$D;ba" abaqus.msg > abaqus_msg.out
  if exist abaqus.dat sed -e :a -e "$q;N;101,$D;ba" abaqus.dat > abaqus_dat.out

  if exist abaqus_msg.out sed -i "s/ERROR: THE ANALYSIS HAS TERMINATED DUE TO PREVIOUS ERRORS/ER_ROR: THE ANALYSIS HAS TERMINATED DUE TO PREVIOUS ER_RORS/g" abaqus_msg.out
  if exist abaqus_msg.out sed -i "s/ERROR MESSAGES/ER_ROR MESSAGES/g" abaqus_msg.out
  if exist abaqus_msg.out sed -i "s/ErrElem/Er_rElem/g" abaqus_msg.out
  if exist abaqus_dat.out sed -i "s/ERROR MESSAGES/ER_ROR MESSAGES/g" abaqus_dat.out
  if exist abaqus_dat.out sed -i "s/FATAL ERRORS/FATAL ER_RORS/g" abaqus_dat.out
  if exist abaqus_dat.out sed -i "s/BECAUSE/BCZ/g" abaqus_dat.out
  if exist abaqus_dat.out sed -i "s/CAUSE OF/ERROR CAUSED/g" abaqus_dat.out

:: read logs after calcul
  call abqx_req >> requir.out

  if %ver% equ 6.7 (
    for /F "tokens=*" %%x in ('sed -n "/System Host ID/{n;n;n;n;n;n;n;p}" requir.out') do set nram2=%%x
    rem set nram2=%nram2:~0,-6%
    )
    if %ver% equ 6.11 (
      for /F "tokens=*" %%x in ('sed -n "/System Host ID/{n;n;n;n;n;n;p}" requir.out') do set nram2=%%x
      )

  for /F "tokens=*" %%x in ('sed -n "/Disk/{n;n;p}" requir.out') do set diskc2=%%x
  for /F "tokens=*" %%x in ('sed -n "/Disk/{n;n;n;p}" requir.out') do set diskd2=%%x
  for /F "tokens=*" %%x in ('sed -n "/Disk/{n;n;n;n;p}" requir.out') do set diske2=%%x

  :: read number of equations
  rem for /F "tokens=*" %%x in ('grep -i "number of equations" abaqus.msg') do set equat=%%x
  rem if exist abaqus.msg set equations=%equat:~,-45%
  rem if exist abaqus.msg set flops=%equat:~45%
  
:: check logs for status anf errors
  if exist abaqus.sta (for /F "tokens=*" %%x in ('tail -1 abaqus.sta') do set status=%%x) else (set status=FAILED)
  if exist abaqus.dat (for /F "tokens=*" %%x in ('grep -i WALLCLOCK abaqus.dat') do set wallclock=%%x)
    set wallh=%wallclock:~28%
      :: divide seconds to 3600
      clc (%wallh%/3600) >wallclock.out
      set /p wallh=<wallclock.out
      :: cut first three symbols
      set wallh=%wallh:~0,3%
  :: check DAT
  if exist abaqus_dat.out for /F "tokens=*" %%x in ('grep -i err abaqus_dat.out') do set errdat=%%x
  if exist abaqus_dat.out for /F "tokens=*" %%x in ('grep -i insufficient abaqus_dat.out') do set errdat=%%x
  :: check MSG
  if exist abaqus_msg.out for /F "tokens=*" %%x in ('grep -i err abaqus_msg.out') do set errmsg=%%x
  :: check SES for error:
  if exist calculaba.ses for /F "tokens=*" %%x in ('grep -i error: calculaba.ses') do set errses=%%x
  :: check SES for abort
  if exist calculaba.ses for /F "tokens=*" %%x in ('grep -i abort calculaba.ses') do set errses=%%x

:: get final date and time
  set date2=%date%
  set time2=%time%
  set tmf=%time2:~0,-6%
  set tm2=%tmf::=.%
  set tm2=%tm2: =0%

:: file suffix depends on status
  set stat=%status:~-5%
    if /i %stat% equ FULLY (
    set filesuffix=OK
      set endstat=Finished:             
      ) else (
        set filesuffix=KO
        set endstat=Aborted:              
        )

:: compress SES and short DAT&MSG
  if exist calculaba.ses (
    ::zip -q9 logs.zip calculaba.ses abaqus_dat.out abaqus_msg.out
    tar cf logs.tar calculaba.ses abaqus_dat.out abaqus_msg.out
    lzma e logs.tar logs.tar.7z
    ) else (
     set attach2=
     )
    
  :purge
:: clean
  rmdir scratch >nul 2>&1
  del sed* *.lst *.bat therm.zip tmp.conf >nul 2>&1

  :sendmail2
:: send 2nd mail
  chcp 1251 >nul 2>&1
  set resultpath=\\%computername%\e\usr\%username%\calculaba\%yyyymm%
  set filezip=%yyyymmdd%_%tm1%_%prj%_%filesuffix%.zip
  
  blat.exe -server %smtp_ip% %attach2% -f %from% -t %to% -i CalculAba -charset utf-8 -q -subject "%computername% [%prj%] %dt1% %tm1% - S_CT report automatique" -body " %status%%curline%/%last%|-----------------------------------------------|                 E R R O R S:|| SES: %errses%| DAT: %errdat%| MSG: %errmsg%||                 S U M M A R Y%curline%/%last%:|| Server:               %computername%| Model:                %maxelementid% elm.| T init:               %tempinit% oC| WB module:            %wbmodule%| Calcul:               %calcul% (%ctype%)| Project:              %prj%| Abaqus/CAT:           %ver%/%vcat%|-----------------------------------------------| Started:              %dt1% at %tm1%| %endstat%%date2% at %tm2%| Used time:            %wallh% h on cpus=%ncpu%|-----------------------------------------------| Engineer:             %name%/%username%||                 R E S U L T:|| S o u r c e: %srcuns%| R e s u l t: %resultpath%\%filezip%| B a c k u p: %bakfold%||                 R E P O R T:|| %nproc%| %gpu%|-----------------------------------------------| %nram2%|-----------------------------------------------| %diskc2%| %diskd2%| %diske2%||Cordialement|-Abaqus"

:: delete log.zip
  del input.tar.7z input.tar logs.tar.7z >nul 2>&1

:: zip, copy and unzip
  zip -q1D "%yyyymmdd%_%tm1%_%prj%_%filesuffix%.zip" * -x *.exe *.cmd exclude.txt config.txt *.zip *.out *.debug tau inst
  if not exist "e:\usr\%username%\calculaba\%yyyymm%" mkdir "e:\usr\%username%\calculaba\%yyyymm%" >nul 2>&1
      mkdir %bakfold% >nul 2>&1
      xcopy /y /q /c "%yyyymmdd%_%tm1%_%prj%_%filesuffix%.zip" %bakfold% >nul 2>&1
  move "%yyyymmdd%_%tm1%_%prj%_%filesuffix%.zip" "e:\usr\%username%\calculaba\%yyyymm%" >nul 2>&1
  rem unzip -q "e:\usr\%username%\calculaba\%yyyymm%\%yyyymmdd%_%tm1%_%prj%_%filesuffix%.zip" -d "e:\usr\%username%\calculaba\%yyyymm%\%yyyymmdd%_%tm1%_%prj%_%filesuffix%"

:: completed message
  echo +
  echo +    TASK %curline%/%last% COMPLETED %DATE2% at %tm2%
  sleep 2 s

:: write statistics
 echo %prj%;%calcul%;%dt1%;%tm1%;%ctype%;%wallh%;%computername%;%ncpu%;%abamem%;%filesuffix%;%username%;%calculaba%;%errses%;%errdat%;%errmsg%;%srcuns%;%resultpath%;%filezip%;%nproc%;%gpu%;%ver%;%vcat%>>T:\S_CT\backup\calculaba.csv
  
:: added in 1.5g6 for proper insert control=30 (30U) UPD: REMOVED IN 1.5g7
::  endlocal disableextensions disabledelayedexpansion
  set ctrl=
  
:: next INP in batch mode
  if %imode% equ inter goto :fin

  :nextinp
:: remove first line in mech.txt and loop for next inp
  sed -i -e "1d" lines.out
  sed -i -e "1d" mech.txt
  del sed* >nul 2>&1
  set /p src=<mech.txt
  if /i %src% equ hare goto :fin else (
    :: clean calcul folder
    del *.inp *.bca *.cca *chamandb *.cid *.com *.csv abaqus.dat *.debug *.env *.fca *.gca *.lck *.mdl abaqus.msg *.odb *.par *.pes *.pmg *.prt *.rca *.sca *.sta *.stt *.trace *.xml *.023 *.aapresults *.rpy *.csv>nul 2>&1
    set ctype=
	set isfirstrun=batch
	goto :readinp
    )

:: Warning messages below...
:: Abort message
  :warnaba
echo +
echo +    CHECK ABAQUS INSTALLATION
echo +
echo +    PRESS ANY KEY TO EXIT
echo +
color c
  del sed* *.bat *.out >nul 2>&1
  goto :fin

:: No CCA message
  :warn_no_cca
  if %curline% neq %last% goto :nextinp
echo +
echo +    C C A DOES NOT EXIST
echo +
echo +    PRESS ANY KEY TO EXIT
echo +
color c
  del sed* *.bat *.out >nul 2>&1
  goto :fin

:: No INP message. This message is OK in case of last batch execution (beta)
  :warn_no_inp
  if %curline% neq %last% goto :nextinp
echo +
echo +    I N P DOES NOT EXIST
echo +
echo +    PRESS ANY KEY TO EXIT
echo +
color c
  del sed* *.bat *.out >nul 2>&1
  goto :fin

:: Unauthorized execution
  :warndomain
echo +
echo +    UNAUTHORIZED ACCESS DETECTED
echo +
echo +    PRESS ANY KEY TO EXIT
echo +
color c
  del sed* *.bat *.out >nul 2>&1
  goto :fin

:: Wrong execution
  :warnexec
echo +
echo +    YOU CANNOT RUN SCRIPT FROM "THERM" FOLDER
echo +
echo +    PRESS ANY KEY TO EXIT
echo +
color c
sleep 4 s
  del sed* *.bat *.out >nul 2>&1
  del sed* calculaba* therm.zip exclude.txt run.cmd & exit /b 0
  pause

:: Insuffisant permissions
  :warnperm
echo +
echo +    WRITE ACCESS DENIED!!
echo +
echo +    PRESS ANY KEY TO EXIT
echo +
color c
  del sed* *.bat *.out >nul 2>&1
  goto :fin

:: Final clean. Now files are ready to load in Workbench or to be sent to client or just nothing. The end.
:: Log off
  :logoff_
title %curline%/%last% %ver% LOGOFF? - %prj%
echo .
echo    =======================================================================
echo                      ATTENTION LOGOFF AFTER 1 HOUR (Y)
echo    =======================================================================
echo .
  echo Local time: 
    time /t
  echo ...
    rem del *.bat abaqus* *.xml *.log *.trace *.csv file*
    choice /c YN /t 3600 /d y /m "logoff after 1 hour?"
      if /i %errorlevel%==1 logoff
      if /i %errorlevel%==2 (
        color
        rem taskkill /IM wscript.exe /F /T
        sleep 2 s
        exit /b 0
        )

  :fin
rem taskkill /IM wscript.exe /F /T >nul 2>&1
del tau inst *.out >nul 2>&1
echo +
echo + Press any key to exit...
echo +
pause > nul
