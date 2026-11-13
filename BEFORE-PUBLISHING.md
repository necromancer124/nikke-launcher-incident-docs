# Before making this repo public

This repo is **private**. Go through this list first.

## Must do

- [ ] **Fill in the `[TODO]` links**: the official Level Infinite notice(s) in `docs/10-if-you-were-affected.md` and `docs/11-credits-and-sources.md`.
- [ ] **Ask the people named** in `docs/11-credits-and-sources.md` whether they're OK being named and linked: Springz, MotherSphere, whyKusanagi, Matsur1_san. Remove or anonymise anyone who says no.
- [ ] **Let Springz read `docs/06-reports-and-takedown.md`.** It describes his emails and his reports. Confirm the times and the wording, and that he is fine with the 1984 email image being here (it is cropped from his own public post).
- [ ] **Check the dates that depend on "today"**: "As of November 13, 2026 … the attacker has not been caught" appears in `README.md`, `docs/01-timeline.md` and `docs/10-if-you-were-affected.md`. Update them to the publishing date.
- [ ] **Link the video** in `README.md` once it is public, and link this repo from the video description.

## Double-check the facts I could not verify myself

- [ ] The official-side timeline in `docs/01-timeline.md` (Sep 27, Nov 3 17:04 GMT, Nov 4 03:13 GMT, Nov 4 23:11 GMT) comes from whyKusanagi's timeline and my own graphic. Compare it against the official notices.
- [ ] When the attacker's server actually went down. Community timelines say it stopped answering on Nov 3; my graphic `G7` says "Nov 4, 05:09 GMT: attacker's server down after reports". `docs/06` explains the uncertainty, but the graphic states one version. Decide which is right, or re-make the graphic.
- [ ] The second IP address and the backup `.org` domain in `docs/09-indicators.md` come from community lists, not from my logs.
- [ ] The registry key and DLL name in `docs/09-indicators.md` are as reported by the community. They were not found on my PCs.
- [ ] The local time of the host's two replies (the screenshot shows 3:42 PM in Springz's time zone; the timeline says "~23:00" my time).

## Privacy check (done on 2026-11-13, repeat before publishing)

Nothing in this repo should contain:

- [ ] my email address, real name or home IP address
- [ ] my PC names or Windows user folder (log excerpts say `[PC NAME REMOVED]`)
- [ ] agent IDs, login tickets, `uid` / `openid` / `sig` values from the launcher logs
- [ ] Discord IDs or private chat screenshots (none are included; the chat is only quoted)
- [ ] case or ticket numbers that aren't already public
- [ ] anything about how the attacker may have paid for the server (not established, deliberately left out)
- [ ] the attacker's domain or IP as a clickable link

Run this to re-check:

```bash
grep -rniE "DESKTOP-|Users\\\\|@gmail|login_ticket|openid|biz_ticket" --include="*.md" --include="*.txt" --include="*.ps1" .
```

## Things deliberately left out

- The raw evidence (full logs, event logs, hashes). It stays offline; hashes only mean something if the files stay untouched.
- The unrelated malware found on my desktop, beyond the one paragraph in `docs/04-my-desktop.md` that explains why it limits what I can claim.
- Any guess about who the attacker is.
