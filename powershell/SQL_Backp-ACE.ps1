<#
==============================================================================
 SQL Database Backup Script
==============================================================================
 Created: 05/21/2015
 Author: Ethan Bell
 Company: Allied Virtual Office Assistants
 Arguments: N/A
==============================================================================
 Modified: 01/09/2019
 Modifications: Line 37 - only backup PNPNAV2018 db & add days to keep backups
==============================================================================
 Purpose: Create a backup of all SQL Databases on the local machine/server
==============================================================================
#>

## Variables
$Server = "NAVSERVER\NAV2018";   # SQL Server Instance.
$Dest = "C:\Support\SQLBac\";    # Backup path on server (optional).
$Daysback = "-5";                # Days to keep.

## ===========================================================================
## Full + Log Backup of MS SQL Server databases
## with SMO.
[void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.ConnectionInfo');
[void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.Management.Sdk.Sfc');
[void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO');
# Required for SQL Server 2008 (SMO 10.0).
[void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMOExtended');
$srv = New-Object Microsoft.SqlServer.Management.Smo.Server $Server;
# If missing set default backup directory.
If ($Dest -eq "")
{ $Dest = $server.Settings.BackupDirectory + "\" };
# Write-Output ("Started at: " + (Get-Date -format yyyy-MM-dd-HH:mm:ss)); --Not needed
# Full-backup for every database
foreach ($db in $srv.Databases)
{
    If($db.Name -eq "PNPNAV2018")  # Modified original statement 'If($db.Name -ne "tempdb")  # No need to backup TempDB' for only PNPNAV2018 db 
    {
        $timestamp = Get-Date -format yyyy-MM-dd-HH-mm-ss;
        $backup = New-Object ("Microsoft.SqlServer.Management.Smo.Backup");
        $backup.Action = "Database";
        $backup.Database = $db.Name;
        $backup.Devices.AddDevice($Dest + $db.Name + "_full_" + $timestamp + ".bak", "File");
        $backup.BackupSetDescription = "Full backup of " + $db.Name + " " + $timestamp;
        $backup.Incremental = 0;
        # Starting full backup process.
        $backup.SqlBackup($srv);
        # For db with recovery mode <> simple: Log backup.
        If ($db.RecoveryModel -ne 3)
        {
            $timestamp = Get-Date -format yyyy-MM-dd-HH-mm-ss;
            $backup = New-Object ("Microsoft.SqlServer.Management.Smo.Backup");
            $backup.Action = "Log";
            $backup.Database = $db.Name;
            $backup.Devices.AddDevice($Dest + $db.Name + "_log_" + $timestamp + ".trn", "File");
            $backup.BackupSetDescription = "Log backup of " + $db.Name + " " + $timestamp;
            #Specify that the log must be truncated after the backup is complete.
            $backup.LogTruncation = "Truncate";
            # Starting log backup process
            $backup.SqlBackup($srv);
        };
    };
};

## Delete all files in backup folder older than x day(s).
$CurrentDate = Get-Date
$DatetoDelete = $CurrentDate.AddDays($Daysback)
Get-ChildItem $Dest | Where-Object { $_.LastWriteTime -lt $DatetoDelete } | Remove-Item

## Output finished statement
# Write-Output ("Finished at: " + (Get-Date -format  yyyy-MM-dd-HH:mm:ss)); --no needed