' Modify line 34 to define the Domain Name.

Const ADS_UF_DONT_EXPIRE_PASSWD = &h10000
Const E_ADS_PROPERTY_NOT_FOUND  = &h8000500D
Const ONE_HUNDRED_NANOSECOND    = .000000100
Const SECONDS_IN_DAY            = 86400
Const adStateOpen 				= 1
Dim domain_name
Dim adoConnection			' Object for the ado Active Directory Connection
Dim adoCommand				' Object for the ado Command Query for retrieving data from the A.D.
Dim adoRecordset			' Object for the resulting Record Set from the Query
Dim objRootDSE	
Dim inputDomain
Dim inputServer
Dim inputAccount
Dim inputUser
Dim User
Dim strPwdnotchange
Dim strPwdexpire
Dim objArgs
Dim strName
Dim strHomeMDB				' Mailbox Location
Dim strMB					' Mailbox Store
Dim strSG					' Mailbox Store Storage Group
Dim strServer	
Dim strTmpArray
Dim boolLog
Dim bolDisabled
Dim bolLocked

bolDisabled = False
bloLocked = False
NonExpire = False
domain_name = "DC=na,DC=calpine,DC=com"

on error resume next

Set objRootDSE = GetObject("LDAP://RootDSE")
Set adoConnection = CreateObject("ADODB.Connection")
Set adoCommand = CreateObject("ADODB.Command")
Set adoRecordset = CreateObject("ADODB.Recordset")
Set objArgs = Wscript.Arguments
boolLog=False

' Prompts for user input of a User Name
If objArgs.Count = 1 Then
	inputUser = Trim(objArgs(0))
Else
	inputUser = InputBox("Please enter the UserName:", "Employee UserName", "")
		If Len(inputUser) < 1 Then
		Set objArgs = Nothing
		WScript.Echo "You didn't enter a username. You can run from the command line with the following syntax: CScript GetUserInfoByName.vbs <UserID>"
		WScript.Quit(0)
		End If
End If

on error resume next

adoConnection.Provider = "ADSDSOObject"
adoConnection.Open

If adoConnection.State = adStateOpen Then
	If boolLog Then
		WScript.Echo "Authentication Successful!"
	End If
Else
	
	WScript.Echo "ADO Authentication Failed!"
	WScript.Quit(1)
End If

Set adoCommand.ActiveConnection = adoConnection
adoCommand.CommandText = "Select distinguishedName FROM 'LDAP://" & objRootDSE.Get("defaultNamingContext") & _
	"' where samAccountName = '" & inputUser & "'"
adoCommand.Properties("Page Size") = 20000
Set adoRecordset = adoCommand.Execute
If boolLog Then
	WScript.Echo adoCommand.CommandText
End If

While Not adoRecordset.EOF
	If boolLog Then
		WScript.Echo "   Active Directory Path:   " & adoRecordSet.Fields.Item("distinguishedName").Value & vbCRLF
	End If
	strMessage = "Results for User Name " & inputUser & vbCRLF & _
			"   Active Directory Path:   " & adoRecordSet.Fields.Item("distinguishedName").Value & vbCRLF
			
		
	'WScript.Echo strMessage
	strlocation=adoRecordSet.Fields.Item("distinguishedName").Value
        'Move on to next record in recordset
	adoRecordset.MoveNext
WEnd

