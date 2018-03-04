<#
=============================================================================
 REBOOT REMOTE COMPUTER - ALT CREDENTIALS
=============================================================================
 Created: [12/07/2011]
 Author: Ethan Bell
 Arguments:
=============================================================================
 Modified: 7/24/2014
 Modifications: Three major modifications were made to the script.
   1. Prompt for credentials
   2. List and prompt for action, script was originally hard-coded for action
   3. Prompt for machine name


=============================================================================
 Purpose: To reboot a remote computer using different credentials
 Options: 0 - Logoff
          4 - Forced Log Off
          1 - Shutdown
          5 - Forced Shutdown
          3 - Reboot
          6 - Forced Reboot
          8 - Power Off
         12 - Forced Power Off
=============================================================================
#>

Write-Host "Options:"
Write-Host "  0 - Logoff"
Write-Host "  1 - Shutdown"
Write-Host "  3 - Reboot"
Write-Host "  4 - Forced Log Off"
Write-Host "  5 - Forced Shutdown"
Write-Host "  6 - Forced Reboot"
Write-Host "  8 - Power Off"
Write-Host " 12 - Forced Power Off"
Write-Host ""

#* Prompt user for option - see list above.
$vRemoteBootOption = Read-Host 'What option would you like to perform?'

#* Prompt user for the computer name.
$vComputerName = Read-Host 'What is the computer name?'

(gwmi win32_OperatingSystem -ComputerName $vComputerName -cred (get-credential)).Win32Shutdown($vRemoteBootOption)