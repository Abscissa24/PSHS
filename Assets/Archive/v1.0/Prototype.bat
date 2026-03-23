@echo off
setlocal enabledelayedexpansion
set "db=players.db"
set "lock=round.lock"
title PSHS Chess Pairing System - Made by Armiel

:menu
cls
echo [PSHS CHESS PAIRING SYSTEM]
echo. 
echo 1. Add Player
echo 2. View Standings
echo 3. Manage Round
echo 4. Reset DB
echo 5. Exit
set /p c="> "
if "%c%"=="1" goto add
if "%c%"=="2" goto view
if "%c%"=="3" goto round
if "%c%"=="4" goto reset
if "%c%"=="5" exit /b
goto menu

:add
cls
set /p n="Name: "
set /p r="Rating: "
set "r=0000%r%"
set "r=%r:~-4%"
echo 000 %r% %n%>>"%db%"
goto menu

:view
cls
echo PTS  RTG   NAME
echo ----------------
if exist "%db%" (
    for /f "tokens=1,2,*" %%a in ('sort /r "%db%"') do (
        set "pts=%%a"
        echo !pts:~0,-1!.!pts:~-1!  %%b  %%c
    )
)
echo. 
pause
goto menu

:round
cls
if not exist "%db%" echo No players. & echo. &pause & goto menu
if exist "%lock%" goto results

:: LOAD PLAYERS
set "cnt=0"
for /f "tokens=*" %%a in ('sort /r "%db%"') do (
    set /a cnt+=1
    set "p[!cnt!]=%%a"
)

:: GENERATE PAIRINGS
echo --- PAIRINGS ---
echo --- PAIRINGS --- > Pairings.txt
for /l %%i in (1, 2, %cnt%) do (
    set /a j=%%i+1
    call set "p1=%%p[%%i]%%"
    call set "p2=%%p[!j!]%%"
    
    if !j! LEQ %cnt% (
        echo !p1! VS !p2!
        echo !p1! VS !p2! >> Pairings.txt
    ) else (
        echo !p1! - BYE
        echo !p1! - BYE >> Pairings.txt
    )
)
echo. & echo Saved to Pairings.txt & echo 1 > "%lock%"
pause
goto menu

:results
echo --- ENTER RESULTS ---
set "cnt=0"
for /f "tokens=*" %%a in ('sort /r "%db%"') do (set /a cnt+=1 & set "p[!cnt!]=%%a")

copy "%db%" "%db%.bak" >nul
del "%db%"

for /l %%i in (1, 2, %cnt%) do (
    set /a j=%%i+1
    call set "p1=%%p[%%i]%%"
    call set "p2=%%p[!j!]%%"

    if !j! LEQ %cnt% (
        echo Match: !p1! VS !p2!
        set /p r="Win (1=P1, 2=P2, 0=Draw): "
        if "!r!"=="1" (call :calc "!p1!" 10 & call :calc "!p2!" 0)
        if "!r!"=="2" (call :calc "!p1!" 0 & call :calc "!p2!" 10)
        if "!r!"=="0" (call :calc "!p1!" 5 & call :calc "!p2!" 5)
    ) else (
        echo [BYE] !p1!
        call :calc "!p1!" 10
    )
)
del "%lock%"
goto menu

:: ================= RESET =================
:reset
cls
set /p confirm="Type 'YES' to delete all data: "
if /i "%confirm%"=="YES" (
    del "%db%" "%lock%" 2>nul & timeout 1 >nul & goto menu
)
goto menu

:: ================ CALC ================
:calc
set "line=%~1"
set "add=%~2"
for /f "tokens=1,2,*" %%x in ("%line%") do (
    set /a new=1%%x %% 1000 + add
    set "pad=000!new!"
    echo !pad:~-3! %%y %%z>>"%db%"
)
goto :eof