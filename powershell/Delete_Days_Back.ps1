<#
==============================================================================
 DELETE DAYS BACK
==============================================================================
 Created: [11/12/2016]
 Author: Ethan Bell
 Arguments: N/A
==============================================================================
 Modified: 
 Modifications: 
==============================================================================
 Purpose: This script will delete files older than x days from the defined
    folder
 Options: 
==============================================================================
#>

## Variables
$Dest = "C:\Support\SQLBac\";    # Backup path on server (optional).
$Daysback = "0";                 # Days to keep.

$CurrentDate = Get-Date
$DatetoDelete = $CurrentDate.AddDays($Daysback)
Get-ChildItem $Dest | Where-Object { $_.LastWriteTime -lt $DatetoDelete } | Remove-Item