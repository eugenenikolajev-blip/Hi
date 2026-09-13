# iPhone diagnosis report

*13 September 2026. Source: the two sysdiagnose archives in your Dropbox folder "Iphone system", taken on 13 September at 13:52 and 13:56 London time. I analysed the first one in full; the second is identical apart from one extra stack snapshot. The archives were processed in the temporary sandbox of your connected Composio tool, because this environment cannot download from Dropbox directly. The 660 MB binary system log inside the archive could not be scanned to the end: the remote sandbox was reset by its provider three times mid-run. Everything below comes from the crash index, the hardware registry, the battery, camera, audio, storage and network dumps, which are complete.*

## Verdict

**Symptoms reported:** the phone freezes all the time, and the microphone does not work in the Camera app. **Question:** which parts to order.

**Answer: on the evidence, no part is proven faulty, and nothing should be ordered yet.**

- **Freezes.** In 30 days the phone has not once crashed at kernel level, been reset by the watchdog, or overheated. A failing logic board, storage chip or touch controller leaves exactly those traces, and there are none. What the logs do show is a phone under constant software load: Apple's own search and intelligence indexing services broke their CPU budget 11 times between 20 August and 3 September and were again the busiest processes at the moment of the diagnostic (the day after the iOS 26.6.2 update), memory ran out 5 times in a month, 39 app crash or termination reports were filed, and background app activity runs 12 hours a day. That profile produces exactly "the phone freezes all the time": short hangs that recover by themselves. The fix sequence is in section 3, and only if freezes survive a clean software install does a hardware part (display assembly for touch, or the logic board) come into question. One thing the logs cannot tell me: whether the screen has ever been replaced outside Apple. An aftermarket display is the single most common hardware cause of touch freezes; check Settings → General → About → Parts and Service History.
- **Camera microphone.** The hardware registry shows the audio codec attached, all four built-in microphones present, no liquid detected in the port, and a live microphone session at the moment you took the diagnostic. The registry cannot say whether sound actually reaches the recording; that needs the 5-minute test matrix in section 4, which tells you which microphone (if any) is dead and therefore which part. The Camera app's sound settings are not at their defaults (audio configuration 2, wind-noise reduction on, audio playback allowed), so reset them first.
- **Backup is broken.** iCloud Backup has failed 5 times in a row; the last attempts on 12 September at 20:20 and 20:38 were cancelled because the Wi-Fi condition was lost. Before any reset or restore, make a backup to a computer.

## 1. Device

| Item | Value |
|---|---|
| Model | iPhone17,2 = iPhone 16 Pro Max, 1 TB, 8 GB RAM |
| iOS | 26.6.2 (build 23G90), installed 12 Sep 2026 at 10:15, previous build 23G83 |
| Last restart | 12 Sep 2026 11:24 (after the update); 26.5 hours before the diagnostic, awake for 17.2 of them |
| In use since | 22 Nov 2024 (restored from a backup of an iOS 18.1 device); battery data since 13 Nov 2024 |
| Region, languages | GB; English (UK), Russian |
| Management | Not supervised, no company management; one configuration profile installed |
| Lockdown Mode | Off |
| Storage | 1 TB, 379 GB free; data volume 534 GB used |

Evidence: `spindump-nosymbols.txt`, `logs/SystemVersion/SystemVersion.plist`, `logs/OTAUpdateLogs/`, `logs/MobileBackup/com.apple.MobileBackup.plist`, `logs/MCState/`, `disks.txt`.

## 2. Symptom 1: freezes

### What the logs rule out

| Check | Result | Meaning |
|---|---|---|
| Kernel panics (`panic-*.ips`) | none in 30 days; the diagnostic tool searched explicitly | no hard crash of the OS |
| Watchdog resets, forced restarts | none; the only restart in the window is the one the update required | the phone never locked up hard enough to be rebooted by the system |
| Hang tracer, window-server hang, memory-exception folders | empty | no logged multi-second system hang except one stack snapshot on 10 Sep 10:12 |
| Thermal | state nominal, level 0, no thermal log ever written | no throttling from heat |
| Storage | file-system check clean (12 Sep), 0 metadata read/write errors, 379 GB free | not a storage-chip problem |
| Liquid | liquid-detection state Idle | no liquid in the USB-C port |
| Battery | 93 %, 688 cycles, no service state | not a brown-out problem |

