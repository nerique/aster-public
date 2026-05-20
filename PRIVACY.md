# Aster Disk — Privacy Policy

**Last updated:** 2026-05-16

## The short version

Aster Disk runs entirely on your Mac. We don't collect anything. There is no analytics, no telemetry, no crash reporting, no cloud sync, no user accounts, no email signup. Your scan results, your trophy progress, and your settings live on your computer and never leave it.

## What Aster Disk reads

To do its job — telling you what's taking up space on your disk — Aster Disk reads:

- **File names, sizes, paths, and modification dates** for every directory you ask it to scan. This is the same metadata that `du`, Finder, or any file manager reads.
- **The contents of `Info.plist` files inside `.app` bundles** to identify installed apps for the Installed Apps page and the Path Explainer.

Aster Disk does **not** read:

- The contents of your documents, photos, videos, or any other file. We look at sizes and dates, never bytes.
- Your network activity.
- Your calendar, contacts, mail, browser history, keychain, or anything else not directly disk-related.

## What Aster Disk stores on your Mac

Aster Disk persists a few things in the standard macOS user-data locations:

- **`UserDefaults`** (under your user account) — your settings (cleanup-rule thresholds, excluded paths, density preference, theme override, snoozed suggestions), trophy progress, lifetime byte counters, the first-use date.
- **`~/Library/Containers/com.nerique.aster.Aster/`** (App Store sandbox container) — compact summaries of past scans, used for the "what changed since last scan" diff. These contain only metadata (path + size + modification date) for items above the significance threshold; they do not contain file contents.

Uninstall Aster Disk and the container disappears with it. Or use Aster Disk's own uninstall flow on itself (it'll find both the bundle and the container).

## What Aster Disk sends over the network

Nothing.

There is no first-party server. We don't make HTTP requests on your behalf. The app does not auto-update over the network — new versions come via the Mac App Store's standard update mechanism.

## Apple Intelligence (on macOS 26+)

When the curated knowledge base + heuristics can't identify a folder, Aster Disk optionally falls back to Apple's on-device Foundation Models framework for a one-paragraph natural-language explanation. This is **strictly on-device**: the framework runs in-process, no network request is made, and the prompt + response never leave your Mac. Aster Disk does not log, store, or transmit any AI-generated text.

The fallback only activates when the underlying macOS feature is enabled in System Settings. You can confirm status — and turn it on or off — under **Settings → Apple Intelligence** inside Aster Disk. Aster Disk works fully without it.

## App permissions Aster Disk requests

- **Full Disk Access** (optional, recommended) — required by macOS to read protected paths like Mail, Messages, Safari, and Time Machine snapshots. Without it, those paths report 0 bytes and are skipped. The choice to grant is yours; Aster Disk does not nag.
- **Apple Events to Finder** — used only to empty the Trash when you choose "Empty Trash & Quit." macOS prompts you the first time. Decline and the feature is disabled; Aster Disk doesn't try again.
- **Photos / Calendar / Contacts / Reminders** — macOS may prompt for these mid-scan if your disk usage includes those libraries' data. Decline and those report 0 bytes.

Aster Disk does not request: location, microphone, camera, screen recording, accessibility, automation of any other app, or any other privacy-protected resource.

## Children

Aster Disk is not directed at children under 13 and does not knowingly collect any data from anyone — child or adult — because it does not collect data, period.

## Data we share with third parties

None. We don't have data to share. There is no analytics provider, no advertising network, no embedded SDK, no payment processor (the Mac App Store handles purchases when those exist; we never see your payment information).

## Changes to this policy

If we ever change Aster Disk's data handling — for example, if a future version adds optional cloud sync — that change will require a new privacy-policy version, a clearly-marked release note, and explicit user opt-in. We will not flip a default that sends data anywhere off-device.

## Contact

Bug reports + feature requests: [open an issue](https://github.com/nerique/aster-public/issues).

Email: `privacy@asterdisk.com`.

— Julien Balmont, Aster Disk maintainer
