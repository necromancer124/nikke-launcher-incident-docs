# Tools

The two PowerShell scripts I used on my **desktop** on November 6, 2026. They are here to document exactly what I did, not as a recommended cleaner: follow the official guide first, and **read any script before you run it**.

| Script | What it does |
|---|---|
| `nikke-cleanup.ps1` | Run as administrator. 1) Copies the launcher logs, browser storage and Windows event logs to an evidence folder with hashes. 2) Blocks the attacker's domains in the hosts file and the attacker's IP addresses in the firewall. 3) Removes the known leftovers if present. 4) Verifies. `-EvidenceOnly` stops after step 1. |
| `show-evidence.ps1` | Read-only. Prints a summary of an evidence folder made by the first script: file integrity, the key log lines, the agent state, the tamper check. Redacts the PC name unless you pass `-NoRedact`. |

Notes:

- The scripts contain the attacker's domains and IP addresses **in plain form**, because a block list has to. They are never opened or contacted, apart from one DNS lookup at the end that checks the domain no longer resolves.
- The block list has one extra IP address (`178.16.54[.]107`). It belongs to a different, unrelated piece of malware that Microsoft Defender had blocked on the same PC. It is not part of the NIKKE incident.
- The default launcher path is `D:\NIKKE`; change `-NikkePath` for your install.
