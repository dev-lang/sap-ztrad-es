@echo off
setlocal
rem ======================================================================
rem  Corre un .sql con isql de Sybase ASE y deja el log al lado del .sql.
rem  Uso:  correr_sql.bat <archivo.sql>      ->  <archivo>.log
rem  isql pide la contrasena del usuario (no se muestra al escribir).
rem  Nunca poner la contrasena en este archivo ni pasarla con -P.
rem ======================================================================

rem --- Ajustar a la instalacion -----------------------------------------
set SYB_SERVER=BAS
set SYB_USER=sapsa
set SYBASE=C:\sybase\BAS
set SYBASE_OCS=OCS-15_0
rem ----------------------------------------------------------------------

if "%~1"=="" (
    echo Uso: %~nx0 ^<archivo.sql^>
    exit /b 1
)
if not exist "%~f1" (
    echo No existe: %~f1
    exit /b 1
)
set SQLFILE=%~f1
set LOGFILE=%~dpn1.log

rem isql necesita las dll de OCS en el PATH (si no: falta libsybcs.dll)
set PATH=%SYBASE%\%SYBASE_OCS%\dll;%SYBASE%\%SYBASE_OCS%\bin;%PATH%
cd /d %SYBASE%\%SYBASE_OCS%\bin

echo Archivo: %SQLFILE%
echo Log:     %LOGFILE%
echo isql va a pedir la contrasena de %SYB_USER% (no se muestra al escribir).
isql -U%SYB_USER% -S%SYB_SERVER% -X -w 300 -i "%SQLFILE%" -o "%LOGFILE%"
echo Listo. Revisar el log: %LOGFILE%
endlocal
pause
