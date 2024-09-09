@echo off
setlocal

rem Variables
set "sourceDir=%~dp0"
set "targetDir=C:\ndt7Client"
set "exeFile=ndt7-client.exe"
set "batFile=%~nx0"
set "vbsFile=%targetDir%\temp.vbs"
set "logFile=%targetDir%\execution.log"

rem Création du répertoire C:\ndt7Client
if not exist "%targetDir%" (
    mkdir "%targetDir%"
)

rem Copie du fichier ndt7-client.exe vers C:\ndt7Client
copy "%sourceDir%%exeFile%" "%targetDir%\"

rem Copie du fichier batch vers C:\ndt7Client
copy "%sourceDir%%batFile%" "%targetDir%\"

rem Création du script VBScript pour exécuter la commande sans afficher de terminal et pour écrire dans un fichier de log
echo Set objShell = CreateObject("WScript.Shell") > "%vbsFile%"
echo objShell.Run "%targetDir%\%exeFile% -server monitor.uac.bj:4444" , 0, False >> "%vbsFile%"

rem Création de la tâche planifiée pour exécution toutes les 3 minutes avec privilèges élevés et utilisateur SYSTEM
SCHTASKS /CREATE /SC HOURLY /MO 8 /TN "ndt7ClientExecution" /TR "wscript.exe \"%vbsFile%\"" /RU "SYSTEM" /RL "HIGHEST"

powershell -Command "Set-ScheduledTask -TaskName 'ndt7ClientExecution' -Settings (New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopIfGoingOnBatteries -AllowStartIfOnBatteries -DontStopOnIdleEnd)"

