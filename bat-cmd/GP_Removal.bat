@echo off

::-------------------------------------------------------------------------------
:: Group Policy Removal Script
:: Created by: Ethan Bell
:: Date: March 15, 2014
:: Description: This script will back up and remove the appropriate registry
::              entries, then it will delete the GroupPolicy folder/files
::              !!REQUIRES A REBOOT!!
::-------------------------------------------------------------------------------

::-------------------------------------------------------------------------------
:: Backup registry entries
::-------------------------------------------------------------------------------

@echo Backuping up registry entries to %TEMP%
reg export HKLM\SOFTWARE\Policies %TEMP%\HKLM_Policies.txt
reg export HKCU\SOFTWARE\Policies %TEMP%\HKCU_Policies.txt

::-------------------------------------------------------------------------------
:: Remove registry entries
::-------------------------------------------------------------------------------

@echo Removing registry entries
reg delete HKLM\SOFTWARE\Policies /f
reg delete HKCU\Software\Policies /f

::-------------------------------------------------------------------------------
:: Delete Group Policy folder
::-------------------------------------------------------------------------------

@echo Deleting Group Policy folder
RD /S /Q %windir%\System32\GroupPolicy
RD /S /Q %windir%\System32\GroupPolicyUsers

@echo Operation has completed. Please reboot the computer...
pause