# 11. Credits and sources

The people who figured this out did not work for the publisher. They were players.

## Credits

| Who | What they did |
|---|---|
| **Springz** ([@SpringZ_FSG](https://x.com/SpringZ_FSG)) | Warned me. Wrote the calm step-by-step guide. Wrote and sent the abuse reports to the host and the registrar, and asked them to preserve their records. |
| **A player on the NGA forum** | The first public report I know of: an anti-cheat refused to start with the malware loaded. |
| **MotherSphere** | The first public technical breakdown, and a scanner. |
| **whyKusanagi** | A check-and-removal kit, a detailed timeline, and reports to Microsoft and CISA. |
| **A Japanese community moderator** | Pinned a warning before there was any official post. |
| **Whoever registered the loader's fallback domain** | Registered `insightjs[.]org` on Nov 3 and turned it into a warning page, so infected launchers showed a warning instead of fetching more malware. |
| **Matsur1_san** | Their public scan result showed the same IP address as my logs: the post that connected the dots for me. |
| **Everyone who reported the server and the domain** | Several people did. The takedown is theirs too. |
| **1984 ehf and PublicDomainRegistry** | Answered abuse reports fast and acted on them. |

## Sources

**Community analysis**
- The NGA forum thread where it was first reported: https://bbs.nga.cn/read.php?tid=47843502 (needs an account)
- MotherSphere, public breakdown: https://gist.github.com/MotherSphere/d6c049a09ba8ac3085c51ee9df24a4e5
- MotherSphere, incident write-up: https://github.com/MotherSphere/NIKKE-Launcher-Check/blob/main/docs/incident.md
- MotherSphere, scanner (the one I read and ran): https://github.com/MotherSphere/NIKKE-Launcher-Check
- whyKusanagi, check kit, docs and timeline (in the README): https://github.com/whykusanagi/nikke_malware
- whyKusanagi, post: https://x.com/whyKusanagi/status/2118386344900919590
- Springz, guide and community logs: https://github.com/SpringZali/nikke-launcher-triage

**Posts I refer to**
- Springz, "a rented server, not a VPN": https://x.com/SpringZ_FSG/status/2118079976050438323
- Springz, the host's two replies: https://x.com/SpringZ_FSG/status/2118087770342031735
- Springz, official guidance is out: https://x.com/SpringZ_FSG/status/2118120685260202262
- Springz, the domain is down: https://x.com/SpringZ_FSG/status/2118293301493223836
- Springz, phase 2: https://x.com/SpringZ_FSG/status/2118319941866664297
- Matsur1_san, infected scan result: https://x.com/Matsur1_san/status/2117789672558539183

**Official**
- First notice, Nov 4, 03:13 GMT: https://x.com/NIKKE_en/status/2117817602659770434
- Apology, Nov 4, 23:01 GMT: https://x.com/NIKKE_en/status/2118116340225732677 (official page: https://nikke-en.com/newsdetail.html?content_id=3a94ebf0ab6c5a4703aa87aa57d0b8cd3d4b)
- Manual security check, Nov 4, 23:11 GMT: https://x.com/NIKKE_en/status/2118118928631451774 (official page: https://nikke-en.com/newsdetail.html?content_id=ecdccd40a55a5a46aaa9abda64d436082db7)
- Additional notice, Nov 10: https://x.com/NIKKE_en/status/2120182878143430985 (official page: https://nikke-en.com/newsdetail.html?content_id=d58204e4a5cc4a4824a8dd3a77f0f5089e12)

**Press and security vendors**
- BleepingComputer, Nov 4: https://www.bleepingcomputer.com/news/security/nikke-pc-game-launcher-hacked-to-spread-remote-access-data-stealing-malware/
- Malwarebytes, Nov 5: https://www.malwarebytes.com/blog/news/2026/11/nikke-pc-launcher-compromise-put-players-passwords-and-personal-files-at-risk

**Public records**
- RDAP record for the attacker's domain (saved copy in [`evidence/`](../evidence/))
- IP WHOIS for the server's address

**My own**
- Launcher logs and Windows logs from my two PCs (kept offline; redacted excerpts in [`evidence/`](../evidence/))
- My log redaction tool: https://github.com/necromancer124/nikke-log-redactor

## What I took from where

- **The attack chain, the DLL persistence, the agent's commands, the "first found on NGA" story and the official-side timeline** come from the community analyses. I did not verify them independently beyond what my own logs show.
- **Everything about my two PCs** comes from my own logs.
- **The tracing** comes from my logs plus public records.
- **The reports and replies** come from Springz and the emails he received.

## Images

- Diagrams in `evidence/images/G*.png` are my own.
- The 1984 email image is cropped from Springz's public post.
- The registry screenshot is from a public RDAP lookup.
- The official post screenshot is from the publisher's public account.
- *GODDESS OF VICTORY: NIKKE* is © SHIFT UP / Level Infinite. This repo is not affiliated with or endorsed by them.