### What the logs show instead

- **Indexing load.** Apple's search, Siri and on-device intelligence daemons exceeded their CPU budget 11 times in two weeks: `spotlightknowledged` (3), `knowledgeconstructiond` (3), `SearchIndexer` (3), `duetexpertd` (2). At the moment of the diagnostic the busiest processes were `mobileassetd`, `siriknowledged`, `corespeechd` and `assetsubscriptiond` (asset downloads and speech/search indexing after the update), and the CPU ranking since the restart has `spotlightknowledged.updater`, `searchd`, `duetexpertd` and `mediaanalysisd` in its top ten.
- **Memory pressure.** 8 GB RAM, about 140 MB free and 1.6 GB compressed at capture; 5 out-of-memory kills in a month; 218 processes sitting idle in the background.
- **Background activity.** In 10 days: Chrome 64.5 hours in the background, WhatsApp 19.2 hours, Gmail 4 hours, Yandex Music 8 hours (playback). Background app time totals 12.3 hours per day.
- **App instability.** 39 crash or termination reports in 30 days: WhatsApp 7, ANNA Apple Pay extension 4, Instagram 3, Telegram 3, Maple 3, and 19 others once each, including the Face ID/passcode prompt service twice within 16 seconds on 8 Sep 09:48 and the audio daemon `audiomxd` on 24 Aug.
- **Stuck sync job.** One cloud-storage file provider has a sync job that failed with error −2011 and was retried 2,557 times.

### Fix sequence (stop when the freezes stop)

1. Two nights on the charger with Wi-Fi so indexing after the update finishes. Update WhatsApp, Telegram, Instagram.
2. Settings → General → Background App Refresh → off for Chrome, Gmail, Instagram, Temu. Close nothing else; iOS manages the rest.
3. Settings → General → Transfer or Reset iPhone → Reset → Reset All Settings (keeps data; you re-enter Wi-Fi passwords).
4. Backup to a computer (section 7), then Erase All Content and Settings, set up as **new** without restoring, use it for one day. Freezes gone: the cause was in the old data or an app; restore the backup and remove apps one by one. Freezes still there on a clean phone: hardware.
5. Hardware only at this point: Apple diagnostics (Apple Support app → Genius Bar, or diagnostics.apple.com). The candidate parts are the display assembly (if freezes are "touch stops responding" or the screen was replaced outside Apple) or the logic board (if the whole system stalls). Do not order either without that test.

## 3. Symptom 2: no microphone in the Camera app

### What the logs show

| Check | Result |
|---|---|
| Audio codec | `AppleCS42L79Audio`, device attached |
| Built-in microphones | 4 declared (`fmic`, `imic`, `lmic`, `smic`), high-power mic path with 4 input channels |
| Microphone state at capture (13:52) | `kAudioMessage_MicOn = Yes`: a microphone session was active |
| Liquid detection | Idle (no liquid in the USB-C port) |
| Audio daemon | `audiomxd` crashed once, 24 Aug; it is the third-heaviest CPU user since the restart (hours of calls and music, plausible) |
| Camera sound settings | `AudioConfiguration = 2`, `AudioWindRemoval = 1` (wind-noise reduction on), `MixAudioWithOthers = 1` (allow audio playback on), `AudioZoom = 0` |
| Camera capture error dumps | none present |

The registry proves the microphones are enumerated and powered; it cannot prove sound is captured. The Camera settings are not defaults, and in the Camera app the recording chain (which mic, how much processing) depends on them.

### The 5-minute test that decides the part

