@echo off

set /p directory=Enter the directory of the repo:
set /p name=Enter the username of the account you want to use:
set /p email=Enter the email of the account you want to use:
set /p host=Enter the host you set up your key to use (see the config in `USER/.ssh`):

cd %directory%
git config user.name %name%
git config user.email %email%
git remote set-url origin git@%host%:%name%/%~n1.git

echo finished
pause
