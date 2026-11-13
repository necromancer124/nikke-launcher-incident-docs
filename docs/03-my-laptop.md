# 3. My laptop: three infections

The laptop is the PC I play on most, and the one the story started with.

## What happened

I opened the launcher for my daily login on three evenings in a row. Each time, the launcher downloaded the payload and started the agent.

| # | Date | Time (local) |
|---|---|---|
| 1 | November 1 | 20:38 |
| 2 | November 2 | 22:19 |
| 3 | November 3 | 17:03 |

Springz's warning arrived on November 3 at 19:03, two hours after the third one. I read it the next morning.

## What the logs show

For each of the three dates:

- The launcher's downloader fetched `insight.bundle` from `analytics.insightjs[.]com`, about 205 KB.
- `debug.log` printed the same three steps: `lua downloaded to log\tinyget\...`, then `k2f_chan registered`, then the agent's identity being adopted or resumed.
- The payload was saved with a fake `.log` name inside the launcher's real log folder (`Launcher\log\tinyget\`).

Also:

- A saved agent state (`k2f.agent.state`) was in the launcher's browser storage.
- The community scanner's verdict was **INFECTED** before cleanup and **NIKKE NOT FOUND** after.

## What was *not* there

- The DLL persistence (`platform_experience_helper.dll` and the HKCU CLSID registry change) was **not found**.
- **Microsoft Defender detected nothing**, before or after cleanup.
- No Windows "log cleared" events.

## How I confirmed it

1. I did not trust a random "virus checker" during an active attack, so I **read the scanner's code first**. It was read-only: it looks for the known log lines, files and registry entries, and deletes or uploads nothing.
2. I ran it. It reported the agent starts in the launcher log and the attacker's address.
3. I opened the logs myself and found the same lines by hand.

## What I did (November 4)

- Uninstalled the launcher and removed its leftover folders.
- Kept **redacted copies and excerpts** of the logs, with SHA-256 hashes (verified November 5).
- Changed passwords from a different device, logged out of sessions everywhere, turned on two-factor authentication.

## My mistake on this PC

I deleted the original launcher logs during cleanup and only kept redacted copies and excerpts. The evidence is still good enough to show what happened, but originals are always stronger. On the desktop two days later I copied everything first. If you take one thing from this page: **save your logs before you clean anything.**

## Limits

- Sysmon was not installed and file-access auditing was off, so Windows has no record of which files the agent touched.
- The NTFS change journal only reached back to November 3, 20:25: after the last infection.
- I never saved the payload file as a sample.
