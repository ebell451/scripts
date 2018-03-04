Dim strComputerName, hostname, groupname
Dim phonenum, contract, intCaseSensitive
Set wshShell = WScript.CreateObject( "WScript.Shell" )
intCaseSensitive = 1
strComputerName = wshShell.ExpandEnvironmentStrings( "%COMPUTERNAME%" )

hostname = InputBox("Computer name?","Set Hostname",strComputerName)

phonenum = InputBox("Phone Number?","","Leave Blank if unknown")

groupname = InputBox("Business Name?","Set Group")

contract = InputBox("Under Contract?","yes or no")

hostname = Replace(hostname, " ", "%20", 1, -1, intCaseSensitive)
phonenum = Replace(phonenum, " ", "%20", 1, -1, intCaseSensitive)
groupname = Replace(groupname, " ", "%20", 1, -1, intCaseSensitive)


wshShell.Run "http://helpme.thealliedteam.com:8040/Bin/Allied.SC.Support.ClientSetup.exe?h=helpme.thealliedteam.com&p=8041&k=BgIAAACkAABSU0ExAAgAAAEAAQABSg3908FFoN8a02LrOEuI4mUoZYCPkd9hyn2iJ3dL4bb%2BW9I%2F9KmNqaaz5IwCN5nrav2E9r%2BL%2Buu63hnnhhu7QNNzMlxdhHBfWGbdQ0aEt%2B81IgBmMhnBroVlPwaydLAuoji30sww%2BkufnESatm%2FcmdxWWYSMWzqLXYwojZ%2BGNOkuK3mQ2ghebdnpPA13mcNBp4gqdeIzbwKxPmigqbsCOm11NnDwiLEhnqszP%2FyRrNCef%2BVBC3akJ%2BoMCIBNxx3iomVegsYJ3Ug597B%2BeAWIyJngt8YS0wpiTR3MmJeTKmh7kuLY5nJ%2B0h%2FPMe8flg5Q9wBorC%2BWaRQ38nYWYJrj&e=Access&y=Guest&t=" & hostname & "%20" & phonenum & "&c=" & groupname & "&c=" & contract

