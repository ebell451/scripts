<#
==============================================================================
 DELETE TEMP FILES
==============================================================================
 Created: [11/12/2016]
 Author: Ethan Bell
 Arguments: N/A
==============================================================================
 Modified: 
 Modifications: 
==============================================================================
 Purpose: Delete temporary files
 Options: 
==============================================================================
#>


$folders = @(
    'C:\Windows\Temp\*',
    'C:\Documents and Settings\*\Local Settings\temp\*',
    'C:\Users\*\Appdata\Local\Temp\*',
    'C:\Users\*\Appdata\Local\Microsoft\Windows\Temporary Internet Files\*',
    'C:\Windows\SoftwareDistribution\Download',
    'C:\Windows\System32\FNTCACHE.DAT',
    'C:\Users\Administrator\AppData\Local\CrashDumps'
)
foreach ($folder in $folders) { Remove-Item $folder -force -recurse -ErrorAction SilentlyContinue };