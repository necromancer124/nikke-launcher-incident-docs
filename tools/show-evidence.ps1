<#
  Shows the NIKKE malware evidence collected on 2026-11-06. Read-only: changes nothing.
  Run in any PowerShell (no admin needed):
    Set-ExecutionPolicy -Scope Process Bypass -Force
    & "$env:USERPROFILE\Desktop\show-evidence.ps1"
  Options:
    -Evidence "path"   evidence folder (default: Desktop\NIKKE-evidence-2026-11-06)
    -Report            also save everything shown to evidence-report.txt next to this folder
    -NoRedact          show secrets (login tickets, agent password) - do not share that output
#>
param(
    [string]$Evidence = "$env:USERPROFILE\Desktop\NIKKE-evidence-2026-11-06",
    [switch]$Report,
    [switch]$NoRedact
)

$ErrorActionPreference = 'SilentlyContinue'
if (-not (Test-Path $Evidence)) { Write-Host "Evidence folder not found: $Evidence" -ForegroundColor Red; exit 1 }
$out = New-Object System.Collections.Generic.List[string]
function Show($text, $color = 'Gray') { Write-Host $text -ForegroundColor $color; $out.Add($text) }
function Head($text) { Show ''; Show ('=' * 78) Cyan; Show " $text" Cyan; Show ('=' * 78) Cyan }
function Redact([string]$s) {
    if ($NoRedact) { return $s }
    $s = $s -replace '((?:login_ticket|biz_ticket|uid|openid|sig|token)["=:]\s*"?)[^&",\s}]+', '$1<REDACTED>'
    $s = $s -replace '("agent_pass"\s*:\s*")[^"]*', '$1<REDACTED>'
    $s -replace '(Cookie:\s*).*', '$1<REDACTED>'
}
function Cut([string]$s, [int]$n = 220) { if ($s.Length -gt $n) { $s.Substring(0, $n) + '...' } else { $s } }

$nikkeLog = "$Evidence\D_NIKKE_Launcher\intl_service\debug.log"
$tinyget  = "$Evidence\D_NIKKE_Launcher\log\tinyget"
$tbs      = "$Evidence\APPDATA_nikke_launcher\tbs_cache"

Show "NIKKE PC launcher malware - evidence viewer" White
Show "Evidence folder: $Evidence"
Show "Shown: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')   Redaction: $(if ($NoRedact) {'OFF'} else {'on'})"

# --- integrity ------------------------------------------------------------------------
Head '0. INTEGRITY - are the files unchanged since they were collected?'
$manifest = "$Evidence\SHA256-manifest.txt"
if (Test-Path $manifest) {
    $ok = 0; $bad = @(); $missing = @(); $listed = @{}
    foreach ($line in Get-Content $manifest) {
        if ($line -notmatch '^([0-9a-f]{64})\s{2}(.+)$') { continue }
        $hash = $Matches[1]; $rel = $Matches[2].Trim(); $listed[$rel] = $true
        $p = Join-Path $Evidence $rel
        if (-not (Test-Path -LiteralPath $p)) { $missing += $rel; continue }
        if ((Get-FileHash -LiteralPath $p -Algorithm SHA256).Hash.ToLower() -eq $hash) { $ok++ } else { $bad += $rel }
    }
    Show "Unchanged: $ok files" Green
    if ($bad)     { Show "CHANGED since collection: $($bad.Count)" Red; $bad | ForEach-Object { Show "  $_" Red } }
    if ($missing) { Show "MISSING (deleted or quarantined by antivirus): $($missing.Count)" Yellow; $missing | Select-Object -First 20 | ForEach-Object { Show "  $_" Yellow } }
    $extra = Get-ChildItem $Evidence -Recurse -File | Where-Object { -not $listed.ContainsKey($_.FullName.Substring($Evidence.Length + 1)) -and $_.Name -ne 'SHA256-manifest.txt' }
    if ($extra) { Show "Not in the hash list (added later, e.g. notes or admin evidence): $(@($extra).Count) files" }
} else { Show 'No SHA256-manifest.txt found - cannot verify integrity.' Yellow }
$zip = "$Evidence.zip"
if (Test-Path $zip) { Show "Backup zip: $zip  sha256 $((Get-FileHash $zip).Hash.ToLower())" }

