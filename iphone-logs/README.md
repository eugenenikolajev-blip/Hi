# iphone-logs

Drop iPhone diagnostic files in this folder. Instructions are in `../iphone-diagnostics-guide.md`.

What belongs here:

- `sysdiagnose_…-slim.zip`, or its `…-slim.zip.part-aa`, `part-ab`, … pieces, made by `tools/sysdiagnose-slim.sh`
- individual crash reports (`.ips` files) from Settings → Privacy & Security → Analytics & Improvements → Analytics Data
- screenshots of the Analytics Data list, Battery Health, and iPhone Storage

GitHub's browser upload accepts files up to 25 MB, up to 100 files at once. Do not upload the full 300 MB `.tar.gz` as one file.

Keep this repository private while these files are here: they contain device identifiers, Wi-Fi network names and the list of installed apps.
