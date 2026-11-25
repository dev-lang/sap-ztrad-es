@echo off
setlocal enabledelayedexpansion
rem ================================================================
rem  comprimir_backups.bat
rem  Comprime con 7-Zip cada .dmp SIN comprimir de la carpeta del NAS.
rem  Para cada uno: comprime en C:\backup-SYB\tmp7z, verifica (7z t),
rem  copia el .7z al NAS y compara tamanos. NO borra nada: al final
rem  lista que .dmp ya se pueden borrar a mano.
rem  Los dumps de hoy (paso2/final) ya estan comprimidos y se saltean.
rem ================================================================
set NAS=\\NAS45E4A6\Public\backup_SYB
set TMP7=C:\backup-SYB\tmp7z
set Z="C:\Program Files\7-Zip\7z.exe"
set LOG=C:\backup-SYB\restore_es\comprimir_backups.log

if not exist %Z% (
  echo No se encontro 7-Zip en C:\Program Files\7-Zip. Instalalo y volve a correr.
  exit /b 1
)
if not exist "%TMP7%" mkdir "%TMP7%"
echo Inicio %date% %time% > "%LOG%"

for %%F in ("%NAS%\*.dmp") do (
  set NAME=%%~nF
  echo !NAME! | findstr /i "paso2 final" >nul
  if !errorlevel! == 0 (
    echo [SALTEADO] %%~nxF ya esta comprimido por Sybase >> "%LOG%"
  ) else if exist "%NAS%\%%~nF.7z" (
    echo [SALTEADO] %%~nF.7z ya existe en el NAS >> "%LOG%"
  ) else (
    echo === %%~nxF ===
    echo === %%~nxF  %%~zF bytes  %time% >> "%LOG%"
    %Z% a -t7z -mx=5 -mmt=on "%TMP7%\%%~nF.7z" "%%F" >> "%LOG%" 2>&1
    if errorlevel 1 (
      echo [ERROR] al comprimir %%~nxF >> "%LOG%"
    ) else (
      %Z% t "%TMP7%\%%~nF.7z" >> "%LOG%" 2>&1
      if errorlevel 1 (
        echo [ERROR] la verificacion de %%~nF.7z fallo, no se copia >> "%LOG%"
      ) else (
        copy /y "%TMP7%\%%~nF.7z" "%NAS%\" >nul
        for %%A in ("%TMP7%\%%~nF.7z") do set L=%%~zA
        for %%B in ("%NAS%\%%~nF.7z") do set R=%%~zB
        if "!L!"=="!R!" (
          echo [OK] %%~nF.7z  !R! bytes en el NAS. Ya se puede borrar %%~nxF del NAS y %TMP7%\%%~nF.7z >> "%LOG%"
        ) else (
          echo [ERROR] tamanos distintos local !L! / NAS !R! para %%~nF.7z >> "%LOG%"
        )
      )
    )
  )
)
echo Fin %date% %time% >> "%LOG%"
echo.
echo Listo. Resumen:
findstr /b /l "[OK] [ERROR] [SALTEADO]" "%LOG%"
endlocal