# --- 1. launcher log ------------------------------------------------------------------
Head '1. PROOF THE AGENT RAN - NIKKE launcher log (debug.log)'
if (Test-Path $nikkeLog) {
    $lines = Get-Content $nikkeLog
    Show "debug.log: $($lines.Count) lines, from $((Cut $lines[0] 16)) to $((Cut $lines[-1] 16))"
    $hits = Select-String -Path $nikkeLog -Pattern 'lua downloaded', 'k2f_chan registered', 'adopted ', 'agent started as', 'resuming', 'startup failed', 'insightjs'
    if ($hits) { $hits | ForEach-Object { Show ("  line {0,6}: {1}" -f $_.LineNumber, (Cut (Redact $_.Line))) Red } }
    else { Show '  No agent lines found.' Green }
    Show '  Meaning: "k2f_chan registered" = the malware agent started; "adopted <id>" = the attacker''s server accepted it.'
} else { Show 'debug.log not in evidence folder.' Yellow }

# --- 2. download ----------------------------------------------------------------------
Head '2. THE DOWNLOAD - launcher downloader logs (tinyget)'
if (Test-Path $tinyget) {
    Get-ChildItem $tinyget -File | ForEach-Object { Show ("  {0,-42} {1,10:N0} bytes  {2}" -f $_.Name, $_.Length, $_.LastWriteTime) }
    $dl = Select-String -Path "$tinyget\*.log" -Pattern 'insight\.bundle', 'insightjs', 'total=205135', '89\.127\.233\.127', '89\.126\.250\.172'
    Show "  Lines mentioning the attacker's server: $(@($dl).Count)"
    $dl | Select-Object -First 25 | ForEach-Object { Show ("  {0}: {1}" -f $_.Filename, (Cut (Redact $_.Line))) Red }
    Show '  Meaning: "Connected to analytics.insightjs.com (89.127.233.127)" + "result=0" = the payload was downloaded successfully.'
} else { Show 'tinyget folder not in evidence folder.' Yellow }

# --- 3. agent state -------------------------------------------------------------------
Head '3. AGENT STATE left in the launcher browser storage (k2f.agent.state)'
$found = $false
Get-ChildItem "$tbs\Local Storage\leveldb" -File | ForEach-Object {
    $txt = [IO.File]::ReadAllText($_.FullName)
    $i = $txt.IndexOf('k2f.agent')
    if ($i -ge 0) {
        $found = $true
        $chunk = $txt.Substring($i, [Math]::Min(500, $txt.Length - $i)) -replace '[^\x20-\x7E]', '.'
        $j = $chunk.IndexOf('}}'); if ($j -gt 0) { $chunk = $chunk.Substring(0, $j + 2) }
        Show "  in $($_.Name):" Red
        Show "  $(Redact $chunk)" Red
    }
}
if ($found) { Show '  Meaning: agent_id matches the "adopted" line; poll_interval = how often it phoned home (seconds).' }
else { Show '  No agent state found (LevelDB may have compressed it into an .ldb file).' Yellow }

# --- 4. loader in cache ---------------------------------------------------------------
Head '4. THE POISONED SCRIPTS - launcher code cache entries pointing to insightjs.com'
$names = @{ 'dd65fa4d61079e7e_0' = 'aegis'; 'ce2fd3f1007a9fe9_0' = 'images'; '1416c638b3830103_0' = 'feedlist'; 'fd520c7c0f65c2d7_0' = 'vue' }
foreach ($n in $names.Keys) {
    $f = "$tbs\Code Cache\js\$n"
    if (Test-Path $f) {
        $raw = [Text.Encoding]::ASCII.GetString([IO.File]::ReadAllBytes($f))
        $url = [regex]::Match($raw, 'https://insightjs\.[a-z]+/l\.js\?f=[a-z]+').Value
        Show ("  FOUND  {0} ({1})  {2}  {3}" -f $n, $names[$n], (Get-Item $f).LastWriteTime, $url) Red
    } else { Show ("  absent {0} ({1})" -f $n, $names[$n]) DarkGray }
}
Get-Content "$tbs\TransportSecurity" -Raw | Select-String 'insightjs' | ForEach-Object { Show '  TransportSecurity mentions insightjs (launcher talked to it over HTTPS)' Red }