Before testing: remove the case and any camera-lens protector, brush out the tiny microphone hole on the camera bump next to the flash and the two holes beside the USB-C port, restart the phone, and reset the Camera sound settings (Settings → Camera → Record Sound or Record Video: wind-noise reduction off, allow audio playback off, standard/stereo recording).

| Test | Microphone used | Result to note |
|---|---|---|
| Voice Memos: record 5 s, play back | bottom | sound / no sound |
| Normal phone call, handset to ear: does the other side hear you? | bottom | |
| Same call on speakerphone | top (front) | |
| Camera, front camera, video 5 s, play back | top (front) | |
| Camera, rear camera, video 5 s, play back | rear (camera bump) | |
| WhatsApp or Instagram video with the rear camera | rear (camera bump) | |

Reading the result:

- **Only rear-camera video is silent, in every app:** the rear microphone is dead. Part: the flash and rear-microphone flex assembly on the camera bump (on the Pro models the flash and the rear mic share one flex). Cheap part, but the phone must be opened; any competent repair shop, no Apple parts pairing involved.
- **Rear-camera video silent only in the Camera app, fine in WhatsApp:** software. Reset Camera settings, Reset All Settings, then restore iOS. No part.
- **Calls also silent for the other side:** bottom microphones. Part: the USB-C charging-port flex assembly (the bottom mics sit on it).
- **Speakerphone or front video silent:** top microphone. Part: the earpiece speaker / top sensor flex.
- **Everything silent:** not a microphone at all; audio codec or software. Restore iOS via computer (DFU) before any repair; if still silent, Apple service (logic board), not a shop.

## 4. Stability data behind section 2

The phone keeps its crash reports for about a month. The index (`summaries/crashes_and_spins.log`) for 14 August to 13 September:

| Report type | Count | Meaning |
|---|---|---|
| WhatsApp | 7 | 12 Sep 16:02 was a background kill for holding a file lock (0xDEAD10CC); the others predate the archive window |
| ANNA Apple Pay extension | 4 | same background-lock kill; harmless unless paying with the ANNA card fails |
| Instagram | 3 | crashes 15, 30, 31 Aug |
| Telegram | 3 | iOS killed it for taking more than 5 s to exit while writing a file (0x8BADF00D); a Telegram bug, harmless |
| Maple | 3 | crashes 20 Aug, 26 Aug, 7 Sep |
| One each | 17 | Bolt, Ryanair, Alipay, WeChat, eBay, ChatGPT, Perplexity, hidemy.name VPN, Claude, Maps, Gmail, Whoop, share and widget extensions, Wallet UI, `audiomxd`, Face ID prompt service (twice, 8 Sep) |
| JetsamEvent (out of memory) | 5 | 18 Aug (3), 19 Aug, 1 Sep |
| System services over CPU budget | 11 | the indexing daemons listed in section 2 |
| Apps over disk-write budget | 13 | Whoop, Maple, Gmail, Instagram, YouTube, Meta AI, WhatsApp and Apple's indexers; informational |
| Hang snapshot | 1 | 10 Sep 10:12 |
| Wi-Fi link-quality reports | 4 | poor Wi-Fi somewhere, not a phone fault |

Evidence: `crashes_and_spins/*.ips`, `summaries/Panics.log`, `summaries/crashes_and_spins.log`, `spindump-nosymbols.txt`, `ltop.txt`, `jetsam_priority.txt`, `vm_stat.txt`.

## 5. Battery

| Measurement | Value | Assessment |
|---|---|---|
| Maximum capacity | 93 % (4320 mAh full charge vs 4630 mAh design) | good for 22 months |
| Cycle count | 688 | about one full charge per day |
| Service warning | Battery Service State 0 (none); "Battery Service Flags" = 3, undocumented | check the Battery Health screen; any message there changes the plan |
| Temperature at capture | 31 °C | normal |

