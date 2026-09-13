# iPhone diagnostics guide

*Branch `claude/iphone-system-analysis-3fhpk5`, 13 September 2026.*

**Status:** no iPhone data has reached me yet. This repository contains no diagnostic files, and a search of your Google Drive found nothing that looks like one. This page explains what the 300 MB file is, three ways to get it to me, and what you can check on the phone right now. Once the data arrives I will write `iphone-diagnosis-report.md` with a ranked list of what needs fixing.

## 1. What the 300 MB file is

It is almost certainly a **sysdiagnose** archive, the standard iPhone diagnostic dump. The name looks like:

```
sysdiagnose_2026.09.12_18-32-10+0100_iPhone-OS_iPhone_23A341.tar.gz
```

It is created when you press Volume Up + Volume Down + Side button together for about 1.5 seconds (the phone vibrates), and it appears roughly 10 minutes later in Settings → Privacy & Security → Analytics & Improvements → Analytics Data. 200 to 500 MB is normal, because it contains:

| Part of the archive | Typical size | What it is |
|---|---|---|
| `system_logs.logarchive` | 150–400 MB (80–90 % of the file) | the complete system log of the last days, in a binary format only a Mac can read |
| `crashes_and_spins/` | 1–30 MB | every crash, hang, kernel panic and out-of-memory report: **the most useful part** |
| `logs/` | 5–50 MB | battery, app installation, Wi-Fi, cellular, iCloud and update logs |
| `ps.txt`, `vm_stat.txt`, `disks.txt`, `ioreg.txt`, `spindump-nosymbols.txt`, … | under 20 MB | a snapshot of processes, memory, storage and hardware |

About 90 % of the file is not needed for a first diagnosis. The routes below send only the useful 10 %.

If your file has a different name or extension (`.logarchive`, `.ips`, `.zip`, `.ipsw`, a backup folder), tell me the exact name and size and I will adjust the instructions.

## 2. Three ways to get the data to me

What works and what does not:

- **This chat:** too small for 300 MB. If it lets you attach small files, individual crash reports (Route A) can go straight in.
- **Google Drive:** I can read **small** files from your Drive (crash reports, screenshots, a zip of a few MB). I cannot download a 300 MB file from it.
- **This GitHub repository:** I can read anything committed here. The browser upload accepts files up to 25 MB, up to 100 files at once.
- **Email:** I can see attachment names in your Gmail but cannot open attachments. Do not email the file.

**Privacy first.** A sysdiagnose contains Wi-Fi network names, the list of installed apps, device identifiers and some location-related data. It has no passwords, messages or photos, but it is still personal. Before uploading to GitHub, make the repository private: github.com/eugenenikolajev-blip/hi → Settings → scroll down to Danger Zone → Change visibility → Private. Individual crash reports (Route A) contain far less: mostly process names and stack traces.

### Route A: phone only, 5 minutes. Send the crash reports (do this first)

1. On the iPhone: Settings → Privacy & Security → Analytics & Improvements → Analytics Data. (If the list is empty, switch on "Share iPhone & Watch Analytics" one screen back and wait a day.)
2. The list is alphabetical. Tap the newest files whose names start with `panic-full`, `JetsamEvent`, `stacks`, `ExcResource`, `ExcUserFault`, `SpringBoard`, `backboardd`, `LowBatteryLog`, and any file named after an app that misbehaves, for example `Instagram-2026-09-12-183210.ips`. Ten to fifteen files are enough.
3. Inside each file tap the Share icon (top right) → **Drive** → save into a folder called `iphone-logs` in My Drive. (Or Share → Save to Files, and upload the folder to Drive later.)
4. Also take a screenshot of the Analytics Data list itself, scrolled to the crash files, and put it in the same folder. It shows me how often each type occurs.
5. Tell me "uploaded to Drive". I read the files through the Drive connection.

### Route B: computer, 10 minutes. Shrink the archive to under 25 MB and upload it here (recommended)

1. Get the `.tar.gz` onto a Mac: in Analytics Data tap the `sysdiagnose_…` entry → Share → AirDrop, or Share → Save to Files → iCloud Drive.
2. Save the script `tools/sysdiagnose-slim.sh` from this repository into your Downloads folder (open it on GitHub and use the download button, or Raw → File → Save Page As).
3. Open Terminal and run:

   ```
   bash ~/Downloads/sysdiagnose-slim.sh ~/Downloads/sysdiagnose_XXXX.tar.gz
   ```

   Replace the name with your file. A trick: type `bash ~/Downloads/sysdiagnose-slim.sh ` and then drag the archive from Finder into the Terminal window; its path is filled in. With no file name at all the script picks the newest `sysdiagnose_*.tar.gz` in Downloads or Desktop by itself.

   It runs for one to two minutes and creates `sysdiagnose_XXXX-slim.zip` next to the archive. If the zip is bigger than 24 MB it is cut into `…-slim.zip.part-aa`, `part-ab`, … instead: upload all of the parts.
