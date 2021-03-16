@echo off

setlocal enabledelayedexpansion

if not defined in_subprocess (cmd /k set in_subprocess=y ^& %0 %*) & exit )

:: BatchGotAdmin
REM  --> Check for permissions
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params= %*
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"


::
::first time setup
::
set configPath= C:\
if not exist %~dp0config.txt (
  echo EXECUTING FIRST TIME SETUP...
  set /p configPath= set path ssh keys will be generated in usually in C:\Users\YOU_USER_NAME_HERE don't put a slash at the end:
  echo !configPath!> %~dp0config.txt
  echo path set
)


echo INITIALIZING SSH-AGENT SERVICE..

::
::initialization step
::
::read from config for the path
for /f "tokens=1" %%A in (config.txt) do set user=%%A
powershell -command "Set-Service ssh-agent -StartupType Manual"
powershell -command "Start-Service ssh-agent"

::
::Section 1: key generation
::
set /p email=Set email for new key:
echo %email%


echo MAKE SURE YOU USE THE PATH LISTED IN THE CONFIG FILE DURING KEY CREATION

ssh-keygen -t rsa -C "%email%"
echo please go register the key listed above in GitHub BEFORE continuing this script or any of the other scripts
echo if you don't know how to do this, look at the text file AddingKeyManual.txt
pause

::
::Section 2: adding the keys
::
set /p idName=Enter the name of the key that you just used (ex: 'id_rsa) Don't put the actual key here, just the name of the file:


ssh-add %user%/.ssh/%idName%

::
::Section 3: adding keys to config and/or creating new config file
::
set /p account=Enter the account you want to add:
::checks to see if the file 'config' exists. If not, it will use the default config section, otherwise it uses the version that is meant for appending to the original config
::for some reason this didn't work when it was implemented the other way around. Might require more testing
if not exist "%user%\.ssh\config" (
  echo # Account default (work or personal)> %user%\.ssh/config & echo Host github.com>> %user%\.ssh/config & echo  HostName github.com>> %user%\.ssh/config & echo  User git>> %user%\.ssh/config & echo  IdentityFile %user%\.ssh/%idName%>> %user%\.ssh/config
) else (
  echo # Account extra (work or personal)>> %user%\.ssh/config & echo Host github-%account%>> %user%\.ssh/config & echo  HostName github.com>> %user%\.ssh/config & echo  User git>> %user%\.ssh/config & echo  IdentityFile %user%\.ssh/%idName%>> %user%/.ssh/config
)

echo key has been added and configured
pause
exit
