#Requires -RunAsAdministrator

# Andrew Rucks
# 2/18/26
# FOR CIT 241 - SYSTEMS PROGRAMMING
# ENDPOINT SECURITY CONFIGURATION REPORT

#region Variables
# section 1
$DeviceName=""
$OSVersion=""
$Reboot=""
$SignedOnUser=""
# section 2
$AcctRestricted="Yes"
$PWComplexity="N/A (Home Edition)"
$PWExpiration="N/A (Home Edition)"
# section 3
$AutoUpdates="Yes"
$LastUpdate=""
# section 4
$AVInstalled="No"
$RealTimeProt="No"
$LastDefUpdate=""
# section 5
$FirewallEnabled="No"
$InboundRules=""
$OutboundRules=""
# section 6
$DiskEncryption="No"
$RemMedRes="No"
# section 7
$TikTokFound="No"
$VLCFound="No"
$GoogleFound="No"
# section 8
$EventLogs="No"
$TamperProt="No"
# section 9
$LockTimeout="No"
$SecureBoot="No"
#endregion

#region InformationGathering
echo "Gathering Information..."
$computerinfo = Get-ComputerInfo
$hotfix = Get-HotFix
$av = Get-MpComputerStatus
$frules = Get-NetFirewallRule
$screensaver = Get-WMIObject Win32_Desktop | Where-Object name -match $env:USERNAME

# section 1
$DeviceName = $computerinfo.CsName
$OSVersion = $computerinfo.OsVersion
$Reboot = $computerinfo.OsLastBootUpTime
$SignedOnUser = $computerinfo.CsUserName

# section 2
if ((Get-LocalUser -Name administrator).Enabled){$AcctRestricted = "No"}

# section 3
if ((Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name NoAutoUpdate -ErrorAction Ignore).NoAutoUpdate -EQ $true){$AutoUpdates = "No"}
$LastUpdate = (Get-HotFix | Sort-Object -Property InstalledOn -Descending)[0].InstalledOn

# section 4
if ($av.AntivirusEnabled){$AVInstalled = "Yes"}
if ($av.RealTimeProtectionEnabled){$RealTimeProt = "Yes"}
$LastDefUpdate = $av.AntivirusSignatureLastUpdated

# section 5
if ((Get-NetFirewallProfile)[0].Enabled -AND (Get-Service -Name mpssvc | Where-Object -Property Status -EQ "Running")){$FirewallEnabled = "Yes"} #checks if service is running just in case
$InboundRules = (Get-NetFirewallRule | Where-Object -Property Direction -EQ "Inbound").Name[0..4] -join ", "
$OutboundRules = (Get-NetFirewallRule | Where-Object -Property Direction -EQ "Outbound").Name[0..4] -join ", "

# section 6
if ((Get-BitLockerVolume -MountPoint "C:").ProtectionStatus -EQ "On"){$DiskEncryption = "Yes"} #needs administrator
if ((Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\RemovableStorageDevices" -Name DenyAll -ErrorAction Ignore).DenyAll -EQ $true){$RemMedRes = "Yes"}

# section 7
if ((Get-Package | Where-Object -Property Name -EQ "Google Chrome") -NE $null){$GoogleFound = "Yes"}
if ((Get-Package | Where-Object -Property Name -like "*TikTok*") -NE $null){$TikTokFound = "Yes"}
if ((Get-Package | Where-Object -Property Name -EQ "VLC media player") -NE $null){$VLCFound = "Yes"}

# section 8
if ((Get-EventLog -LogName System -Newest 1).TimeGenerated.Date -EQ (Get-Date).Date){$EventLogs = "Yes"} #sees if an event log was generated today
if ($av.IsTamperProtected){$TamperProt = "Yes"} #I don't know if this affects logging, but its the only tamper protection I could find...

# section 9
if ($screensaver.ScreenSaverActive -AND $screensaver.ScreenSaverSecure){$LockTimeout = "Yes"}
if (Confirm-SecureBootUEFI){$SecureBoot = "Yes"} #needs administrator

echo "Generating report..."
#endregion

#region HTML
"<!DOCTYPE html>
<html>
<head>
<title>$DeviceName</title>
</head>
<body>

<h1>Endpoint Security Configuration Report</h1>

<h2>1. System Information</h2>
<p><b>Device Name: </b>$DeviceName</p>
<p><b>OS Version: </b>$OSVersion</p>
<p><b>Last Reboot Time: </b>$Reboot</p>
<p><b>Signed-on User: </b>$SignedOnUser</p>

<h2>2. Accounts & Authentication</h2>
<p><b>Local Admin Accounts Disabled: </b>$AcctRestricted</p>
<p><b>Password Complexity Enforced: </b>$PWComplexity</p>
<p><b>Password Expiration Policy: </b>$PWExpiration</p>

<h2>3. Patch & Update Status</h2>
<p><b>Automatic Updates Enabled: </b>$AutoUpdates</p>
<p><b>Last OS Update: </b>$LastUpdate</p>

<h2>4. Endpoint Protection</h2>
<p><b>Antivirus Installed: </b>$AVInstalled</p>
<p><b>Real-time Protection Enabled: </b>$RealTimeProt</p>
<p><b>Last AV Signature Update: </b>$LastDefUpdate</p>

<h2>5. Firewall & Network Security</h2>
<p><b>Firewall Enabled: </b>$FirewallEnabled</p>
<p><b>Inbound Rules Reviewed: </b>$InboundRules</p>
<p><b>Outbound Rules Reviewed: </b>$OutboundRules</p>

<h2>6. Disk & Data Protection</h2>
<p><b>Disk Encryption Enabled: </b>$DiskEncryption</p>
<p><b>Removable Media Restrictions: </b>$RemMedRes</p>

<h2>7. Application Security</h2>
<p>Unauthorized Software Check</p>
<p><b>TikTok: </b>$TikTokFound</p>
<p><b>VLC: </b>$VLCFound</p>
<p><b>Google Chrome: </b>$GoogleFound</p>

<h2>8. Logging & Monitoring</h2>
<p><b>Event Logs Enabled: </b>$EventLogs</p>
<p><b>Tamper Protection Enabled: </b>$TamperProt</p>

<h2>9. Physical Security</h2>
<p><b>Device Lock Timeout Configured: </b>$LockTimeout</p>
<p><b>Secure-boot Enabled: </b>$SecureBoot</p>

</body>
</html>" > ./ARucks_GeneratedReport.html
start ./ARucks_GeneratedReport.html

#endregion
