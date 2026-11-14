# Before making this repo public

This repo is **private**. What's left before it can go public:

## Still to do

- [ ] **Let Springz read `docs/06-reports-and-takedown.md`** and confirm the wording about his emails and reports.
- [ ] **Check the dates that depend on "today"**: "As of November 13, 2026 … the attacker has not been caught" appears in `README.md`, `docs/01-timeline.md` and `docs/10-if-you-were-affected.md`. Update them to the publishing date.
- [ ] **Link the video** in `README.md` once it is public, and link this repo from the video description.
- [ ] **Read your scanner verdict** in `docs/03-my-laptop.md` ("My verdict on MotherSphere's checker") and change it to your own words. I wrote it from what you said in the chat on Nov 4 and from the scanner's changelog. Also confirm the version: **v0.4.0** was the newest release when you ran it (about 09:20 GMT on Nov 4); if you downloaded it the evening before, it was v0.2.0 or v0.2.1.
- [ ] Optional: the exact time of the host's two replies to Springz. The screenshot says 3:42 PM in his time zone; the timeline just says "Nov 4, evening".

## Done (2026-11-13)

- [x] **Named people approved.** Springz, MotherSphere, whyKusanagi and Matsur1_san are OK being named and linked (confirmed by Necromancer).
- [x] **Official links filled in** (`docs/10`, `docs/11`): the first notice, the apology, the manual check guide and the Nov 10 additional notice. The two official nikke-en.com pages were opened in a browser and their titles and dates checked ("Our Apology for the PC Launcher Security Incident" and "Manual Security Check Instructions for the PC Launcher", both dated 2026.11.05 JST). The X post links and GMT times come from Springz's guide, which marks them as read at the source.
- [x] **Official-side timeline checked** against whyKusanagi's timeline and Springz's guide. Corrections made in `docs/01`:
  - The domain was **taken over** on Sep 27 at 01:59 GMT (the publisher: a domain "used for some game services"); the files were changed about five hours later, at 06:41 GMT. Previously the docs only said "registered the same day".
  - On Nov 3 the publisher replaced **three** of the four files (17:04–17:23 GMT); the fourth was cleared from the CDN cache on Nov 4 at 03:09 GMT; all four were clean everywhere by 07:09 GMT.
  - Added the publisher's stated distribution start (Oct 29, 18:52 GMT, disputed by Oct 23 player logs) and its own "confirmed an anomaly" time (Nov 3, ~15:00 GMT).
  - The first community scanners were released at 19:35 and 20:15 GMT on Nov 3 (GitHub release times), matching graphic `G7`.
- [x] **When the server went down.** whyKusanagi's timeline: the host shut it down on **Nov 4, 05:09 GMT**, after an abuse report from another researcher. One report says it stopped answering on Nov 3, 18:31 GMT (unconfirmed). This matches graphic `G7`. `docs/06` now says plainly that our report got a confirmation, not the shutdown.
- [x] **Second IP and the `.org` domain** (`docs/09`): `89.126.250[.]172` is where the domain pointed before about Oct 22 (a victim's report, same network). `insightjs[.]org` is the loader's fallback domain, registered by a third party on Nov 3 as a warning page.
- [x] **Registry key and DLL path** (`docs/09`) checked against both community analyses, including the warning to leave the HKLM copy alone.
- [x] **Privacy check**: no email, real name, PC name, user folder, agent ID, login tickets, Discord IDs, private screenshots, payment theories, or clickable attacker links.

Re-run the privacy check before publishing:

```bash
grep -rniE "DESKTOP-|Users\\\\|@gmail|login_ticket|openid|biz_ticket" --include="*.md" --include="*.txt" --include="*.ps1" .
```

## Things deliberately left out

- The raw evidence (full logs, event logs, hashes). It stays offline; hashes only mean something if the files stay untouched.
- The unrelated malware found on my desktop, beyond the one paragraph in `docs/04-my-desktop.md` that explains why it limits what I can claim.
- Any guess about who the attacker is.