4. Upload: open github.com/eugenenikolajev-blip/hi → branch dropdown → `claude/iphone-system-analysis-3fhpk5` → open the folder `iphone-logs` → **Add file → Upload files** → drag the zip (or all the parts) in → **Commit changes**.
5. Tell me "uploaded to GitHub".

**On Windows** (no Mac): Windows 10 and 11 include `tar`. In PowerShell:

```
cd $HOME\Downloads
mkdir sd
tar --exclude=system_logs.logarchive --exclude=*.tailspin --exclude=*.ktrace --exclude=*.PLSQL --exclude=*.pklg -xzf sysdiagnose_XXXX.tar.gz -C sd
Compress-Archive -Path sd\* -DestinationPath sysdiagnose-slim.zip
```

If `sysdiagnose-slim.zip` is over 25 MB, install 7-Zip, right-click the `sd` folder → 7-Zip → Add to archive → Archive format `zip`, "Split to volumes" `24m`, and upload all the `.zip.001`, `.zip.002`, … files. (The Windows commands are written from the documentation; I could only test the Mac/Linux script.)

### Route C: the whole 300 MB (only if I ask for it)

On a Mac, in Terminal:

```
cd ~/Downloads
split -b 24m sysdiagnose_XXXX.tar.gz sysdiagnose_XXXX.tar.gz.part-
```

This produces about 13 files named `…part-aa`, `…part-ab`, … Upload all of them as in Route B step 4. I join them back together here. If `git` is installed, pieces of 90 MB (`split -b 90m …`) pushed with git also work.

## 3. What to check on the phone today (10 minutes)

| # | Check | Where | Bad sign | What to do |
|---|---|---|---|---|
| 1 | iOS version | Settings → General → Software Update | an update is waiting | back up (iCloud or computer), then install. Many "mystery" problems disappear with the next iOS point release |
| 2 | Free storage | Settings → General → iPhone Storage | less than about 10 % free, or "System Data" above 20 GB | offload unused apps, delete videos, Messages → Review Large Attachments. A huge System Data only shrinks after a restore (step 10) |
| 3 | Battery health | Settings → Battery → Battery Health & Charging | Maximum Capacity under 80 %, a "Service" message, or "performance management has been applied" | battery replacement at Apple or an authorised provider. Slowness, sudden shutdowns and restarts on a cold morning are the classic symptoms |
| 4 | Battery hogs | Settings → Battery → Last 10 Days | one app with large "background activity" | Settings → General → Background App Refresh → off for that app; update or reinstall it |
| 5 | Crash reports | Settings → Privacy & Security → Analytics & Improvements → Analytics Data | see the decoding table below | Route A |
| 6 | Non-genuine parts | Settings → General → About → Parts and Service History (only shown after a repair) | "Unknown Part" next to Battery, Display or Camera | explains battery, Face ID, True Tone and auto-brightness problems after a third-party repair |
| 7 | Overheating | note when it happens: which app, charging, sunlight, navigation | hot while idle with the screen off | a stuck background process or a battery fault: restart, update, then Route A |
| 8 | Wi-Fi or cellular dropping | Settings → General → Transfer or Reset iPhone → Reset → Reset Network Settings | | keeps your data; you re-enter Wi-Fi passwords |
| 9 | General misbehaviour | same menu → Reset All Settings | | keeps photos, apps and data; resets Wi-Fi, wallpaper, layout and privacy choices |
| 10 | Last software step | back up → Erase All Content and Settings → set up as **new** → test for a day → restore the backup only if the problem is gone | the problem survives a clean setup | hardware: go to step 11 |
| 11 | Hardware check | Apple Support app → book a Genius Bar diagnostic (free), or Apple's Diagnostics for Self Service Repair at diagnostics.apple.com (available in the US and most of Europe; the site explains how to put the phone into diagnostics mode) | | |

### Decoding the Analytics Data list

