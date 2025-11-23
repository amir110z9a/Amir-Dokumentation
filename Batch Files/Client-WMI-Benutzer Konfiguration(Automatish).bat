@echo off
echo ===============================
echo  WMI & Firewall Auto Fix Script
echo ===============================
echo.

REM ---- Enable Required Services ----
echo Starting required services...
sc config Winmgmt start= auto
sc config RpcSs start= auto
sc config eventlog start= auto
sc config RemoteRegistry start= auto

net start Winmgmt
net start RemoteRegistry

echo Services enabled.
echo.

REM ---- Enable Firewall Rules ----
echo Configuring firewall rules...

netsh advfirewall firewall set rule group="Windows Management Instrumentation (WMI)" new enable=yes
netsh advfirewall firewall set rule group="Remote Administration" new enable=yes
netsh advfirewall firewall set rule group="Remote Event Log Management" new enable=yes
netsh advfirewall firewall set rule group="Remote Service Management" new enable=yes
netsh advfirewall firewall set rule group="Performance Logs and Alerts" new enable=yes

REM ---- Extra WMI program rule ----
netsh advfirewall firewall add rule name="WMI Extra" dir=in action=allow program="%systemroot%\system32\wbem\wmiprvse.exe" enable=yes

echo Firewall configured.
echo.

REM ---- Enable DCOM via Registry ----
echo Applying DCOM permissions...
reg add "HKLM\Software\Microsoft\Ole" /v EnableDCOM /t REG_SZ /d Y /f
reg add "HKLM\Software\Microsoft\Ole" /v LegacyAuthenticationLevel /t REG_DWORD /d 2 /f
reg add "HKLM\Software\Microsoft\Ole" /v LegacyImpersonationLevel /t REG_DWORD /d 3 /f

echo DCOM enabled.
echo.

REM ---- Repair WMI performance counters ----
echo Repairing WMI Performance Counters...
lodctr /R
winmgmt.exe /resyncperf

echo WMI counters repaired.
echo.

REM ---- Add user to required groups ----
echo Adding user 'Benutzer' to admin and management groups...
net localgroup Administrators Benutzer /add
net localgroup "Remote Management Users" Benutzer /add
net localgroup "Distributed COM Users" Benutzer /add
net localgroup "Event Log Readers" Benutzer /add
net localgroup "Performance Log Users" Benutzer /add

echo User permissions updated.
echo.

echo All tasks completed successfully!
pause