' Password expiration
Set User = GetObject("LDAP://" & strlocation)
strName=User.displayName
If strName <> "" Then 
   'on error resume Next
   
   intUID = User.Get("uid")

   intUserAccountControl = User.Get("userAccountControl")
   If intUserAccountControl And ADS_UF_DONT_EXPIRE_PASSWD Then     ' LINE 11
       WScript.Echo "Note: This password does not expire."
       strmaxpasswordage="Note: The password does not expire."
       NonExpire = True
       strPwdexpire="No"
   Else
       dtmValue = User.PasswordLastChanged
       'If Err.Number = E_ADS_PROPERTY_NOT_FOUND Then               ' LINE 16
        If dtmValue = "" then
           WScript.Echo "Note: The password has never been set."
           strPasswordlastset="The password has never been set."
           strPwdexpire="Yes"
       Else
           intTimeInterval = Int(Now - dtmValue)
             ' WScript.Echo "The password was last updated on " & _
              '  DateValue(dtmValue) & " at " & TimeValue(dtmValue)  & vbCrLf & _
           '  "The difference between when the password was last" & vbCrLf & _
            ' "updated and today is " & intTimeInterval & " days"
           strPasswordlastset="The password was last updated on " & _
           DateValue(dtmValue) & " at " & TimeValue(dtmValue)
       'End If
       
       
       If dtmValue = "" Then
       'MsgBox "Blank"
       End If
       
          Set objDomain = GetObject("LDAP://" & domain_name)
          Set objMaxPwdAge = objDomain.Get("maxPwdAge")

          If objMaxPwdAge.LowPart = 0 Then
              WScript.Echo "Note: The Maximum Password Age is set to 0 in the " & _
                        "domain. Therefore, the password does not expire."
              strmaxpasswordage="The Maximum Password Age is set to 0 in the " & _
                        "domain. Therefore, the password does not expire."
              NonExpire = False
              strPwdexpire="No"
        
          Else
              dblMaxPwdNano = _
              Abs(objMaxPwdAge.HighPart * 2^32 + objMaxPwdAge.LowPart)
              dblMaxPwdSecs = dblMaxPwdNano * ONE_HUNDRED_NANOSECOND
              dblMaxPwdDays = Int(dblMaxPwdSecs / SECONDS_IN_DAY)
              ' WScript.Echo "Maximum password age is " & dblMaxPwdDays & " days"
              strmaxpasswordage="Maximum password age is " & dblMaxPwdDays & " days"
              strPwdexpire="Yes"
              
              If intTimeInterval >= dblMaxPwdDays Then
              'WScript.Echo "Yes. The password has expired."
              strIspasswordExpired="Yes. The password has expired."
              Else
              'WScript.Echo "The password will expire on " & _
              'DateValue(dtmValue + dblMaxPwdDays) & " (" & _
              'Int((dtmValue + dblMaxPwdDays) - Now) & " days from today)."
              strIspasswordExpired="No. The password will expire on " & _
              DateValue(dtmValue + dblMaxPwdDays) & " (" & _
              Int((dtmValue + dblMaxPwdDays) - Now) & " days from today)."
              End If
          End If
       End If
   End If


   strHomeMDB = Trim(User.homeMDB) & ""

    if strHomeMDB = "" then
        strMB = ""
        strSG = ""
        strServer = ""
    else
        strTmpArray = Split(strHomeMDB,",")
        strMB	= Right(strTmpArray(0), Len(strTmpArray(0)) - 3)
        strSG = Right(strTmpArray(1), Len(strTmpArray(1)) - 3)
        strServer = Right(strTmpArray(3), Len(strTmpArray(3)) - 3)
    end if

	LCSEnabled = User.Get("msRTCSIP-UserEnabled")
	If Err Then
    LCSEnabled = "False"
    SIPAddress = "User not setup in LCS"
Else
    SIPAddress = User.Get("msRTCSIP-PrimaryUserAddress")
End if
Err.Clear

aProxy = User.proxyaddresses

    for each sProxy in aProxy
        strAddy = strAddy & "<b>   Address:</b>                " & sProxy & "<br>"
    next

'arrMemberOf = objUser.GetEx("memberOf")
arrMemberOf = User.GetEx("memberOf")

For Each grp In User.Groups
gt = grp.groupType
arrGrp = Split(grp.Name, "=")

'MsgBox arrGrp(1) & ", " & gt

If grp.mail = "" then
    if instr(arrGrp(1),"proxy") > 1 then
        ntGroup = ntGroup & "<b>   Group Name:</b>             " & arrGrp(1) & "  <span style='color:red'><b> - Client has internet access</b></span><br><br>"
     else
        If gt <> 8 Then
         	ntGroup = ntGroup & "<b>   Group Name:</b>             " & arrGrp(1) & "<br>   <span style='color:orange'><B>Group Description:</b></span>      " & grp.Description & "<br><br>"
        End if
    end if
Else
	If gt = 8 Then
    	distroList = distroList & "<b>   Group Name:</b>             " & arrGrp(1) & "<br>   <span style='color:orange'><B>Group Description:</b></span>      " & grp.Description & "<br><br>"
	End If
End If



'If grp.Mail = "" Then
'
'if instr(arrGrp(1),"proxy") > 1 then
'        ntGroup = ntGroup & "<b>   Group Name:</b>             " & arrGrp(1) & "  <span style='color:red'><b> - Client has internet access</b></span><br><br>"
'Else
'
'MsgBox arrGrp(1) & ", " & gt
'If gt = 8 Then
'MsgBox "gt = 8"
'distroList = distroList & "<b>   Group Name:</b>             " & arrGrp(1) & "<br>   <span style='color:orange'><B>Group Description:</b></span>      " & grp.Description & "<br><br>"
'Else
'ntGroup = ntGroup & "<b>   Group Name:</b>             " & arrGrp(1) & "<br>   <span style='color:orange'><B>Group Description:</b></span>      " & grp.Description & "<br><br>"
'End If
'End if
'End if


Next

If User.IsAccountLocked = True Then
strISlocked = "red"
Else
strISlocked = "black"
End If


