# 7. What I can prove, and what I can't

The honest answer to "were you hacked?" is **yes**. The honest answer to "did they steal anything?" is **I can't prove it either way**.

## ✅ Proven by my own evidence

**Both PCs**
- The official launcher downloaded `insight.bundle` (about 205 KB) from `analytics.insightjs[.]com`.
- Right after each download, the launcher's `debug.log` shows the agent starting.
- The payload was saved under a fake `.log` name in the launcher's real log folder.
- A saved agent state was in the launcher's browser storage.

**Laptop**
- Three infections: November 1 (20:38), 2 (22:19) and 3 (17:03).
- Scanner verdict INFECTED before cleanup, NIKKE NOT FOUND after.
- Microsoft Defender detected nothing, before or after.

**Desktop**
- One infection: October 31, 19:15.
- The log line connecting the domain to the IP address `89.127.233[.]127`.
- The agent's saved state: 4 messages sent, 30-minute check-in interval.

**The infrastructure**
- The IP address belongs to a hosting company (1984 ehf, Iceland).
- The domain was registered on September 27, 2026 through PublicDomainRegistry and has been on client hold since November 5, 2026, 02:05 GMT.
- The host wrote that the server was shut down; the registrar wrote that the domain was suspended.

## ❌ Not proven (I don't state these as fact)

- **That any password, cookie, wallet or file was stolen.** The agent *could* do that. No record of an upload was preserved.
- **That the malware edited or wiped logs.** My real logs survived and recorded every infection. No Windows "log cleared" events (Security 1102 / System 104) on either PC.
- **That a person was watching or controlling my PC live.**
- **Who the attacker is.**
- **That our report alone took anything down.** See [`06-reports-and-takedown.md`](06-reports-and-takedown.md).
- **That anyone at the publisher knew** before the files were replaced.

## About "it deletes its files and logs"

One widely shared community graphic says the malware "deletes its files and logs". From what I read in the same author's own documentation, that wording is stronger than the evidence:

- The payload deleting **itself** after starting is plausible, and matches my desktop (file gone, download record still there).
- A cleanup command that removes the payload and downloader logs is described from one person's screenshots; no sample or code was published.
- On my laptop the downloader logs survived until **I** deleted them. So that command either did not run on my PC or did not remove them.

My wording: *the malware disguised itself as a log file to hide among the launcher's real logs. I have no evidence it edited or wiped the real logs. On my PCs they recorded every infection.*

## Limits of my evidence

| Limit | Why it matters |
|---|---|
| Sysmon not installed, file-access auditing off | Windows kept no record of which files the agent opened |
| Laptop NTFS change journal only reached back to Nov 3, 20:25 | It starts after the last laptop infection |
| Laptop: original launcher logs deleted in my cleanup | Only redacted copies and excerpts remain |
| No payload sample saved | I cannot analyse the code myself |
| Desktop had other, unrelated malware | No loss on that PC can be pinned on NIKKE |
| The launcher was closed soon after each infection | The agent's window was short, but I can't measure what it did in it |

## Why I still treated everything as stolen

Because the cost of being wrong is one-sided. If nothing was taken and I change every password, I lose an evening. If something was taken and I do nothing, I lose accounts. "I can't prove it" is a statement about my evidence, not about the attacker's behaviour.
