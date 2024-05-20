@ECHO OFF
REM author: Robert-Vincent Lichterfeld <robert.vincent.n@gmail.com>
REM copyright: Robert-Vincent Lichterfeld
REM Set title of window
title Setup and install PyTorch AT Example on Windows
REM Rezize command prompt
mode con: cols=160 lines=40
COLOR 0A
ECHO ---------------
ECHO Logged in user: %USERNAME%
ECHO ---------------
SET CW_DIR=%CD%
REM .... Configure variables ....
SET PYTORCH_AT_Example=%PUBLIC%\NN_PyTorch_AT_Example
SET DEFAULT_VENV_NAME=venv_nn_pytorch
SET DEFAULT_REQUIREMENTS_FILE=requirements_py3_10_win10.txt
SET PROXY_ADDRESS=my-proxy.domain:8000
REM .... Initial information for the user of this file ....
ECHO [i] This script will try to setup and install PyTorch JB Example on Windows
ECHO    [i] The installation needs a disk space of roughly 6 [GB]
ECHO. && ECHO.
TIMEOUT /T 60
REM .... Check if Git is installed ....
ECHO. && ECHO [i] Checkig if 'Git' is installed
FOR /F "delims=" %%g IN ('git --version') DO SET GIT_VERSION=%%g
IF "%GIT_VERSION%" NEQ "" (
    ECHO [i] Git is installed, see details: && ECHO     %GIT_VERSION% && ECHO.
) ELSE (
    COLOR 0C
    ECHO [warning] Please install 'Git'   See: https://git-scm.com/downloads
	START https://git-scm.com/downloads && ECHO.
    GOTO ABORTSETUP
)
REM .... Check environment variable for path to installation of python ....
ECHO. && ECHO [i] Checkig if environment variable for python is available
FOR /F "delims=" %%e IN ('WHERE PYTHON') DO SET PYTHON_INSTALL_PATH=%%e
IF "%PYTHON_INSTALL_PATH%" NEQ "" (
    ECHO [i] Environment variable for python is available, see details: && ECHO     %PYTHON_INSTALL_PATH% && ECHO.
    TIMEOUT /T 3
    GOTO ENVHASPYTHON
) ELSE (
    COLOR 0C
    ECHO [warning] Please install 'Python 3.10'   See: https://www.python.org/downloads/release/python-3100/
	START https://www.python.org/downloads/release/python-3100/ && ECHO.
    GOTO ABORTSETUP
)
:ENVHASPYTHON
REM .... Automatically check if Python in version 3.10 is installed ....
REM ... Replace sections of the string ...
REM Source: https://stackoverflow.com/questions/2772456/string-replacement-in-batch-file
REM # SET REPLACE = ""
REM # CALL SET PYTHON_INSTALL_PATH=%%PYTHON_INSTALL_PATH:\python.exe=%REPLACE%%%
REM # ECHO [i] Path to directory of python executable: %PYTHON_INSTALL_PATH% && ECHO.
REM # CD %PYTHON_INSTALL_PATH%
ECHO [i] Checkig if 'Python' in version '3.10.X' is installed
FOR /F "delims=" %%v IN ('python --version') DO SET PYTHON_VERSION=%%v
IF "%PYTHON_VERSION%" NEQ "" (
    ECHO [i] Python is installed, see details: && ECHO     %PYTHON_VERSION% && ECHO.
    TIMEOUT /T 3
) ELSE (
    COLOR 0C
    ECHO [warning] Please install 'Python 3.10'   See: https://www.python.org/downloads/release/python-3100/
	START https://www.python.org/downloads/release/python-3100/ && ECHO.
    GOTO ABORTSETUP
)
REM .... Check if a proxy should be used ....
ECHO [i] Do you want to use and setup a proxy connection? (y/n)
SET /P INPUT_PROXY=Enter y or n: 
IF /I "%INPUT_PROXY%" =="y" GOTO USEPROXY
GOTO NOPROXY
:USEPROXY
REM User response was y, configure and use proxy
REM Get password for current user
ECHO -----------------------------------------------------------------
ECHO [i] Please enter password for user: %USERNAME% (needed for proxy)
ECHO [i]    You may need to use percent encoding or URL encoding to "escape" special characters of your password   See: https://fabianlee.org/2016/09/07/git-calling-git-clone-using-password-with-special-character/ && ECHO.
ECHO -----------------------------------------------------------------
PAUSE && COLOR 82
SET /P INPUT_PW=Password: 
CLS
REM .... Replace special characters of password ....
REM Source: https://fabianlee.org/2016/09/07/git-calling-git-clone-using-password-with-special-character/
REM .... Replace sections of the string using powershell ....
FOR /F "delims=*" %%p IN ('POWERSHELL -executionpolicy bypass -noninteractive -command "'%INPUT_PW%'.Replace('!', '%21').Replace('#', '%23').Replace('$', '%24').Replace('&', '%26').Replace('(', '%28').Replace(')', '%29').Replace('*', '%2A').Replace('+', '%2B').Replace(',', '%2C').Replace('/', '%2F').Replace(':', '%3A').Replace(';', '%3B').Replace('=', '%3D').Replace('?', '%3F').Replace('@', '%40').Replace('[', '%5B').Replace(']', '%5D')"') DO SET ENCODED_PW=%%p
ECHO [debug] Encoded Password: %ENCODED_PW%
ECHO [i] Hit Ctrl + C to abort the setup
TIMEOUT /T 30 && CLS && COLOR 0A
REM .... Ask if current and edited global git configuration should be stored ....
ECHO. && ECHO --------------
ECHO [!] ATTENTION: This setup will unset the global http proxy, the global credential helper of the git configuration and delete stored login information (see CMDKEY /LIST) containing the following string: git:http://in && ECHO --------------
ECHO [i] Do you want to store the current and edited global git configuration at your desktop? (y/n)
SET /P INPUT_STORE_GIT_CFG=Enter y or n: 
IF /I "%INPUT_STORE_GIT_CFG%" =="y" GOTO STOREGITCFG
GOTO DISCARDGITCFG
:DISCARDGITCFG
REM .... Configure global configuration of git ....
REM Configure git credential helper
git config --global credential.helper manager-core
REM Configure git http proxy
git config --global http.proxy http://%USERNAME%:%ENCODED_PW%@internet-proxy-muc.mn-man.biz:8000
REM Skip code to store the current and edited global git configuration
GOTO AFTERSTORINGOFGITCFG
:STOREGITCFG
REM ---- Store current global git configuration in a text file ----
ECHO [i] Storing current global configuration of git from %COMPUTERNAME% of user '%USERNAME%' to a text file...
REM Get current date and time
FOR /F "delims=" %%d IN ('DATE /T') DO SET CURRENT_DATE=%%d
FOR /F "delims=" %%t IN ('TIME /T') DO SET CURRENT_TIME=%%t
REM Write the text file
ECHO __________________________________________________________________________________________________________ >>"%HOMEPATH%\Desktop\%COMPUTERNAME%_%USERNAME%_CURRENT_GIT_CONFIG.txt"
ECHO __________________________________________________________________________________________________________ >>"%HOMEPATH%\Desktop\%COMPUTERNAME%_%USERNAME%_CURRENT_GIT_CONFIG.txt"
ECHO Stored current global configuration of git    %CURRENT_DATE% - %CURRENT_TIME% >>"%HOMEPATH%\Desktop\%COMPUTERNAME%_%USERNAME%_CURRENT_GIT_CONFIG.txt"
ECHO ---------------------------------------------------------------------- >>"%HOMEPATH%\Desktop\%COMPUTERNAME%_%USERNAME%_CURRENT_GIT_CONFIG.txt"
ECHO You can view your current windows access information by entering the following path into your explorer: >>"%HOMEPATH%\Desktop\%COMPUTERNAME%_%USERNAME%_CURRENT_GIT_CONFIG.txt"
ECHO Systemsteuerung\Benutzerkonten\Anmeldeinformationsverwaltung >>"%HOMEPATH%\Desktop\%COMPUTERNAME%_%USERNAME%_CURRENT_GIT_CONFIG.txt"
ECHO. >>"%HOMEPATH%\Desktop\%COMPUTERNAME%_%USERNAME%_CURRENT_GIT_CONFIG.txt"
ECHO Enter the following command into a command promt shell to edit your global configuration of git: >>"%HOMEPATH%\Desktop\%COMPUTERNAME%_%USERNAME%_CURRENT_GIT_CONFIG.txt"
ECHO git config --global --edit >>"%HOMEPATH%\Desktop\%COMPUTERNAME%_%USERNAME%_CURRENT_GIT_CONFIG.txt"
ECHO. >>"%HOMEPATH%\Desktop\%COMPUTERNAME%_%USERNAME%_CURRENT_GIT_CONFIG.txt"
ECHO ........................ >>"%HOMEPATH%\Desktop\%COMPUTERNAME%_%USERNAME%_CURRENT_GIT_CONFIG.txt"
ECHO Example configuration >>"%HOMEPATH%\Desktop\%COMPUTERNAME%_%USERNAME%_CURRENT_GIT_CONFIG.txt"
ECHO ........................ >>"%HOMEPATH%\Desktop\%COMPUTERNAME%_%USERNAME%_CURRENT_GIT_CONFIG.txt"
ECHO [credential] >>"%HOMEPATH%\Desktop\%COMPUTERNAME%_%USERNAME%_CURRENT_GIT_CONFIG.txt"
ECHO         helper = manager-core >>"%HOMEPATH%\Desktop\%COMPUTERNAME%_%USERNAME%_CURRENT_GIT_CONFIG.txt"
ECHO [http] >>"%HOMEPATH%\Desktop\%COMPUTERNAME%_%USERNAME%_CURRENT_GIT_CONFIG.txt"
ECHO         proxy = http://%USERNAME%:MyPassword@%PROXY_ADDRESS% >>"%HOMEPATH%\Desktop\%COMPUTERNAME%_%USERNAME%_CURRENT_GIT_CONFIG.txt"
ECHO. >>"%HOMEPATH%\Desktop\%COMPUTERNAME%_%USERNAME%_CURRENT_GIT_CONFIG.txt"
ECHO. >>"%HOMEPATH%\Desktop\%COMPUTERNAME%_%USERNAME%_CURRENT_GIT_CONFIG.txt"
ECHO __________________________________________________________________________________________________________ >>"%HOMEPATH%\Desktop\%COMPUTERNAME%_%USERNAME%_CURRENT_GIT_CONFIG.txt"
ECHO Entries of current global configuration of git (git config --list --global)>>"%HOMEPATH%\Desktop\%COMPUTERNAME%_%USERNAME%_CURRENT_GIT_CONFIG.txt"
ECHO ------------------------------------------------- >>"%HOMEPATH%\Desktop\%COMPUTERNAME%_%USERNAME%_CURRENT_GIT_CONFIG.txt"
FOR /F "delims=" %%c IN ('git config --list --global') DO ECHO %%c >>"%HOMEPATH%\Desktop\%COMPUTERNAME%_%USERNAME%_CURRENT_GIT_CONFIG.txt"
ECHO. >>"%HOMEPATH%\Desktop\%COMPUTERNAME%_%USERNAME%_CURRENT_GIT_CONFIG.txt"
COLOR 09
REM .... Configure global configuration of git ....
REM Configure git credential helper
git config --global credential.helper manager-core
REM Configure git http proxy
git config --global http.proxy http://%USERNAME%:%ENCODED_PW%@internet-proxy-muc.mn-man.biz:8000
ECHO ................. && ECHO [i] Cloning repositories && ECHO ................. && TIMEOUT /T 3
REM Configure git credential helper
git config --global credential.helper manager-core
REM Configure git http proxy
git config --global http.proxy http://%USERNAME%:%ENCODED_PW%@internet-proxy-muc.mn-man.biz:8000
REM ---- Store current edited global git configuration in a text file ----
ECHO [i] Storing current edited global configuration of git from %COMPUTERNAME% of user '%USERNAME%' to a text file...
REM Get current date and time
FOR /F "delims=" %%d IN ('DATE /T') DO SET CURRENT_DATE=%%d
FOR /F "delims=" %%t IN ('TIME /T') DO SET CURRENT_TIME=%%t
REM Write the text file
ECHO __________________________________________________________________________________________________________ >>"%HOMEPATH%\Desktop\%COMPUTERNAME%_%USERNAME%_EDITED_GIT_CONFIG.txt"
ECHO __________________________________________________________________________________________________________ >>"%HOMEPATH%\Desktop\%COMPUTERNAME%_%USERNAME%_EDITED_GIT_CONFIG.txt"
ECHO Stored current edited global configuration of git    %CURRENT_DATE% - %CURRENT_TIME% >>"%HOMEPATH%\Desktop\%COMPUTERNAME%_%USERNAME%_EDITED_GIT_CONFIG.txt"
ECHO ---------------------------------------------------------------------- >>"%HOMEPATH%\Desktop\%COMPUTERNAME%_%USERNAME%_EDITED_GIT_CONFIG.txt"
ECHO You can view your current windows access information by entering the following path into your explorer: >>"%HOMEPATH%\Desktop\%COMPUTERNAME%_%USERNAME%_EDITED_GIT_CONFIG.txt"
ECHO Systemsteuerung\Benutzerkonten\Anmeldeinformationsverwaltung >>"%HOMEPATH%\Desktop\%COMPUTERNAME%_%USERNAME%_EDITED_GIT_CONFIG.txt"
ECHO. >>"%HOMEPATH%\Desktop\%COMPUTERNAME%_%USERNAME%_EDITED_GIT_CONFIG.txt"
ECHO Enter the following command into a command promt shell to edit your global configuration of git: >>"%HOMEPATH%\Desktop\%COMPUTERNAME%_%USERNAME%_EDITED_GIT_CONFIG.txt"
ECHO git config --global --edit >>"%HOMEPATH%\Desktop\%COMPUTERNAME%_%USERNAME%_EDITED_GIT_CONFIG.txt"
ECHO. >>"%HOMEPATH%\Desktop\%COMPUTERNAME%_%USERNAME%_EDITED_GIT_CONFIG.txt"
ECHO ........................ >>"%HOMEPATH%\Desktop\%COMPUTERNAME%_%USERNAME%_EDITED_GIT_CONFIG.txt"
ECHO Example configuration >>"%HOMEPATH%\Desktop\%COMPUTERNAME%_%USERNAME%_EDITED_GIT_CONFIG.txt"
ECHO ........................ >>"%HOMEPATH%\Desktop\%COMPUTERNAME%_%USERNAME%_EDITED_GIT_CONFIG.txt"
ECHO [credential] >>"%HOMEPATH%\Desktop\%COMPUTERNAME%_%USERNAME%_EDITED_GIT_CONFIG.txt"
ECHO         helper = manager-core >>"%HOMEPATH%\Desktop\%COMPUTERNAME%_%USERNAME%_EDITED_GIT_CONFIG.txt"
ECHO [http] >>"%HOMEPATH%\Desktop\%COMPUTERNAME%_%USERNAME%_EDITED_GIT_CONFIG.txt"
ECHO         proxy = http://%USERNAME%:MyPassword@%PROXY_ADDRESS% >>"%HOMEPATH%\Desktop\%COMPUTERNAME%_%USERNAME%_EDITED_GIT_CONFIG.txt"
ECHO. >>"%HOMEPATH%\Desktop\%COMPUTERNAME%_%USERNAME%_EDITED_GIT_CONFIG.txt"
ECHO. >>"%HOMEPATH%\Desktop\%COMPUTERNAME%_%USERNAME%_EDITED_GIT_CONFIG.txt"
ECHO __________________________________________________________________________________________________________ >>"%HOMEPATH%\Desktop\%COMPUTERNAME%_%USERNAME%_EDITED_GIT_CONFIG.txt"
ECHO Entries of current edited global configuration of git (git config --list --global)>>"%HOMEPATH%\Desktop\%COMPUTERNAME%_%USERNAME%_EDITED_GIT_CONFIG.txt"
ECHO ------------------------------------------------- >>"%HOMEPATH%\Desktop\%COMPUTERNAME%_%USERNAME%_EDITED_GIT_CONFIG.txt"
FOR /F "delims=" %%c IN ('git config --list --global') DO ECHO %%c >>"%HOMEPATH%\Desktop\%COMPUTERNAME%_%USERNAME%_EDITED_GIT_CONFIG.txt"
ECHO. >>"%HOMEPATH%\Desktop\%COMPUTERNAME%_%USERNAME%_CURRENT_GIT_CONFIG.txt"
:AFTERSTORINGOFGITCFG
REM ---- Update pip ----
ECHO [i] Ensure that pip is installed (package installer for python)
ECHO [debug] Changing directory
CD %PYTHON_INSTALL_PATH%
python -m ensurepip --upgrade
python -m ensurepip --default-pip
ECHO [i] Upgrading pip... && TIMEOUT /T 3
python -m pip --proxy http://%USERNAME%:%ENCODED_PW%@%PROXY_ADDRESS% install --upgrade pip
python -m pip --proxy http://%USERNAME%:%ENCODED_PW%@%PROXY_ADDRESS% install --upgrade pip setuptools wheel
ECHO [i] Installing package virtualenv with flag --user
python -m pip --proxy http://%USERNAME%:%ENCODED_PW%@%PROXY_ADDRESS% install --user virtualenv
ECHO [i] Upgrading setuptools
python -m pip --proxy http://%USERNAME%:%ENCODED_PW%@%PROXY_ADDRESS% install --upgrade pip setuptools
REM ---- Show some information prior to creation of virtual environment ----
IF NOT EXIST "%PYTORCH_AT_Example%" MKDIR "%PYTORCH_AT_Example%"
ECHO [i] Changing directory to where the virtual environment will be created and showing content of directory...
REM #CD %CW_DIR% && DIR && ECHO.
REM #START explorer.exe "%CW_DIR%"
CD %PYTORCH_AT_Example% && DIR && ECHO.
START explorer.exe "%PYTORCH_AT_Example%"
REM ---- Setup and configure virtual environment ----
ECHO -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
ECHO [i] Please enter infromation about the new virtual environment, which will be used by python
ECHO [i]    Default name of the virtual environment: %DEFAULT_VENV_NAME%
SET /P VENV_NAME=Please enter name of virtual environment (Hit RETURN to use the default): 
IF "%VENV_NAME%" EQU "" (
    GOTO DEVAULTVENVNAME
) ELSE (
    GOTO INPUTVENVNAME
)
:DEVAULTVENVNAME
REM Reset variable
SET VENV_NAME = ""
SET VENV_NAME=%DEFAULT_VENV_NAME%
ECHO [i] Using default virtual environment: %VENV_NAME%
GOTO SETUPVIRTUALENV
:INPUTVENVNAME
ECHO [i] Using entered virtual environment: %VENV_NAME%
:SETUPVIRTUALENV
ECHO [debug] Changing directory
CD %PYTHON_INSTALL_PATH%
ECHO [i] Showing information about package virtualenv && TIMEOUT /T 3
python -m pip show virtualenv
ECHO [i] Creating virtual environment "%VENV_NAME%" && TIMEOUT /T 3
python -m virtualenv %PYTORCH_AT_Example%\%VENV_NAME%
ECHO. && ECHO [i] Activating virtual environment "%VENV_NAME%" and check with WHERE PYTHON in new command line shell
START CMD /C CD %PYTORCH_AT_Example% ^& %VENV_NAME%\Scripts\activate ^& title=Check_python_env ^& ECHO [i] Checking for available python environments... ^& WHERE PYTHON ^& deactivate ^& TIMEOUT /T 10
REM ....Check and select a suitable file which contains the required python packages ....
REM # Source - Shell script operators: https://stackoverflow.com/a/47385593
ECHO -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
ECHO [i] Please make sure a suitable file which contains the required python packages will be used!
ECHO [i]    Default requirements file: %DEFAULT_REQUIREMENTS_FILE%
SET /P REQUIREMENTS_FILE=Please enter name and file extension of file containing the required python packages (Hit RETURN to use the default): 
IF "%REQUIREMENTS_FILE%" EQU "" (
	GOTO DEFAULTREQUIREMENTSFILE
) ELSE (
	GOTO INPUTREQUIREMENTSFILE
)
:DEFAULTREQUIREMENTSFILE
SET REQUIREMENTS_FILE = ""
SET REQUIREMENTS_FILE=%DEFAULT_REQUIREMENTS_FILE%
ECHO [i] Using default requirements file: %REQUIREMENTS_FILE%
GOTO PIPINSTALLREQUIREMENTS
:INPUTREQUIREMENTSFILE
ECHO [i] Using entered requirements file: %REQUIREMENTS_FILE%
:PIPINSTALLREQUIREMENTS
ECHO [i] Installing required packages using pip (package installer for python)
REM #%CW_DIR%\\%VENV_NAME%\\Scripts\\python.exe -m pip --proxy http://%USERNAME%:%ENCODED_PW%@%PROXY_ADDRESS% install --upgrade pip
REM #%CW_DIR%\\%VENV_NAME%\\Scripts\\python.exe -m pip --proxy http://%USERNAME%:%ENCODED_PW%@%PROXY_ADDRESS% install --upgrade pip setuptools wheel
REM #%CW_DIR%\\%VENV_NAME%\\Scripts\\python.exe -m pip --proxy http://%USERNAME%:%ENCODED_PW%@%PROXY_ADDRESS% install -r %CW_DIR%\%REQUIREMENTS_FILE%
%PYTORCH_AT_Example%\\%VENV_NAME%\\Scripts\\python.exe -m pip --proxy http://%USERNAME%:%ENCODED_PW%@%PROXY_ADDRESS% install --upgrade pip
%PYTORCH_AT_Example%\\%VENV_NAME%\\Scripts\\python.exe -m pip --proxy http://%USERNAME%:%ENCODED_PW%@%PROXY_ADDRESS% install --upgrade pip setuptools wheel
%PYTORCH_AT_Example%\\%VENV_NAME%\\Scripts\\python.exe -m pip --proxy http://%USERNAME%:%ENCODED_PW%@%PROXY_ADDRESS% install -r %PYTORCH_AT_Example%\%REQUIREMENTS_FILE%
REM .... Check and select a suitable version of PyTorch ....
SET DEFAULT_INSTALL_PYTORCH=torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
ECHO -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
ECHO [i] Please make sure a suitable version of PyTorch (if necesary with pre compiled CUDA support) will be used!
ECHO [i]    Default command (python_from_virtual_env -m pip install): %DEFAULT_INSTALL_PYTORCH%
ECHO [i]        Get a command for a localy suitable version by visiting the following website
ECHO [i]        https://pytorch.org/get-started/locally/
START https://pytorch.org/get-started/locally/
ECHO.
SET /P INSTALL_PYTORCH=Please enter the command for a localy suitable version of PyTorch (Hit RETURN to use the default): 
IF "%INSTALL_PYTORCH%" EQU "" (
    GOTO DEFAULTINSTALLTORCH
) ELSE (
	GOTO INPUTINSTALLTORCH
)
:DEFAULTINSTALLTORCH
SET INSTALL_PYTORCH = ""
SET INSTALL_PYTORCH=%DEFAULT_INSTALL_PYTORCH%
ECHO [i] Using default command for the installation of PyTorch: %INSTALL_PYTORCH%
GOTO PIPINSTALLPYTORCH
:INPUTINSTALLTORCH
ECHO [i] Using entered command for the installation of PyTorch: %INSTALL_PYTORCH%
:PIPINSTALLPYTORCH
ECHO [i] Installing selected version of PyTorch using pip (package installer for python)
REM #%CW_DIR%\\%VENV_NAME%\\Scripts\\python.exe -m pip --proxy http://%USERNAME%:%ENCODED_PW%@%PROXY_ADDRESS% install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
%PYTORCH_AT_Example%\\%VENV_NAME%\\Scripts\\python.exe -m pip --proxy http://%USERNAME%:%ENCODED_PW%@%PROXY_ADDRESS% install %INSTALL_PYTORCH%
ECHO -------------------------
ECHO [i] Do you want to remove data of your credentials from your git configuration? (y/n)
SET /P INPUT_REMOVE_GIT_CFG=Enter y or n: 
IF /I "%INPUT_REMOVE_GIT_CFG%" =="y" GOTO RESETGITCONFIGANDPW
GOTO SETUPFINISHED
:NOPROXY
REM ---- Update pip ----
ECHO [i] Ensure that pip is installed (package installer for python)
ECHO [debug] Changing directory
CD %PYTHON_INSTALL_PATH%
python -m ensurepip --upgrade
python -m ensurepip --default-pip
ECHO [i] Upgrading pip... && TIMEOUT /T 3
python -m pip install --upgrade pip
python -m pip install --upgrade pip setuptools wheel
ECHO [i] Installing package virtualenv with flag --user
python -m pip install --user virtualenv
ECHO [i] Upgrading setuptools
python -m pip install --upgrade pip setuptools
REM ---- Show some information prior to creation of virtual environment ----
IF NOT EXIST "%PYTORCH_AT_Example%" MKDIR "%PYTORCH_AT_Example%"
ECHO [i] Changing directory to where the virtual environment will be created and showing content of directory...
REM #CD %CW_DIR% && DIR && ECHO.
REM #START explorer.exe "%CW_DIR%"
CD %PYTORCH_AT_Example% && DIR && ECHO.
START explorer.exe "%PYTORCH_AT_Example%"
REM ---- Setup and configure virtual environment ----
ECHO -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
ECHO [i] Please enter infromation about the new virtual environment, which will be used by python
ECHO [i]    Default name of the virtual environment: %DEFAULT_VENV_NAME%
SET /P VENV_NAME=Please enter name of virtual environment (Hit RETURN to use the default): 
IF "%VENV_NAME%" EQU "" (
    GOTO DEVAULTVENVNAME
) ELSE (
    GOTO INPUTVENVNAME
)
:DEVAULTVENVNAME
REM Reset variable
SET VENV_NAME = ""
SET VENV_NAME=%DEFAULT_VENV_NAME%
ECHO [i] Using default virtual environment: %VENV_NAME%
GOTO SETUPVIRTUALENV
:INPUTVENVNAME
ECHO [i] Using entered virtual environment: %VENV_NAME%
:SETUPVIRTUALENV
ECHO [debug] Changing directory
CD %PYTHON_INSTALL_PATH%
ECHO [i] Showing information about package virtualenv && TIMEOUT /T 3
python -m pip show virtualenv
ECHO [i] Creating virtual environment "%VENV_NAME%" && TIMEOUT /T 3
python -m virtualenv %PYTORCH_AT_Example%\%VENV_NAME%
ECHO. && ECHO [i] Activating virtual environment "%VENV_NAME%" and check with WHERE PYTHON in new command line shell
START CMD /C CD %PYTORCH_AT_Example% ^& %VENV_NAME%\Scripts\activate ^& title=Check_python_env ^& ECHO [i] Checking for available python environments... ^& WHERE PYTHON ^& deactivate ^& TIMEOUT /T 10
REM ....Check and select a suitable file which contains the required python packages ....
REM # Source - Shell script operators: https://stackoverflow.com/a/47385593
ECHO -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
ECHO [i] Please make sure a suitable file which contains the required python packages will be used!
ECHO [i]    Default requirements file: %DEFAULT_REQUIREMENTS_FILE%
SET /P REQUIREMENTS_FILE=Please enter name and file extension of file containing the required python packages (Hit RETURN to use the default): 
IF "%REQUIREMENTS_FILE%" EQU "" (
	GOTO DEFAULTREQUIREMENTSFILE
) ELSE (
	GOTO INPUTREQUIREMENTSFILE
)
:DEFAULTREQUIREMENTSFILE
SET REQUIREMENTS_FILE = ""
SET REQUIREMENTS_FILE=%DEFAULT_REQUIREMENTS_FILE%
ECHO [i] Using default requirements file: %REQUIREMENTS_FILE%
GOTO PIPINSTALLREQUIREMENTS
:INPUTREQUIREMENTSFILE
ECHO [i] Using entered requirements file: %REQUIREMENTS_FILE%
:PIPINSTALLREQUIREMENTS
ECHO [i] Installing required packages using pip (package installer for python)
REM #%CW_DIR%\\%VENV_NAME%\\Scripts\\python.exe -m pip install --upgrade pip
REM #%CW_DIR%\\%VENV_NAME%\\Scripts\\python.exe -m pip install --upgrade pip setuptools wheel
REM #%CW_DIR%\\%VENV_NAME%\\Scripts\\python.exe -m pip install -r %REQUIREMENTS_FILE%
%PYTORCH_AT_Example%\\%VENV_NAME%\\Scripts\\python.exe -m pip install --upgrade pip
%PYTORCH_AT_Example%\\%VENV_NAME%\\Scripts\\python.exe -m pip install --upgrade pip setuptools wheel
%PYTORCH_AT_Example%\\%VENV_NAME%\\Scripts\\python.exe -m pip install -r %PYTORCH_AT_Example%\%REQUIREMENTS_FILE%
REM .... Check and select a suitable version of PyTorch ....
SET DEFAULT_INSTALL_PYTORCH=torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
ECHO -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
ECHO [i] Please make sure a suitable version of PyTorch (if necesary with pre compiled CUDA support) will be used!
ECHO [i]    Default command (python_from_virtual_env -m pip install): %DEFAULT_INSTALL_PYTORCH%
ECHO [i]        Get a command for a localy suitable version by visiting the following website
ECHO [i]        https://pytorch.org/get-started/locally/
START https://pytorch.org/get-started/locally/
ECHO.
SET /P INSTALL_PYTORCH=Please enter the command for a localy suitable version of PyTorch (Hit RETURN to use the default): 
IF "%INSTALL_PYTORCH%" EQU "" (
    GOTO DEFAULTINSTALLTORCH
) ELSE (
	GOTO INPUTINSTALLTORCH
)
:DEFAULTINSTALLTORCH
SET INSTALL_PYTORCH = ""
SET INSTALL_PYTORCH=%DEFAULT_INSTALL_PYTORCH%
ECHO [i] Using default command for the installation of PyTorch: %INSTALL_PYTORCH%
GOTO PIPINSTALLPYTORCH
:INPUTINSTALLTORCH
ECHO [i] Using entered command for the installation of PyTorch: %INSTALL_PYTORCH%
:PIPINSTALLPYTORCH
ECHO [i] Installing selected version of PyTorch using pip (package installer for python)
%PYTORCH_AT_Example%\\%VENV_NAME%\\Scripts\\python.exe -m pip  install %INSTALL_PYTORCH%
ECHO -------------------------
ECHO [i] Do you want to remove data of your credentials from your git configuration? (y/n)
SET /P INPUT_REMOVE_GIT_CFG=Enter y or n: 
IF /I "%INPUT_REMOVE_GIT_CFG%" =="y" GOTO RESETGITCONFIGANDPW
GOTO SETUPFINISHED
:RESETGITCONFIGANDPW
REM Reset information regarding git configuration and user password
REM Configure git http proxy
git config --global --unset http.proxy
REM     git config --global http.proxy http://default_username:defalut_password@internet-proxy-muc.mn-man.biz:8000
REM     git config --global --unset http.proxy
REM Configure credential manager
git config --global --unset credential.helper
REM Reset user password
SET INPUT_PW = ""
SET ENCODED_PW = ""
REM ---- Finding, showing and deleting credential for git ----
FOR /F "delims=" %%k IN ('CMDKEY /LIST ^| FINDSTR git:http://in') DO SET CMD_KEY_GIT=%%k
ECHO [debug] CMDKEY for git: %CMD_KEY_GIT%
REM .... Replace sections of the string ....
REM Source: https://stackoverflow.com/questions/2772456/string-replacement-in-batch-file
SET REPLACE = ""
CALL SET CMD_KEY_GIT=%%CMD_KEY_GIT:Ziel: LegacyGeneric:target=%REPLACE%%%
ECHO [debug] CMDKEY croase target-name: %CMD_KEY_GIT%
REM .... Replace sections of the string using powershell ....
FOR /F "delims=*" %%k IN ('POWERSHELL -executionpolicy bypass -noninteractive -command "'%CMD_KEY_GIT%'.Replace('=', '').Replace(' ', '')"') DO SET KEY_GIT=%%k
ECHO [debug] CMDKEY target-name: %KEY_GIT%
REM .... Showing and deleting credentials ....
REM Source: https://www.thewindowsclub.com/manage-credential-manager-using-command-prompt?utm_content=cmp-true
ECHO [i] Showing currently stored credentials regarding target-name: %KEY_GIT%
CMD /C CMDKEY /LIST:%KEY_GIT%
ECHO --------- && ECHO [i] Deleting stored credentials regarding target-name: %KEY_GIT% && ECHO --------- 
CMD /C CMDKEY /DELETE:%KEY_GIT%
CMD /C CMDKEY /LIST:%KEY_GIT%
TIMEOUT /T 60
GOTO SETUPFINISHED
:ABORTSETUP
COLOR 0C
ECHO Aborting setup... && TIMEOUT /T 60
:SETUPFINISHED
COLOR 0A
ECHO Setup finished... && TIMEOUT /T 60
COLOR 07
