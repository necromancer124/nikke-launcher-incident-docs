<#
  NIKKE PC launcher compromise - evidence collection, blocking and cleanup.
  Run in an ADMIN PowerShell with the NIKKE launcher closed:
    Set-ExecutionPolicy -Scope Process Bypass -Force
    & "$env:USERPROFILE\Desktop\nikke-cleanup.ps1"
  Options:
    -NikkePath "D:\NIKKE"   NIKKE install folder (the one containing Launcher\)
    -EvidenceOnly           collect admin evidence and stop, change nothing
    -FullScan               run a Microsoft Defender full scan at the end
  Order: 1) collect evidence  2) block  3) remove  4) verify. Nothing is deleted before it is copied.
#>
param(
    [string]$NikkePath = 'D:\NIKKE',
    [switch]$EvidenceOnly,
    [switch]$FullScan
)

$ErrorActionPreference = 'Continue'
$principal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host 'Run this from an ADMIN PowerShell (right-click Start > Terminal (Admin)).' -ForegroundColor Red
    exit 1
}

$stamp    = Get-Date -Format 'yyyy-MM-dd_HHmmss'
$evRoot   = "$env:USERPROFILE\Desktop\NIKKE-evidence-2026-11-06"
$ev       = "$evRoot\admin-evidence-$stamp"
New-Item -ItemType Directory -Force $ev | Out-Null
$log = "$ev\cleanup-log.txt"
function Say($msg, $color = 'Gray') { Write-Host $msg -ForegroundColor $color; Add-Content $log $msg }

$badDomains = 'insightjs.com', 'www.insightjs.com', 'analytics.insightjs.com', 'portal.insightjs.com',
              'docs.insightjs.com', 'insightjs.org', 'www.insightjs.org'
# 89.x = NIKKE attacker servers; 178.16.54.107 = the separate PowerShell malware Defender caught on Oct 17
$badIPs     = '89.127.233.127', '89.126.250.172', '178.16.54.107'
$clsidKey   = 'HKCU:\Software\Classes\CLSID\{E77CC89B-7401-4C04-8CED-149DB35ADD04}'
$launcherData = Get-ChildItem $env:APPDATA -Directory -Filter 'nikke_launcher*' -ErrorAction SilentlyContinue

Say "=== NIKKE cleanup $stamp ===" Cyan

# --- 0. stop the launcher -------------------------------------------------------------
Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.Name -match '^(nikke_launcher.*|tbs_browser)$' } | ForEach-Object {
    Say "Stopping $($_.Name) ($($_.Id))" Yellow
    Stop-Process -Id $_.Id -Force
}

# --- 1. admin-only evidence -------------------------------------------------------------
Say '--- 1. Collecting admin-only evidence' Cyan
New-Item -ItemType Directory -Force "$ev\evtx", "$ev\usn", "$ev\artifacts" | Out-Null

wevtutil epl Security "$ev\evtx\Security.evtx"
wevtutil epl 'Microsoft-Windows-TaskScheduler/Operational' "$ev\evtx\TaskScheduler.evtx" 2>$null
$cleared = Get-WinEvent -FilterHashtable @{ LogName = 'Security'; Id = 1102 } -ErrorAction SilentlyContinue
$cleared += Get-WinEvent -FilterHashtable @{ LogName = 'System'; Id = 104 } -ErrorAction SilentlyContinue
if ($cleared) { $cleared | ForEach-Object { Say "LOG CLEARED: $($_.TimeCreated) $($_.LogName)" Red } }
else { Say 'No log-cleared events in Security or System.' Green }
$oldestSec = Get-WinEvent -LogName Security -MaxEvents 1 -Oldest -ErrorAction SilentlyContinue
Say "Security log oldest record: $($oldestSec.TimeCreated)"

# NTFS change journal (file creates/deletes/renames) for every fixed drive
foreach ($d in (Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Used -gt 0 })) {
    $letter = $d.Name
    fsutil usn queryjournal "${letter}:" > "$ev\usn\${letter}-journal-info.txt" 2>&1
    fsutil usn readjournal "${letter}:" csv > "$ev\usn\${letter}-usn-journal.csv" 2>&1
    Say "Saved USN journal for ${letter}:"
}
# quick look for agent file names in the journals
Get-ChildItem "$ev\usn\*-usn-journal.csv" | ForEach-Object {
    $hits = Select-String -Path $_.FullName -Pattern 'k2f', 'insight.bundle', 'platform_experience_helper', 'tinyget\.2026' -SimpleMatch
    $hits | Select-Object -First 50 | ForEach-Object { $_.Line } | Out-File "$ev\usn\$($_.BaseName)-agent-hits.txt" -Encoding utf8
    Say "$($_.Name): $(@($hits).Count) agent-related journal lines"
}