# --- 5. defender ----------------------------------------------------------------------
Head '5. MICROSOFT DEFENDER DETECTIONS (separate PowerShell trojan, Oct 17 / Oct 23)'
$threats = @{}
if (Test-Path "$Evidence\defender-threats.json") {
    # parentheses: Windows PowerShell 5.1 otherwise passes a JSON array down the pipe as one object
    (Get-Content "$Evidence\defender-threats.json" -Raw | ConvertFrom-Json) | ForEach-Object { $threats["$($_.ThreatID)"] = $_.ThreatName }
}
if (Test-Path "$Evidence\defender-detections.json") {
    $det = @(Get-Content "$Evidence\defender-detections.json" -Raw | ConvertFrom-Json) | ForEach-Object { $_ }
    foreach ($d in @($det)) {
        $when = $d.InitialDetectionTime
        if ($when -is [datetime]) { $when = $when.ToLocalTime() }
        elseif ("$when" -match '/Date\((\d+)\)') { $when = [DateTimeOffset]::FromUnixTimeMilliseconds([int64]$Matches[1]).LocalDateTime }
        Show ("  {0}  {1}  removed={2}" -f $when, $threats["$($d.ThreatID)"], $d.ActionSuccess) Red
        $res = ($d.Resources -join ' ')
        $url = [regex]::Matches($res, 'https?://[^\s'';]+') | ForEach-Object Value | Select-Object -Unique
        if ($url) { Show "      downloads from: $($url -join ', ')" Red }
        Show "      command: $(Cut $res 160)" DarkGray
    }
} else { Show 'No Defender detection export found.' Yellow }

# --- 6. tamper check ------------------------------------------------------------------
Head '6. LOG / FILE TAMPERING CHECK'
$tr = "$Evidence\tamper-check\TAMPER-CHECK-REPORT.txt"
if (Test-Path $tr) { Get-Content $tr | ForEach-Object { Show "  $_" } } else { Show 'No tamper report found.' Yellow }
$evtx = Get-ChildItem "$Evidence\tamper-check\evtx\*.evtx"
if ($evtx) {
    Show ''; Show '  Saved event logs (open with Event Viewer > Action > Open Saved Log):'
    $evtx | ForEach-Object { Show ("    {0,-75} {1,6:N1} MB" -f $_.Name, ($_.Length / 1MB)) }
}

# --- 7. admin evidence ----------------------------------------------------------------
Head '7. ADMIN EVIDENCE (only after nikke-cleanup.ps1 has been run as admin)'
$admin = Get-ChildItem $Evidence -Directory -Filter 'admin-evidence-*' | Sort-Object Name
if (-not $admin) { Show '  None yet. Run nikke-cleanup.ps1 (or with -EvidenceOnly) from an admin terminal.' Yellow }
foreach ($a in $admin) {
    Show "  $($a.Name)" White
    if (Test-Path "$($a.FullName)\defender-exclusions.txt") { Get-Content "$($a.FullName)\defender-exclusions.txt" | ForEach-Object { Show "    $_" } }
    Get-ChildItem "$($a.FullName)\usn\*-agent-hits.txt" | ForEach-Object {
        $h = Get-Content $_.FullName
        Show "    File-change journal $($_.Name): $(@($h).Count) agent-related lines" $(if ($h) { 'Red' } else { 'Green' })
        $h | Select-Object -First 15 | ForEach-Object { Show "      $(Cut $_ 200)" Red }
    }
    if (Test-Path "$($a.FullName)\malware-file-hashes.txt") {
        $mh = Get-Content "$($a.FullName)\malware-file-hashes.txt" | Where-Object { $_ }
        Show "    Malware files hashed before removal: $(@($mh).Count)"; $mh | ForEach-Object { Show "      $_" Red }
    }
    if (Test-Path "$($a.FullName)\cleanup-log.txt") {
        Show '    Cleanup log:'; Get-Content "$($a.FullName)\cleanup-log.txt" | ForEach-Object { Show "      $_" }
    }
}

# --- summary --------------------------------------------------------------------------
Head 'SUMMARY'
$ran = (Test-Path $nikkeLog) -and (Select-String -Path $nikkeLog -Pattern 'k2f_chan registered' -Quiet)
Show ("  NIKKE malware agent ran on this PC:      {0}" -f $(if ($ran) { 'YES' } else { 'no evidence' })) $(if ($ran) { 'Red' } else { 'Green' })
Show ("  Separate PowerShell trojan (Defender):   {0}" -f $(if ($det) { "YES - $(@($det).Count) detections, all removed" } else { 'none recorded' })) $(if ($det) { 'Red' } else { 'Green' })
Show  '  Attacker addresses: insightjs.com, analytics.insightjs.com, insightjs.org, 89.127.233.127, 89.126.250.172, 178.16.54.107'

if ($Report) {
    $rp = "$(Split-Path $Evidence -Parent)\evidence-report-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"
    $out | Out-File $rp -Encoding utf8
    Write-Host "`nReport saved: $rp" -ForegroundColor Green
}
