$Instances = @()
$BrowserService = Get-WmiObject -Class Win32_service | Where-Object { $_.Name -eq "SQLBrowser" }
if ($BrowserService) {
	$Instance = New-Object PSObject
	$Instance | Add-Member -MemberType NoteProperty -Name Instancename -Value "*SQLBROWSER*"
	$SQLBrowser = $BrowserService.PathName
	$Instance | Add-Member -MemberType NoteProperty -Name SQLBinnRoot -Value $SQLBrowser

	$Instances += $Instance
}

$SQLInstances = @()
if ((Get-Item 'HKLM:\SOFTWARE\Microsoft').GetSubKeyNames() -contains 'Microsoft SQL Server') {
	$SQLInstances = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server').InstalledInstances
}
foreach ($sql in $SQLInstances) {
    $Instance = New-Object PSObject
    $Instance | Add-Member -MemberType NoteProperty -Name Instancename -Value $sql

    $InstanceId = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL').("$sql")
    $SQLBinnRoot = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$($InstanceId)\Setup").SQLBinRoot + '\sqlservr.exe'
    $Instance | Add-Member -MemberType NoteProperty -Name SQLBinnRoot -Value $SQLBinnRoot
    $Instances += $Instance
}

foreach ($Instance in $Instances) {

    if ($Instance.Instancename -eq "*SQLBROWSER*") {
        $FirewallRuleName = "SQL Server Browser"
    }
    else {
        $FirewallRuleName  = "SQL Server (" + $Instance.Instancename + ")"
    }
    $FirewallBinary = $Instance.SQLBinnRoot.Replace("""","")
    $FWRule = Get-NetFirewallRule | where-object { $_.DisplayName -eq $FirewallRuleName } -ErrorAction SilentlyContinue
    if ($FWRule) {
        Write-Host $FirewallRuleName -ForegroundColor Yellow
        Write-Host $FirewallBinary -ForegroundColor Yellow
        Set-NetFirewallRule -NewDisplayName $FirewallRuleName -Program $FirewallBinary -Action Allow -Profile Domain -DisplayName $FirewallRuleName -Description $FirewallRuleName -Direction Inbound | Out-Null
    }
    else {
        Write-Host $FirewallRuleName -ForegroundColor Green
        Write-Host $FirewallBinary -ForegroundColor Green
        #New-NetFirewallRule -Program "C:\Program Files (x86)\Microsoft SQL Server\90\Shared\sqlbrowser.exe" -Action Allow -Profile Domain, Private -DisplayName "SQL Server Browser" -Description "Allow SQL Server Browser" -Direction Inbound
        #New-NetFirewallRule -Program "C:\Program Files\Microsoft SQL Server\MSSQL15.INST1\MSSQL\Binn\sqlservr.exe" -Action Allow -Profile Domain, Private -DisplayName "SQL Server (INST1)" -Description "Allow SQL Server (INST1)" -Direction Inbound
        New-NetFirewallRule -Program $FirewallBinary -Action Allow -Profile Domain -DisplayName $FirewallRuleName -Description $FirewallRuleName -Direction Inbound | Out-Null
    }
}

