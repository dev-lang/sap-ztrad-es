@echo off
setlocal EnableDelayedExpansion
rem ======================================================================
rem  Reinicio completo de BAS: baja SAP, reinicia Sybase ASE y sube SAP.
rem  Sirve, por ejemplo, para liberar un proceso de ASE que quedo colgado
rem  y que no se puede matar con kill.
rem  Correr como ADMINISTRADOR (clic derecho > Ejecutar como administrador).
rem  No pide ni guarda contrasenas, salvo el paso opcional de "shutdown with
rem  nowait", donde isql pide la de sapsa.
rem ======================================================================

rem --- Ajustar si hace falta ---------------------------------------------
set SID=BAS
set NR=00
set SAPCONTROL=C:\usr\sap\%SID%\SYS\exe\uc\NTAMD64\sapcontrol.exe
set SYBASE=C:\sybase\%SID%
set SYBASE_OCS=OCS-15_0
rem ----------------------------------------------------------------------

set LOG=%~dp0reiniciar_sap_ase.log
echo ==== %date% %time% inicio > "%LOG%"

net session >nul 2>&1
if errorlevel 1 (
    echo Hay que correrlo como administrador.
    pause
    exit /b 1
)
if not exist "%SAPCONTROL%" (
    echo No encuentro sapcontrol en %SAPCONTROL%
    pause
    exit /b 1
)

rem --- Servicios de Sybase (se detectan solos) ----------------------------
set SVC_ASE=
set SVC_BCK=
rem sc muestra "SERVICE_NAME:" o "NOMBRE_SERVICIO:" segun el idioma de Windows: se toma lo que sigue a ":"
for /f "tokens=2 delims=: " %%s in ('sc query state^= all ^| findstr /i /r /c:": *SYBSQL_%SID%"') do set SVC_ASE=%%s
for /f "tokens=2 delims=: " %%s in ('sc query state^= all ^| findstr /i /r /c:": *SYBBCK_%SID%"') do set SVC_BCK=%%s
if "%SVC_ASE%"=="" (
    echo No encuentro el servicio SYBSQL_%SID%. Servicios Sybase instalados:
    sc query state^= all | findstr /i "SYB"
    pause
    exit /b 1
)
echo Servicio ASE:           %SVC_ASE%
echo Servicio Backup Server: %SVC_BCK%
echo Instancia SAP:          %SID% nr %NR%
echo.
echo Se va a BAJAR SAP y reiniciar la base. Los usuarios conectados se cortan.
choice /c SN /m "Seguir"
if errorlevel 2 exit /b 0

rem --- 1) Bajar SAP -------------------------------------------------------
echo.
echo [1/5] Bajando SAP %SID% %NR% ...
"%SAPCONTROL%" -prot PIPE -nr %NR% -function Stop >> "%LOG%" 2>&1
"%SAPCONTROL%" -prot PIPE -nr %NR% -function WaitforStopped 900 10 >> "%LOG%" 2>&1
if errorlevel 1 (
    echo SAP no termino de bajar en 15 minutos ^(ver %LOG%^). No sigo.
    "%SAPCONTROL%" -prot PIPE -nr %NR% -function GetProcessList
    pause
    exit /b 1
)
echo SAP abajo.

rem --- 2) Bajar Sybase ----------------------------------------------------
echo.
echo [2/5] Bajando Sybase ...
if not "%SVC_BCK%"=="" net stop "%SVC_BCK%" >> "%LOG%" 2>&1
rem sc stop no se queda esperando (net stop espera sin limite si ASE no puede bajar)
sc stop "%SVC_ASE%" >> "%LOG%" 2>&1
echo Esperando hasta 2 minutos a que ASE baje ...
call :esperar_estado "%SVC_ASE%" STOPPED 120
if errorlevel 1 (
    echo.
    echo ASE no bajo en 2 minutos ^(por ejemplo, por un proceso que no se puede matar^).
    echo Se puede forzar con "shutdown with nowait": SAP ya esta abajo, y al
    echo arrancar ASE hace la recuperacion normal de la base.
    choice /c SN /m "Forzar shutdown with nowait (isql pide la clave de sapsa)"
    if errorlevel 2 (
        echo No se forzo. ASE sigue arriba y SAP abajo.
        pause
        exit /b 1
    )
    set PATH=%SYBASE%\%SYBASE_OCS%\dll;%SYBASE%\%SYBASE_OCS%\bin;!PATH!
    echo shutdown with nowait> "%TEMP%\zshut.sql"
    echo go>> "%TEMP%\zshut.sql"
    isql -Usapsa -S%SID% -X -i "%TEMP%\zshut.sql" >> "%LOG%" 2>&1
    del "%TEMP%\zshut.sql"
    call :esperar_estado "%SVC_ASE%" STOPPED 120
    if errorlevel 1 (
        echo ASE sigue sin bajar. Revisar %LOG% y el errorlog de ASE.
        pause
        exit /b 1
    )
)
echo Sybase abajo.

rem --- 3) Subir Sybase ----------------------------------------------------
echo.
echo [3/5] Subiendo Sybase ...
net start "%SVC_ASE%" >> "%LOG%" 2>&1
call :esperar_estado "%SVC_ASE%" RUNNING 300
if errorlevel 1 (
    echo ASE no arranco. Revisar el errorlog: %SYBASE%\ASE-15_0\install\%SID%.log
    pause
    exit /b 1
)
if not "%SVC_BCK%"=="" net start "%SVC_BCK%" >> "%LOG%" 2>&1
echo Sybase arriba. Espero 60 s a que recupere las bases ...
timeout /t 60 /nobreak >nul

rem --- 4) Subir SAP -------------------------------------------------------
echo.
echo [4/5] Subiendo SAP %SID% %NR% ...
"%SAPCONTROL%" -prot PIPE -nr %NR% -function Start >> "%LOG%" 2>&1
"%SAPCONTROL%" -prot PIPE -nr %NR% -function WaitforStarted 900 10 >> "%LOG%" 2>&1
if errorlevel 1 (
    echo SAP no termino de subir en 15 minutos ^(ver %LOG%^).
)

rem --- 5) Estado final ----------------------------------------------------
echo.
echo [5/5] Estado:
"%SAPCONTROL%" -prot PIPE -nr %NR% -function GetProcessList
sc query "%SVC_ASE%" | findstr /c:"RUNNING" /c:"STOPPED"
echo ==== %date% %time% fin >> "%LOG%"
echo.
echo Listo. Log: %LOG%
pause
exit /b 0

rem ----------------------------------------------------------------------
rem  :esperar_estado <servicio> <STOPPED|RUNNING> <segundos>
:esperar_estado
set /a _n=%~3/5
:_loop
sc query %1 | findstr /c:"%~2" >nul && exit /b 0
set /a _n-=1
if %_n% LEQ 0 exit /b 1
timeout /t 5 /nobreak >nul
goto _loop
