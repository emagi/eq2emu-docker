@echo off
setlocal enabledelayedexpansion

:: Path to your .env file
set ENV_FILE=.env
set EXAMPLE_ENV_FILE=.env.example

:: Define descriptions for each _PASSWORD field
:: Add more mappings as needed
set "DESC_MARIADB_PASSWORD=World user database password"
set "DESC_MARIADB_ROOT_PASSWORD=Root password for database"
set "DESC_EQ2LS_DB_PASSWORD=Login user database password"
set "DESC_EQ2DAWN_DB_PASSWORD=EQ2Dawn Web Server user database password"
set "DESC_WORLD_ACCOUNT_PASSWORD=World server login account password"
set "DESC_EQ2DAWN_ADMIN_PASSWORD=Admin user account password for Dawn Web Server Dashboard"
set "DESC_EQ2WORLD_WEB_PASSWORD=EQ2Dawn to World API Password"
set "DESC_EQ2LOGIN_WEB_PASSWORD=EQ2Dawn to Login API Password"
set "DESC_EQ2EDITOR_DB_PASSWORD=EQ2Editor user database password"
set "DESC_EQ2EDITOR_ADMIN_PASSWORD=Admin user password for EQ2Editor DB Web Interface"

:: Check if .env file exists, if not copy from .env.example
if not exist %ENV_FILE% (
    if exist %EXAMPLE_ENV_FILE% (
        echo .env file not found, copying from .env.example...
        copy %EXAMPLE_ENV_FILE% %ENV_FILE%
    ) else (
        echo Neither .env nor .env.example found!
        exit /b 1
    )
)

:: Prompt user for each password if it's set to "<template>"
for /f "tokens=1,2 delims==" %%A in ('findstr /r "_PASSWORD=" %ENV_FILE%') do (
    set var=%%A
    set value=%%B
    set value=!value:"=!
    if "!value!"=="<template>" (
        set desc_var=DESC_!var!
        call set desc=%%!desc_var!%%
        if not defined desc (
            set "desc=Enter value for !var!:"
        ) else (
			call set desc= !desc! "(!var!)"
		)
		:: Display description and read user input
        echo !desc!
		@echo off
		setlocal
		:: Call PowerShell to get the password
		for /f "delims=" %%i in ('powershell -command "$Password = Read-Host 'Enter your password' -AsSecureString; $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password); [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)"') do set "password=%%i"
        echo Password is: !password!
		call :replace_value !var! !password!
		endlocal
    ) else (
        echo Skipping !var! because it is not set to "<template>"
    )
)
:: Prompt user for Docker Compose action
:choose_action
echo.
echo Choose EQ2EMu Server Asction:
echo [1] Start
echo [2] Stop
echo [3] Exit
echo [9] Down (Remove)
set /p action=Enter the number corresponding to your choice: 

if "%action%"=="1" goto :run_docker_up
if "%action%"=="2" goto :run_docker_stop
if "%action%"=="3" goto :end
if "%action%"=="9" goto :run_docker_down
echo Invalid choice. Please try again.
goto :choose_action

:replace_value
    set search=%1
    set replace=%2
    (for /f "usebackq tokens=*" %%i in (`findstr /v /r "^%search%=.*$" %ENV_FILE%`) do @echo %%i) > %ENV_FILE%.tmp
    echo %search%="%replace%">> %ENV_FILE%.tmp
    move /Y %ENV_FILE%.tmp %ENV_FILE%
    goto :eof
	
:run_docker_up
:: Check if the eq2emu-docker container is running by searching for "docker-entrypoint"
docker ps -f name=eq2emu-docker | findstr "docker-entrypoint" >nul 2>&1
if %errorlevel% neq 0 (
    echo eq2emu-docker container not found, starting with docker compose up...
    docker compose up
) else (
    echo eq2emu-docker container found running, did you mean to stop?
)
goto :end

:run_docker_stop
echo Stopping Docker Compose...
docker compose stop
goto :end

:run_docker_down
echo Bringing Docker Compose down...
docker compose down
goto :end

:end
endlocal
