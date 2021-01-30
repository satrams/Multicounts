@echo off

set /p directory=Enter the directory of the repo:
set /p name=Enter the username of the account you want to use:
set /p email=Enter the email of the account you want to use:

cd %directory%
git config user.name %name%
git config user.email %email%


echo finished
pause