If User.AccountDisabled = True Then
strISDisabled = "red"
Else
strISDisabled = "black"
End if

bolpwexpired = UCase(Replace(Left(strIspasswordExpired,3),".",""))

If bolpwexpired = "YES" Then
strPWColor = "red"
Else
strPWColor = "black"
End if

If NonExpire = True Then
strExpireColor = "red"
Else
strExpireColor = "black"
End If

strMailboxHidden = User.msExchHideFromAddressLists
If strMailboxHidden = True Then
strMailboxHidden = "<b><span style='color:red'>" & "True</b></span>"
Else
strMailboxHidden = "False"
End if

If strmaxpasswordage = "Note: The password does not expire." Then
strmaxpasswordage = "<b><span style='color:red'>" & "Note: The password does not expire." & "</span></b>"
strIspasswordExpired = "<b><span style='color:red'>" & "Note: The password does not expire." & "</span></b>"
strPasswordlastset = "<b><span style='color:red'>N/A</span></b>"
End if


   strMessage = "<b><span style='color:blue'>General Info for UserID " & inputUser & "</span></b><br>" & _
			"<b>   Display Name: </b>               " & User.displayName & "<br>" & _
			"<b>   User Name:   </b>				" & User.samAccountName & "<br>" & _
			"<b>   Employee ID:  </b>				" & User.EmployeeID & "<br>" & _
			"<b>   Description:  </b>               " & User.description & "<br>" & _
			"<b>   Title:   </b>                    " & User.Title & "<br>" & _
			"<b>   Location:  </b>                  " & User.physicalDeliveryOfficeName & "<br>" & _
			"<b>   Department:   </b>               " & User.department & "<br>" & _
			"<b>   Active Directory Path: </b>      " & User.distinguishedName & "<br>" & _
			"<b>   Personal Share:  </b>            " & User.homeDirectory & "<br>" & _
			"<b>   Profile Path:    </b>            " & User.profilePath & "<br><br>" &_
	        "<b><span style='color:blue'>Account Status</span></b><br>" & _
            "<b>   Password last changed:  </b>       " & strPasswordlastset & "<br>" & _
            "<b>   Does Password Expire: </b>       " & "<b><span style='color:" & strExpireColor & "'>" & strPwdexpire & "</span></b><br>" & _
            "<b>   Maximum password age: </b>       " & strmaxpasswordage & "<br>" & _
            "<b>   Is Password Expired: </b>        " & "<span style='color:" & strPWColor & "'>" & strIspasswordExpired & "</span><br>" & _
            "<b><span style='color:black'>   Is Account Locked: </b>            " & "<b><span style='color:" & strISLocked & "'>" & User.IsAccountLocked & "</span><br></b>" & _
            "<b><span style='color:black'>   AccountDisabled: </span></b>            " & "<b><span style='color:" & strISDisabled & "'>" & User.AccountDisabled & "</span></b><br><br>"& _ 
            "<b><span style='color:blue'>Mail Info</span></b><br>" & _
            "<b><span style='color:black'>   Exchange Server: </b>            " & strServer & "<br>" & _
			"<b>   Storage Group:   </b>            " & strSG & "<br>" & _
			"<b>   Mailbox Store:   </b>            " & strMB & "<br>" & _
			"<b>   Mailbox Hidden:  </b>            " & strMailboxHidden & "<br>" & _
            "<b>   Primary E-Mail Address: </b>     " & User.mail & "<br>" & "<br>" & _
            "<b><span style='color:blue'>Mail Aliases:</span>" & "<br></b>" & strAddy & "<br><br>" & _
            "<b><span style='color:blue'>UserID " & UCase(inputUser) & " is a member of:</span></b><br><br>" &_
            "<b><span style='color:green' style=text-decoration:underline;> NT Security Groups: </b></span><br>" & ntGroup & "<br><b><span style='color:green' style=text-decoration:underline;> Email Distribution Lists: </b></span><br>" & distroList
            
''   WScript.Echo strMessage			strPWColor		<span style="text-decoration:underline;">

Set objExplorer = WScript.CreateObject("InternetExplorer.Application")
ObjExplorer.Navigate "about:blank"
ObjExplorer.ToolBar = 0
ObjExplorer.StatusBar = 0
ObjExplorer.Width = 850
ObjExplorer.Height = 650
ObjExplorer.Left = 0
ObjExplorer.Top = 0
ObjExplorer.Visible = 1
ObjExplorer.Document.Title = "-> " & inputUser & " <- Account Information for " & inputUser
ObjExplorer.Document.Body.InnerHTML = strMessage

Else
   WScript.Echo "No Information for this Employee:  " & inputUser
   WScript.Quit(0)
End If
