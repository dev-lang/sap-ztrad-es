@echo off
setlocal
rem Fuerza la baja de ASE (BAS) con 'shutdown with nowait'.
rem Usar SOLO con SAP abajo. ASE hace la recuperacion normal al arrancar.
set SYBASE=C:\sybase\BAS
set SYBASE_OCS=OCS-15_0
set PATH=%SYBASE%\%SYBASE_OCS%\dll;%SYBASE%\%SYBASE_OCS%\bin;%PATH%
echo shutdown with nowait> "%TEMP%\zshut.sql"
echo go>> "%TEMP%\zshut.sql"
echo isql va a pedir la contrasena de sapsa (no se muestra al escribir).
isql -Usapsa -SBAS -X -i "%TEMP%\zshut.sql"
del "%TEMP%\zshut.sql"
echo.
echo Si dice que se corto la conexion es lo esperado: ASE se esta bajando.
pause
