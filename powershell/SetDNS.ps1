<#
==============================================================================
 SET DNS
==============================================================================
 Created: [11/12/2016]
 Author: Ethan Bell
 Arguments: N/A
==============================================================================
 Modified: 
 Modifications: 
==============================================================================
 Purpose: This script allows you to set the DNS settings for a list of
		computers defined in a text file > ComputerList.txt
 Options: 
==============================================================================
#>

$dnsservers = "192.168.1.100","192.168.1.1"
$computers = Get-Content ComputerList.txt
foreach ($comp in $computers)
{

	$adapters = gwmi -q "select * from win32_networkadapterconfiguration where ipenabled='true'" -ComputerName $comp
	foreach ($adapter in $adapters)
	{
		$adapter.setDNSServerSearchOrder($dnsservers)
	}
	
}