# Evidence

Only **redacted excerpts and public material** are here. The raw evidence stays offline on my PCs, with SHA-256 manifests, because hashes only mean something if the files stay untouched.

## What's in this folder

| File | What it is | Redactions |
|---|---|---|
| [`desktop-log-excerpts.txt`](desktop-log-excerpts.txt) | The key lines from my desktop's launcher logs (October 31) | PC name removed; domain and IP defanged; lines shortened |
| [`insightjs-rdap-verisign-nov12.json`](insightjs-rdap-verisign-nov12.json) | The public registry (RDAP) record for the attacker's domain, fetched November 12 | None needed: it is a public record. It contains the plain domain name |
| `images/insightjs-client-hold-rdap-nov12.png` | Screenshot of the same record: client hold since November 5 | None |
| `images/1984-two-replies-nov4-1542.jpg` | The host's two replies, cropped from Springz's public post | As published by him |
| `images/nikke-en-manual-check-nov5.png` | The publisher's public "manual check" post | None |
| `images/G1` … `G7` | My own explainer diagrams | - |

## What exists offline (not published)

**Laptop** (`NIKKE-Incident-Evidence`, hashes verified 2026-11-05)
- The scanner's report before and after cleanup
- Redacted copies and excerpts of the launcher logs for November 1–3
- Windows log checks, cleanup logs, a backup of the hosts file

**Desktop** (`NIKKE-evidence-2026-11-06`, hashes verified 2026-11-06)
- The full launcher folders (`log`, `intl_service`), copied before cleanup
- The launcher's browser storage (with the saved agent state) and code cache
- Exported Windows event logs: Security, System, PowerShell, Defender
- NTFS change journal exports, program-execution records
- A log-tampering check report
- The cleanup log

If an investigator, the publisher or a researcher has a real need for the originals, contact me.

## How the excerpts were made

1. Lines were copied from the original log files.
2. The PC name was replaced with `[PC NAME REMOVED]`.
3. The attacker's domain and IP were defanged.
4. Long lines were shortened with `...`; nothing was reworded.

For sharing your own logs safely, see my tool: https://github.com/necromancer124/nikke-log-redactor