# SRUM (bytes sent per program) and Amcache (program execution) are locked: copy via shadow copy
esentutl.exe /y "$env:windir\System32\sru\SRUDB.dat" /vss /d "$ev\artifacts\SRUDB.dat" | Out-Null
esentutl.exe /y "$env:windir\appcompat\Programs\Amcache.hve" /vss /d "$ev\artifacts\Amcache.hve" | Out-Null
Copy-Item "$env:windir\Prefetch" "$ev\artifacts\Prefetch" -Recurse -Force -ErrorAction SilentlyContinue
Copy-Item "$env:ProgramData\Microsoft\Windows Defender\Support" "$ev\artifacts\DefenderSupport" -Recurse -Force -ErrorAction SilentlyContinue
Copy-Item "$env:windir\System32\drivers\etc\hosts" "$ev\artifacts\hosts.before" -Force

$mp = Get-MpPreference
"ExclusionPath:      $($mp.ExclusionPath -join '; ')",
"ExclusionProcess:   $($mp.ExclusionProcess -join '; ')",
"ExclusionExtension: $($mp.ExclusionExtension -join '; ')",
"ExclusionIpAddress: $($mp.ExclusionIpAddress -join '; ')" | Tee-Object "$ev\defender-exclusions.txt" | ForEach-Object { Say $_ Yellow }

if (Test-Path $clsidKey) { reg export 'HKCU\Software\Classes\CLSID\{E77CC89B-7401-4C04-8CED-149DB35ADD04}' "$ev\artifacts\HKCU-CLSID-E77CC89B.reg" /y | Out-Null }

# per-victim Chrome DLL and LuaJIT agent files: record hash only (copying live malware would just get quarantined)
$chromeDlls = Get-ChildItem "$env:LOCALAPPDATA\Google\Chrome\User Data\PlatformExperienceHelper" -Directory -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -match '^[0-9a-fA-F]{64}$' -and (Test-Path "$($_.FullName)\platform_experience_helper.dll") }
$agentFiles = Get-ChildItem "$NikkePath\Launcher\log\tinyget" -File -ErrorAction SilentlyContinue | Where-Object {
    $fs = [IO.File]::OpenRead($_.FullName); $b = New-Object byte[] 4; $null = $fs.Read($b, 0, 4); $fs.Close()
    ($b -join ',') -eq '27,76,74,1'
}
$tempFiles = Get-ChildItem $env:TEMP -File -Force -Filter 'k2f*' -ErrorAction SilentlyContinue
@($chromeDlls | ForEach-Object { Get-ChildItem $_.FullName -File }) + @($agentFiles) + @($tempFiles) | Where-Object { $_ } |
    Get-FileHash -Algorithm SHA256 | ForEach-Object { "$($_.Hash.ToLower())  $($_.Path)" } | Out-File "$ev\malware-file-hashes.txt" -Encoding utf8

Get-ChildItem $ev -Recurse -File | Where-Object { $_.Name -ne 'cleanup-log.txt' } | Get-FileHash -Algorithm SHA256 |
    ForEach-Object { '{0}  {1}' -f $_.Hash.ToLower(), $_.Path.Substring($ev.Length + 1) } | Out-File "$env:TEMP\admin-manifest.txt" -Encoding utf8
Move-Item "$env:TEMP\admin-manifest.txt" "$ev\SHA256-manifest.txt" -Force
Say "Admin evidence saved to $ev" Green

if ($EvidenceOnly) { Say '-EvidenceOnly given: stopping before any changes.' Cyan; exit 0 }

# --- 2. block ---------------------------------------------------------------------------
Say '--- 2. Blocking attacker domains and IPs' Cyan
$hosts = "$env:windir\System32\drivers\etc\hosts"
$current = Get-Content $hosts -ErrorAction SilentlyContinue
$add = $badDomains | Where-Object { $d = $_; -not ($current | Where-Object { $_ -match "^\s*0\.0\.0\.0\s+$([regex]::Escape($d))\s*$" }) }
if ($add) {
    Add-Content $hosts "`r`n# NIKKE launcher malware block ($stamp)" -Encoding ascii
    $add | ForEach-Object { Add-Content $hosts "0.0.0.0 $_" -Encoding ascii; Say "hosts: blocked $_" }
} else { Say 'hosts: entries already present' }
ipconfig /flushdns | Out-Null

