<content>

# Gather Computers

When using PowerShell, one of the most interesting advantages is you can execute code against multiple computers in one go.
When working with SQL Server, we can also address multiple SQL Instances at the same time.
There are some different ways to supply a cmdlet or function with a collection of computers.
I'll show you some easy methods right away:

## Parameter ComputerName

Lots of existing cmdlets since PS V2 have a -ComputerName parameter. You can submit one or more computers to it:
```powershell
PS> Get-WSManInstance -ResourceURI winrm/config/client -ComputerName SQL1
```
```powershell
PS> Get-WSManInstance -ResourceURI winrm/config/client -ComputerName SQL1,SQL2,SQL3
```
 
## Pipeline
 
If a cmdlet or function accepts pipeline input for the computer name, here's the way we use it:

```powershell
PS> 'SQL1','SQL2','SQL3','FakeSQL4' | Get-WSManInstance -ResourceURI winrm/config/client
```
 
## Expression
### for the pipeline

The code to collect the computer names we want, is provided to the pipeline:

```powershell
PS> Get-ADComputer -SearchBase "OU=Central servers,OU=Computers MyCompany,DC=MYCOMPANY,DC=COM" -Filter "name -like 'SQL*'" | select -ExpandProperty name  | Get-WSManInstance -ResourceURI winrm/config/client
```
### inline

We can also put that part of the code at the -ComputerName parameter and wrap it in parentheses.

```powershell
PS> Get-WSManInstance -ResourceURI winrm/config/client -ComputerName $(Get-ADComputer -SearchBase "OU=Central servers,OU=Computers MyCompany,DC=MYCOMPANY,DC=COM" -Filter "name -like 'SQL*'" | select -ExpandProperty name)
```

## using variables

To avoid summing up all your computers of interest, it can be handy to keep the list in a variable:

```powershell
PS> $MyComputers = 'SQL1','SQL2','SQL3','FakeSQL4'

PS> Get-WSManInstance -ResourceURI winrm/config/client -ComputerName $MyComputers
```
### from a text file

*SQLHosts.txt*:

SQL1  
SQL2  
SQL3  

```powershell
PS> $MyComputers = Get-Content -Path 'C:\MyDirectory\SQLHosts.txt'

PS> Get-WSManInstance -ResourceURI winrm/config/client -ComputerName $MyComputers
```

### from a csv

*SQLInstances.csv*:
|ComputerName |InstanceName | Category |
|:--- |:---- |:----|:----|
|SQL1| Instance2K14 | Production |
|SQL2| Instance2K12 | Test |
|SQL3| Instance2K8R2 | Production |

```powershell
PS> $MyComputers = Import-Csv -Path 'C:\MyDirectory\SQLInstances.csv' | select ComputerName

PS> Get-WSManInstance -ResourceURI winrm/config/client -ComputerName $MyComputers
```

### from Active Directory

When you're on a Domain Controller (bad idea!) or you have installed RSAT on your work station and activated the necesary features, you can use the AD-cmdlets.

```powershell
PS> $MyComputers = Get-ADComputer -SearchBase "OU=Central servers,OU=Computers MyCompany,DC=MYCOMPANY,DC=COM" -Filter "name -like 'SQL*'" | select -ExpandProperty name

PS> Get-WSManInstance -ResourceURI winrm/config/client -ComputerName $MyComputers
```

### as registered servers

In the dbatools module, there is a function that gets the servernames from a Central Management Server:

```powershell
PS> $MyComputers = Get-DbaRegisteredServerName -SqlInstance MyCMS

PS> Get-WSManInstance -ResourceURI winrm/config/client -ComputerName $MyComputers
```

### from a database

```powershell
PS> $MyComputers = Invoke-Sqlcmd -ServerInstance 'MyPrecious' -Database sqlinfodb -Query "select hostName from dbo.hosts;" | select -ExpandProperty hostName

PS> Get-WSManInstance -ResourceURI winrm/config/client -ComputerName $MyComputers
```

## making variables permanent

Now, once populated, we can reuse $MyComputers as much as we like. But when we continue in another session, we'll have to populate our variable again. I think that's still too much work, so we take it one step further. We're going to populate our variable in our PowerShell Profile:

*SQLInstances.txt*:

SQL1\Inst2K14  
SQL2\Inst2K08R2  
SQL3  

*C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1*:
```
$AllMyComputers = Get-Content C:\scripts\SQL\SQLInstances.txt | ForEach-Object {$_.split('\')[0]} | Select-Object -Unique

$AllMyInstances = Import-Csv -Path 'C:\MyDirectory\SQLInstances.csv' | select @{label = 'SQLInstance';expression={$_.ComputerName + '\' + $_.InstanceName}}
```

## super trick: the real profile

Because it's a burden to alter the content of the profile script, we can make our life easier. In profile.ps1 we dotsource another .ps1 that contains our real profile text. That way we can alter the content as much as we like and it will be loaded as soon as we start a new PowerShell session:

*C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1*:
```
. D:\scripts\MyRealProfile.ps1
```

*D:\scripts\MyRealProfile.ps1*:

```
$AllMyComputers = Get-Content C:\scripts\SQL\SQLInstances.txt | ForEach-Object {$_.split('\')[0]} | Select-Object -Unique

$AllMyInstances = Import-Csv -Path 'C:\MyDirectory\SQLInstances.csv' | select @{label = 'SQLInstance';expression={$_.ComputerName + '\' + $_.InstanceName}}
```

</content>

  <tabTrigger>Gather Computers</tabTrigger>