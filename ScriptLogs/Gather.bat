<#
==============================================================================
 Gather information from a remote machine. Useful for TS.
==============================================================================
 Created: [05/21/2015]
 Author: Ethan Bell
 Company: Allied Virtual Office Assistants
 Arguments: N/A
==============================================================================
 Source: Original script was created by a co-worker
==============================================================================
 Purpose: Gathers information from a remote machine on current LAN.
 Useful for troubleshooting issues on the system.
==============================================================================
#>

set FormatedTime=%date:~10,4%_%date:~7,2%_%date:~4,2%__%Time:~0,2%_%time:~3,2%
set FormatedTime=%FormatedTime: =%

set startdir=%cd%

If NOT exist "C:\ScriptLogs\Gather\[%1]" (
md C:\ScriptLogs\Gather\%1
)

:: Turn on Remote Registry

psservice /accepteula \\%1 start RemoteRegistry >> C:\ScriptLogs\Gather\%1\%1.txt

start msinfo32.exe /nfo C:\ScriptLogs\Gather\%1\%1_%FormatedTime::=%.nfo /computer %1

start gpresult.exe /s %1 /H C:\ScriptLogs\Gather\%1\%1_%FormatedTime::=%.html

:: Get remotely opened files


psfile /accepteula \\%1 >> C:\ScriptLogs\Gather\%1\%1.txt


:: Get System Information


psinfo /accepteula \\%1 -d >> C:\ScriptLogs\Gather\%1\%1.txt

:: See who is logged on
Echo. >> C:\ScriptLogs\Gather\%1\%1.txt

Psloggedon /accepteula \\%1 >> C:\ScriptLogs\Gather\%1\%1.txt

:: Get Warnings and errors from the Event logs >> C:\ScriptLogs\Gather\%1\%1.txt


psloglist /accepteula \\%1 -d 2 -f wec -s >> C:\ScriptLogs\Gather\%1\%1.txt


psloglist /accepteula \\%1 -d 2 -f wec -s -e 4098 Application >> C:\ScriptLogs\Gather\%1\%1.txt

:: Process information


pslist /accepteula \\%1 >> C:\ScriptLogs\Gather\%1\%1.txt

:: Process information in Tree Form

Echo. >> C:\ScriptLogs\Gather\%1\%1.txt

pslist /accepteula \\%1 -t >> C:\ScriptLogs\Gather\%1\%1.txt
Echo. >> C:\ScriptLogs\Gather\%1\%1.txt
Echo:Get services info. >> C:\ScriptLogs\Gather\%1\%1.txt
Echo. >> C:\ScriptLogs\Gather\%1\%1.txt

powershell "Get-Service -computername %1 | sort-object status -descending" >> C:\ScriptLogs\Gather\%1\%1.txt
Echo. >> C:\ScriptLogs\Gather\%1\%1.txt

:: Get Printer List

Echo. >> C:\ScriptLogs\Gather\%1\%1.txt

Cscript %WINDIR%\System32\Printing_Admin_Scripts\en-US\Prnmngr.vbs -l -s \\%1 >> C:\ScriptLogs\Gather\%1\%1.txt
Echo. >> C:\ScriptLogs\Gather\%1\%1.txt

:: Get port list

Echo. >> C:\ScriptLogs\Gather\%1\%1.txt

Cscript %WINDIR%\System32\Printing_Admin_Scripts\en-US\Prnport.vbs -l -s \\%1 >> C:\ScriptLogs\Gather\%1\%1.txt
Echo. >> C:\ScriptLogs\Gather\%1\%1.txt

:: Get Program List

Echo. >> C:\ScriptLogs\Gather\%1\%1.txt

psinfo /accepteula \\%1 -s >> C:\ScriptLogs\Gather\%1\%1.txt
Echo. >> C:\ScriptLogs\Gather\%1\%1.txt


cd /d C:\ScriptLogs\Gather\%1\
ren %1.txt %1_%FormatedTime::=%.txt
start notepad C:\ScriptLogs\Gather\%1\%1_%FormatedTime::=%.txt
cd /d %startdir%

start explorer.exe C:\ScriptLogs\Gather\%1\


:: Turn off Remote Registry

psservice /accepteula \\%1 stop RemoteRegistry >> C:\ScriptLogs\Gather\%1\%1.txt

:: Remove Sysinternals reg entries

Echo:Remove Sysinternals Reg entries. >> C:\ScriptLogs\Gather\%1\%1.txt
REG DELETE HKCU\Software\Sysinternals /f >> C:\ScriptLogs\Gather\%1\%1.txt
