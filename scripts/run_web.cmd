@echo off
set "SystemRoot=C:\Windows"
set "PATH=%PATH%;C:\Windows\System32;C:\Windows;C:\Windows\System32\WindowsPowerShell\v1.0"
if not defined PORT set "PORT=8765"
flutter run -d web-server --web-port %PORT% --web-hostname 127.0.0.1