Energy use over the 10 days to 13 September: 935 % of a full battery (one charge per day), 79 hours of foreground app use (7.9 h/day), 123 hours of background app time. Top consumers: WhatsApp 33.7 % (39.7 h foreground, 19.2 h background, 6.8 h calls), Instagram 16.7 % (11 h), HLS 8.5 %, Gmail 6.7 % (4 h background), Telegram 4.1 %, Yandex Music 3.2 % (8 h background playback), Photos 2.6 %, Chrome 2.6 % (64.5 h background), Google Maps 2.1 %, ChatGPT 2.0 %, poor cellular signal 0.8 %. No rogue drain; the battery empties because the phone is used all day. Apple rates this battery to keep 80 % after 1000 cycles; replacement is not due.

Evidence: `logs/BatteryHealth/BatteryHealth.log`, `ioreg/IOService.txt` (AppleSmartBattery), `logs/BatteryBDC/`, `logs/BatteryUIPlist/BatteryUISysdiagnose.plist`.

## 6. Storage, memory, network, thermal, update

- **Storage:** 1 TB, 379 GB free; `fsck_apfs` clean on 12 Sep 20:11; zero APFS metadata errors.
- **Memory:** 8 GB; about 1.6 GB compressed and 140 MB free at capture (normal for iOS); 5 out-of-memory kills in a month.
- **Wi-Fi at capture:** 5 GHz, 160 MHz channel, −55 dBm (strong), 1152 Mbps, WPA2, all connectivity checks passed. Wi-Fi Calling tunnels active. No modem crash or reset logs; periods of weak cellular signal visible in the battery data.
- **Bluetooth:** on, 24 paired devices, 2 connected at capture (AirPods), two BMW cars paired, no faults logged.
- **VPN:** hidemy.name and VPN360 installed; no tunnel active at capture; hidemy.name crashed once on 11 Sep.
- **Thermal:** nominal, level 0; no thermal event ever recorded.
- **Update:** 26.6.1 → 26.6.2 on 12 Sep 10:15–10:18, result SUCCESS; firmware sub-steps completed with tolerated retries. iOS 27 is due mid-September: only after a working backup.

Evidence: `disks.txt`, `apfs_stats.txt`, `logs/fsck/fsck_apfs.log`, `WiFi/wifi_status.txt`, `WiFi/diagnostics-connectivity.txt`, `WiFi/bluetooth_status.txt`, `logs/Networking/ifconfig.txt`, `logs/OTAUpdateLogs/ota_patch.txt`.

## 7. iCloud, backup and sync

- **iCloud Backup is failing.** `FailureCount = 5`; last attempts 12 Sep 20:20 (error 209) and 20:38 (error 202, "Backup cancelled (com.apple.backupd.wifi)"); next retry was scheduled for 13 Sep 12:06. The phone is not managing to finish a backup over Wi-Fi. With 534 GB of data this needs the phone locked, charging and on Wi-Fi for many hours. **Do a computer backup now** (Mac: Finder; Windows: Apple Devices app; tick "encrypt" so passwords and Health data are included), then leave the phone charging on Wi-Fi overnight to let iCloud catch up.
- iCloud Keychain: in the trusted circle, all views ready. iCloud Drive: no upload, download or sync errors.
- File Provider check: 3 of 389 files out of step and one job with error −2011 retried 2,557 times in one cloud-storage integration (iCloud Drive, Dropbox, Google Drive or VK Mail are installed). Reinstall or sign out and in of whichever of these you use least; if it is iCloud Drive, toggle it off and on.

Evidence: `logs/MobileBackup/com.apple.MobileBackup.plist`, `otctl_status.txt`, `ckksctl_status.txt`, `brctl/`, `FileProvider/fileproviderctl_check.log`.

## 8. What to do, in order