foreach ($dir in 'Outbound', 'Inbound') {
    $name = "Block NIKKE malware IPs ($dir)"
    Get-NetFirewallRule -DisplayName $name -ErrorAction SilentlyContinue | Remove-NetFirewallRule
    New-NetFirewallRule -DisplayName $name -Direction $dir -Action Block -RemoteAddress $badIPs -Profile Any | Out-Null
    Say "firewall: $name -> $($badIPs -join ', ')"
}

# --- 3. remove --------------------------------------------------------------------------
Say '--- 3. Removing malware traces' Cyan
if (Test-Path $clsidKey) {
    Remove-Item $clsidKey -Recurse -Force
    if (Test-Path $clsidKey) { Say 'CLSID hijack key could not be removed - restart Windows and run again.' Red }
    else { Say 'Removed HKCU CLSID hijack key (HKLM copy left alone, it is legitimate).' Green }
} else { Say 'HKCU CLSID hijack key: not present.' }

foreach ($f in $chromeDlls) {
    Remove-Item $f.FullName -Recurse -Force -ErrorAction SilentlyContinue
    if (Test-Path $f.FullName) { Say "LOCKED: $($f.FullName) - restart Windows and run again." Red } else { Say "Removed Chrome DLL folder $($f.Name)" Green }
}
foreach ($f in @($agentFiles) + @($tempFiles) | Where-Object { $_ }) {
    Remove-Item $f.FullName -Force -ErrorAction SilentlyContinue
    Say "Removed $($f.FullName)" Green
}

# tbs_cache can hold the modified CDN scripts and the agent state; delete only if a copy is in the evidence folder
foreach ($ld in $launcherData) {
    $cache  = "$($ld.FullName)\tbs_cache"
    $backup = "$evRoot\APPDATA_$($ld.Name)\tbs_cache"
    if (-not (Test-Path $cache)) { continue }
    if ((Test-Path $backup) -or (Test-Path "$evRoot.zip")) {
        Remove-Item $cache -Recurse -Force -ErrorAction SilentlyContinue
        if (Test-Path $cache) { Say "Could not fully delete $cache (locked?)" Red } else { Say "Removed $cache (copy kept in evidence)" Green }
    } else {
        Copy-Item $cache "$ev\tbs_cache-$($ld.Name)" -Recurse -Force
        Remove-Item $cache -Recurse -Force -ErrorAction SilentlyContinue
        Say "Copied then removed $cache" Green
    }
}
Say 'Left in place on purpose: Launcher\intl_service\debug.log and Launcher\log (evidence, harmless).'

# --- 4. verify --------------------------------------------------------------------------
Say '--- 4. Verify' Cyan
$fw = Get-NetFirewallRule -DisplayName 'Block NIKKE malware IPs*' -ErrorAction SilentlyContinue
Say "Firewall rules active: $(@($fw | Where-Object Enabled -eq 'True').Count) of 2"
$resolved = try { [Net.Dns]::GetHostAddresses('analytics.insightjs.com') | ForEach-Object IPAddressToString } catch { 'no answer' }
Say "analytics.insightjs.com now resolves to: $resolved (should be 0.0.0.0 or no answer)"
Say "HKCU CLSID key present: $(Test-Path $clsidKey)"
$conn = Get-NetTCPConnection -ErrorAction SilentlyContinue | Where-Object { $_.RemoteAddress -in $badIPs }
Say "Live connections to attacker IPs: $(@($conn).Count)"

if ($FullScan) {
    Say 'Starting Defender full scan (can take an hour)...' Cyan
    Update-MpSignature -ErrorAction SilentlyContinue
    Start-MpScan -ScanType FullScan
    Get-MpThreatDetection | Where-Object { $_.InitialDetectionTime -gt (Get-Date).AddHours(-3) } | ForEach-Object { Say "DETECTED: $($_.ThreatID) $($_.Resources -join '; ')" Red }
}

Say "`nDone. Log: $log" Green
Say 'Next: change your passwords from ANOTHER device, then run Microsoft Defender Offline scan (Windows Security > Virus & threat protection > Scan options).' Yellow
