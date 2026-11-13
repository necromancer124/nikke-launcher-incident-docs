# 9. Indicators of compromise

> 🛡️ Everything here is **defanged** on purpose (`[.]`, `hxxps`). Do not visit these addresses. Use them only to search your own logs or to build block lists.

"Seen by me" means it is in my own logs. The rest comes from the community analyses in [`11-credits-and-sources.md`](11-credits-and-sources.md).

## Network

| Indicator | What it is | Seen by me |
|---|---|---|
| `analytics.insightjs[.]com` | Where the launcher downloaded the payload from | **Yes** (both PCs) |
| `hxxps://analytics.insightjs[.]com/comm/assets/insight.bundle` | The payload URL | **Yes** |
| `89.127.233[.]127` | The server behind that domain (1984 ehf, AS44925) | **Yes** (desktop log) |
| `insightjs[.]com`, `www.`, `portal.`, `docs.` subdomains | Same domain family | No: blocked as a precaution |
| `insightjs[.]org`, `www.insightjs[.]org` | Reported backup domain | No: blocked as a precaution |
| `89.126.250[.]172` | Second address in community lists | No: blocked as a precaution |

Status: the `.com` domain has been on **client hold** since November 5, 2026 and no longer resolves.

## Log lines (the fastest way to check)

In the launcher's `intl_service\debug.log`:

```
"lua downloaded to log\tinyget\tinyget.<date>-<time>.log"
"k2f_chan registered"
"agent started as <your PC name>"
```

In the launcher's `log\tinyget\` logs:

```
url=hxxps://analytics.insightjs[.]com/comm/assets/insight.bundle
Connected to analytics.insightjs[.]com (89.127.233[.]127) port 443
total=205135
```

*(Defanged here. In your real logs the address appears without the brackets. The easiest words to search for are `insight.bundle` and `insightjs`.)*

If you find the first block, the agent ran on that PC at that time. Each occurrence is one infection.

## Files and storage

| Indicator | Where | Seen by me |
|---|---|---|
| A ~205 KB file named like a log, `tinyget.<date>-<time>.log`, that is not text | `<launcher>\log\tinyget\` | Download record yes; the file deletes itself |
| `k2f.agent.state` | The launcher's browser storage (leveldb) | **Yes** (both PCs) |
| Changed loader entries in the launcher's code cache | The launcher's cache folder | **Yes** (desktop, 2 of 4) |
| `platform_experience_helper.dll` | Reported in a browser-related folder under the user profile | Not found |
| `k2f*` files | `%TEMP%` | Not found |

## Registry

| Indicator | Seen by me |
|---|---|
| A CLSID entry under `HKCU\Software\Classes\CLSID\` pointing at the DLL above (reported: `{E77CC89B-7401-4C04-8CED-149DB35ADD04}`) | Not found |

## Timeframe

Anyone who launched the Windows PC launcher **since September 27, 2026** is asked by the publisher to check. The changed files were replaced on November 3.

## Checking your own PC

1. Don't open the launcher.
2. Search `debug.log` for `lua downloaded`. Note every date and time.
3. **Copy the launcher's `log` and `intl_service` folders somewhere safe** before running any cleanup tool.
4. Then follow the official check, or one of the community check kits listed in the credits. Read a tool before you run it.
