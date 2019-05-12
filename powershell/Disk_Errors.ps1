<#
==============================================================================
 DISK ERRORS
==============================================================================
 Created: [11/12/2016]
 Author: Ethan Bell
 Arguments: N/A
==============================================================================
 Modified: 
 Modifications: 
==============================================================================
 Purpose: This script is used to check for any reported errors on the disk or
    potential erros on the disk.
 Options: 
==============================================================================
#>

if ((get-host).Version.Major -ge 4) {
$XmlQuery = [xml]@'
<QueryList>
  <Query Id="0" Path="System">
    <Select Path="System">*[System[Provider[@Name='disk'] and TimeCreated[timediff(@SystemTime) &lt;= 86400000]]]</Select>
  </Query>
</QueryList>
'@
$LogOutput = Get-WinEvent -FilterXml $XmlQuery -ErrorAction SilentlyContinue
}
  else{
    $LogOutput = Get-EventLog -LogName system -Source disk -After (get-date).AddDays(-1) -ErrorAction SilentlyContinue
    }

if ($LogOutput){
Write-Host "---ERROR---"
Write-Host "Disk messages in system log found"
$LogOutput | fl TimeGenerated, Message
exit 1010
}

else{
Write-Host "---OK---"
Write-Host "No disk messages in system log found"
exit 0
}