@echo off
rem Servidor dedicado de teste do church_run (DEPENDENCIES.md §5 B): sem Steam, nome "churchrun_dev",
rem ate 5 GB de memoria. O StartServer64.bat da Steam reserva 16 GB e so repassa dois argumentos.
rem Uso: tools\start-dev-server.bat "<pasta do Project Zomboid Dedicated Server>"
setlocal
set "SERVER_DIR=%~1"
if "%SERVER_DIR%"=="" set "SERVER_DIR=C:\Program Files (x86)\Steam\steamapps\common\Project Zomboid Dedicated Server"
if not exist "%SERVER_DIR%\jre64\bin\java.exe" (
    echo Pasta do Dedicated Server nao encontrada: "%SERVER_DIR%"
    echo Passe a pasta como argumento, entre aspas.
    exit /b 1
)
cd /d "%SERVER_DIR%"
".\jre64\bin\java.exe" -Djava.awt.headless=true -Dzomboid.steam=0 -Dzomboid.znetlog=1 -XX:+UseZGC -XX:-CreateCoredumpOnCrash -XX:-OmitStackTraceInFastThrow -Xms2g -Xmx5g -Djava.library.path=natives/ -cp "java/;java/projectzomboid.jar" zombie.network.GameServer -statistic 0 -servername churchrun_dev
pause
