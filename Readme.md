calculaba
=========


    #####                                        #                 
   #     #   ##   #       ####  #    # #        # #   #####    ##  
   #        #  #  #      #    # #    # #       #   #  #    #  #  # 
   #       #    # #      #      #    # #      #     # #####  #    #
   #       ###### #      #      #    # #      ####### #    # ######
   #     # #    # #      #    # #    # #      #     # #    # #    #
    #####  #    # ######  ####   ####  ###### #     # #####  #    #

This CMD automates Abaqus calculations with CAT

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
:: !abaqus 6.4-1 support

  set calculaba=v1.5g9 Crimea freedom edition

:: released on Github

::  set calculaba=v1.5g8 build 2014.03.06
::
:: abacat for 6.11 updated to v03b02r06_c
:: changed ZIP archiver to LZMA - up to 2 times better compression
:: added Dasha sr01107 to known users
:: added file with outlook rules
:: turned back to cpus=8 (due to license limitation of 12 tokens since March 6)
:: changed timeformat: uderscore changed to zero _1.57 -> 01.57
::
::  set calculaba=v1.5g7 build 2014.01.29
::
:: fixed memory change for abaqus 6.7 (manual/auto)
:: fixed algorythm of config/inp existance, removes old calcul files when config exists
:: new fix for control=30 bug for batch calculations (setlocal commented, code improved)
:: fixed stable-point check and correspond messages
:: fixed frequency check for stable-point (skips this check)
:: fixed 2nd attachment if SES file does not exist
:: fixed batch numbering if projects were added when asked
:: changed number of strings in logs to 100
:: abaqus 6.7x32 support discontinued
:: set default cpus=2 due to license limitation
:: set gpu=nvidia by default
:: set 50% RAM for 6.11 by default
:: added inp & cca to attachment in 1st mail
:: convert local source path to UNC
:: minor code improvements
::
::  set calculaba=v1.5g6 build 2013.09.24
:: control=30 fixed
::
:: set calculaba=v1.5g5 build 2013.09.xx
:: test version with algorythm 'Each calcul in separate folder'
::
::  set calculaba=v1.5g4 build 2013.09.11
:: abacat updated to v03b02r06
:: !tried to add Abaqus 6.7-3 32-bit + abacat v03b02r05 32-bit (e:\temp\6.7-3x32) - failed bcz of MS runtime libraries
:: renamed short logs to .out
:: fixed stopping bcz of missing inp or cca in batch
::
::  set calculaba=v1.5g3 build 2013.09.04
:: wallclock time changed to hours
:: added errors from msg,dat,ses to stats
:: added source, result to stats
:: added cpu/gpu name to stats
::
::  set calculaba=v1.5g2 build 2013.08.29
:: added csv copy (g2)
::
::  set calculaba=v1.5g2 build 2013.08.29
:: fixed controls parameter for 2nd and more calcul (batch)
:: logoff disabled
:: added progress bar (pbar.cmd)
::
::  set calculaba=v1.5g build 2013.08.29
:: added abaqus 6.11 support
:: added gpu support (cpus=8 gpu=nvidia), does not work bcz license
:: fixed abaqus 6.11 ENV file (memory)
:: added batch calculs counter
:: !added model equations (DOF) number
:: !added model FLOPs number
:: improved error filter
:: removed line Drive in email
:: fixed duplicated lines in mech.txt
:: !fixed logoff with taskkill wscript.exe
::
::  set calculaba=v1.5f
:: added statistics T:\S_CT\backup\calculaba.csv
:: added model element number
:: fixed deleting source files in interactive mode
:: fixed abaqus 6.12 ENV file
:: fixed abaqus 6.12 support (memory change)
:: added unpack operation for ODB
:: fixed interactive mode
:: improved batch and config execution
::
::  set calculaba=v1.5ex
:: fixed key.js support
:: ready for full mtee support (run.cmd)
:: fixed batch and config execution
:: added FATAL ERRORS filter to DAT
::  
::  set calculaba=v1.5d
:: added "error:" filter for SES
:: added key.js to PATH - disables locking session
::
::  set calculaba=v1.5c
:: added chcp.com and logoff.exe to PATH
:: improved config using on single calculations (new config)
:: improved batch execution
:: config.txt for batch
:: abaqus 6.11/6.12 beta
:: improved for msk
:: name changed to calculaba.exe
:: added logoff timeout 1 hour
::
::  set calculaba=v1.4
:: added config file support
:: improved find errors
:: removed 1st attachment
:: reduced attachment size
:: added OK/KO status to zip
:: removed license status
:: minor changes
::
::  set calculaba=v1.3
:: full automated launch
:: batch support
:: project name is taken from inp
:: added T init
:: added russian comment
:: added abaqus 6.11 support (beta)
::
::  set calculaba=v1.2
:: reduced number of input parameters
:: added copying files from source (incl. network)
:: added abaqus memory change
:: added freq/temoin fix
:: added controls fix
:: added license status
:: added system info
:: added session file for abaqus solver
:: added backup for ODB after calcul
:: added clean DAT, MSG
:: added WB wizard support
::
::  set calculaba=v1.0/1.13
:: first release
:: added mail notifications