| File name starts with | Meaning | Usual fix |
|---|---|---|
| `panic-full-` or `panic-base-` | kernel panic: the whole system crashed and rebooted | update iOS; if it repeats more than once or twice a month, hardware is likely (see the panic strings below) |
| `JetsamEvent-` | an app was killed for using too much memory, or the system ran out of memory | normal a few times a week. Many per day: reinstall the app named inside, free storage, restart |
| `stacks-` | a hang: an app or a system process froze | update the app; if the file names `SpringBoard`, do Reset All Settings |
| `ExcResource-` | an app exceeded its CPU or memory limits (drains the battery) | update or reinstall that app, switch off its Background App Refresh |
| `ExcUserFault_` | a non-fatal internal error reported by a system process, which kept running | informative only, unless there are dozens per day |
| `Instagram-2026-…ips` (any app name) | that app crashed | update, then delete and reinstall. If the name is a system process (`SpringBoard`, `backboardd`, `mediaserverd`, `CommCenter`, `wifid`, `bluetoothd`) it is an iOS problem: update, reset settings, restore |
| `LowBatteryLog-` | the phone shut down because the battery voltage collapsed | battery replacement, especially with capacity under 85 % |
| `wakeups_` | which processes wake the phone in the background | shows the battery drain culprit |
| `Analytics-…core_analytics`, `AggregateHeartbeat` | daily statistics | ignore |
| `sysdiagnose_….tar.gz` | the big archive | the 300 MB file |

Inside a `panic-full` file the first lines contain a `panicString`. The words there point to the cause:

- `userspace watchdog timeout: no successful checkins from <process>`: a system daemon hung. Usually software: update iOS, Reset All Settings, restore.
- `Sleep Wake failure`: the phone failed to wake. Usually software or a stuck accessory, sometimes the battery.
- `ANS2`, `NAND`, `APFS`: the storage chip. Back up immediately, then Apple service.
- `AOP`, `SMC`, `SEP`, `PMU`, `i2c`, `SPI`: a hardware controller. Apple service.
- `thermalmonitord`, `thermal`: shut down for overheating.
- `AppleBaseband`, `baseband`, `CommCenter`: the cellular modem. Reset Network Settings first, then service.

## 4. What I will do when the data arrives

1. Count and date every panic, crash, hang, memory kill and low-battery shutdown, and rank them by frequency.
2. Identify the process or app behind each one, and sort them into three buckets: an app bug, an iOS fault, or a hardware signal.
3. Check memory pressure, free storage, battery capacity and cycle count, thermal throttling, cellular and Wi-Fi errors, and app install or update failures.
4. Cross-check the installed iOS build against known issues for that version.
5. Write `iphone-diagnosis-report.md` in this repository: a ranked list of what needs fixing, each item with severity, the evidence (file and line), and the concrete action, separated into free software steps and paid hardware service.

## 5. Кратко по-русски

Файл на 300 МБ — почти наверняка **sysdiagnose** (`sysdiagnose_….tar.gz`), стандартный диагностический архив iPhone. 200–500 МБ — норма; 90 % объёма занимает бинарный системный лог, который для первичной диагностики не нужен. Данных от вас я пока не получил: в репозитории и на Google Drive ничего нет.

Три способа передать данные:

- **A. Только телефон, 5 минут (сделайте сначала).** Настройки → Конфиденциальность и безопасность → Аналитика и улучшения → Данные аналитики. Откройте 10–15 свежих файлов, названия которых начинаются с `panic-full`, `JetsamEvent`, `stacks`, `ExcResource`, `LowBatteryLog`, `SpringBoard`, плюс файлы с названием проблемного приложения. В каждом: значок «Поделиться» (вверху справа) → Drive → папка `iphone-logs`. Добавьте скриншот самого списка. Напишите мне «загрузил на Drive».
- **B. Компьютер, 10 минут (рекомендую).** Перенесите `.tar.gz` на Mac (AirDrop из того же меню). Скачайте `tools/sysdiagnose-slim.sh` из этого репозитория в «Загрузки» и в Терминале выполните `bash ~/Downloads/sysdiagnose-slim.sh ~/Downloads/sysdiagnose_XXXX.tar.gz`. Скрипт делает zip меньше 25 МБ (или несколько частей `.part-aa`, `.part-ab`, …). Загрузите результат на GitHub: репозиторий → ветка `claude/iphone-system-analysis-3fhpk5` → папка `iphone-logs` → Add file → Upload files → Commit changes. Напишите мне «загрузил на GitHub». Команды для Windows — в разделе 2.
- **C. Весь файл целиком** — только если я попрошу: `split -b 24m файл.tar.gz файл.tar.gz.part-` и загрузить все части так же, как в B.

Перед загрузкой на GitHub сделайте репозиторий приватным: Settings → Danger Zone → Change visibility → Private. В архиве есть имена Wi‑Fi‑сетей, список приложений и идентификаторы устройства (паролей, сообщений и фото нет).

Что проверить на телефоне сегодня: обновление iOS; свободное место (не меньше ~10 %); Настройки → Аккумулятор → Состояние аккумулятора (ёмкость ниже 80 % — менять батарею); какое приложение тратит батарею в фоне; при проблемах с сетью — Сброс настроек сети; при общих сбоях — Сбросить все настройки (данные сохраняются); крайняя мера — резервная копия и восстановление «как новый»; если проблема остаётся после чистой установки — это железо, диагностика в Apple.