1. Computer backup (section 7). 10 minutes plus transfer time. Everything else is safe only after this.
2. Microphone test matrix (section 3). 5 minutes. It tells you the part, if any.
3. Freeze fix sequence (section 2), steps 1 to 3. Two days.
4. Check Settings → General → About → Parts and Service History and the Battery Health screen. Any "Unknown Part" or "Service" line goes into the decision.
5. Only if step 3 fails: clean install, then Apple diagnostics. Order a display or logic-board repair only on that result.
6. Background trims and battery care: Background App Refresh off for Chrome, Gmail, Instagram, Temu; Settings → Battery → Charging → Charge Limit 90 %; WhatsApp media auto-download on Wi-Fi only.

## 9. Open items

- The binary system log (660 MB) was not scanned to the end because the remote sandbox was reset by its provider during each run; it would give timestamps of individual hangs but would not change the parts decision. If you want it done, the archive can be opened on any Mac with the `log` command and I will give the exact filter.
- Which cloud-storage app owns the stuck sync job could not be read from the check log.
- "Battery Service Flags = 3" is undocumented; the Battery Health screen is the authority.
- App names "HLS" and "Maple" are reported as they appear in the logs.

## 10. Кратко по-русски

**Что с телефоном.** iPhone 16 Pro Max (1 ТБ), iOS 26.6.2 от 12 сентября. За 30 дней ни одной паники ядра, ни одного аварийного перезапуска, ни перегрева, ни ошибок памяти-накопителя, жидкости в разъёме нет, батарея 93 % (688 циклов, замена не нужна). **По логам ни одна деталь не признана неисправной. Заказывать пока нечего.**

**Зависания.** Это не умирающая плата и не накопитель: такие поломки оставляют паники и перезагрузки по watchdog, их нет. Телефон задыхается от нагрузки: системная индексация Apple (Spotlight, Siri, Apple Intelligence) 11 раз за две недели превысила лимит процессора и снова грузила его в момент диагностики (на следующий день после обновления), 5 раз заканчивалась память, 39 падений приложений за месяц (WhatsApp 7), фоновая активность 12 часов в сутки (Chrome 64 часа в фоне за 10 дней). Порядок: 1) две ночи на зарядке с Wi‑Fi, обновить WhatsApp/Telegram/Instagram; 2) выключить фоновое обновление у Chrome, Gmail, Instagram, Temu; 3) Сбросить все настройки; 4) резервная копия на компьютер → стереть → настроить как новый → день без восстановления; 5) зависает даже чистый — только тогда железо: диагностика Apple, кандидаты — дисплейный модуль (если «не отвечает тач» или экран когда-то меняли не в Apple: проверьте Настройки → Основные → Об этом устройстве → Запчасти и история обслуживания) или плата. Без этого теста детали не заказывать.

**Микрофон в камере.** По реестру железа кодек подключён, все 4 микрофона на месте, микрофон был активен в момент диагностики, жидкости нет. Пишется ли звук — лог не показывает, это решает 5‑минутный тест. Перед ним: снять чехол и защиту камеры, прочистить отверстие микрофона у вспышки и два отверстия у разъёма, перезагрузить, сбросить Настройки → Камера → Запись звука (шумоподавление ветра выкл., воспроизведение аудио выкл.). Тест: диктофон (нижний мик) → обычный звонок, слышат ли вас (нижний) → громкая связь (верхний) → видео фронталкой (верхний) → видео основной камерой в Камере и в WhatsApp (задний). Итог: тишина только на видео основной камерой во всех приложениях → задний микрофон, деталь: шлейф вспышки/заднего микрофона на блоке камер (дёшево, любая мастерская); тишина только в приложении Камера, а в WhatsApp есть → программное, сброс и восстановление iOS, деталь не нужна; не слышат в звонках → нижние микрофоны, деталь: шлейф разъёма USB‑C; громкая связь/фронталка → верхний микрофон, шлейф динамика/верхних датчиков; тишина везде → не микрофон, восстановление iOS через компьютер (DFU), потом только Apple.

**Срочно.** Резервная копия iCloud у вас не проходит: 5 отказов подряд, последние 12 сентября в 20:20 и 20:38 («отменено, потерян Wi‑Fi»). Сделайте копию на компьютер до любых сбросов.
