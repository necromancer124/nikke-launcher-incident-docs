# 2. How the attack worked

This is a **supply-chain attack**: the attacker did not trick me into downloading anything. They changed files on the game's own servers, and the official launcher did the rest.

I did not reverse-engineer the malware. This page combines what the community analysts published with what I can see in my own logs, and marks which is which.

## The chain, step by step

| Step | What happens | Did I see it myself? |
|---|---|---|
| 1 | Four JavaScript files on the publisher's download servers (CDN) are changed. They are files the launcher loads every time it starts. | No: reported by the community and confirmed by the official notice. On my desktop, the launcher's code cache held two of the four changed loader entries, written at the moment of infection. |
| 2 | I open the launcher. It loads those files as usual. | Yes. |
| 3 | On some launches, the changed code tells the launcher's own downloader to fetch a file called `insight.bundle` (about 205 KB) from `analytics.insightjs[.]com`. | **Yes.** My launcher logs record the download, the address and the size. |
| 4 | The file is saved inside the launcher's real log folder with a name that looks like a log file (`log\tinyget\tinyget.<date>-<time>.log`). It hides among real logs. | **Yes.** The launcher's `debug.log` prints `lua downloaded to log\tinyget\...`. |
| 5 | The file is a script (LuaJIT). The launcher runs it. It registers a channel and starts an **agent** that identifies itself by the PC's name. | **Yes.** `debug.log` prints `k2f_chan registered` and `agent started as <PC name>`. |
| 6 | The payload file deletes itself after starting. | Partly: on my desktop the file was gone but the download record survived. |
| 7 | While the launcher stays open, the agent checks in with the attacker's server on a timer and can receive commands. | Partly: the agent's saved state on my desktop shows a check-in interval of 1,800 seconds (30 minutes) and a counter of 4 messages sent. |
| 8 | Commands reported by analysts include reading files, collecting browser data and looking for crypto wallets. | **No.** I have no record of which commands, if any, were sent to my PCs. |
| 9 | A stronger form of persistence was reported on some PCs: the agent can drop a DLL (`platform_experience_helper.dll`) into Google Chrome's profile folder and register it under HKCU as Windows Parental Controls, so it loads into other apps and survives after the launcher closes. | **Not found on either of my PCs.** (Chrome isn't installed on my desktop.) |

## What makes it nasty

- **It came through the official launcher.** "Only download from official sources" did not help.
- **It only needed the launcher open.** Daily login was enough.
- **It disguised itself as a log file** in a folder full of real logs.
- **My antivirus saw nothing.** Microsoft Defender detected nothing on my laptop before or after.

## What it did *not* do, as far as my evidence goes

- It did not wipe the launcher's real logs. They survived and recorded every infection.
- I found no Windows "log cleared" events on either PC.
- I have no evidence a person was watching my PC live.

See [`07-what-i-can-prove.md`](07-what-i-can-prove.md) for the full list.

## The one-second view

From my desktop's `debug.log`, October 31 (PC name removed):

```
[1031/191508.367:INFO:CONSOLE(1)] "lua downloaded to log\tinyget\tinyget.20261031-191507-353.log"
[1031/191508.542:INFO:CONSOLE(1)] "k2f_chan registered"
[1031/191508.924:INFO:CONSOLE(1)] "agent started as [PC NAME REMOVED]"
```

Download, register, start: 0.6 seconds.

## How it was first noticed

According to the community write-ups, the first public report came from a player on the [NGA forum](https://bbs.nga.cn/read.php?tid=47843502): League of Legends' anti-cheat (Vanguard) blocks unsigned DLLs, so the game refused to start while the malware's DLL was loaded. That is the first public report I know of; others may have noticed earlier.
