@echo off
set "SystemRoot=C:\Windows"
set "PATH=%PATH%;C:\Windows\System32;C:\Windows;C:\Windows\System32\WindowsPowerShell\v1.0"
flutter run -d web-server --web-port 8765 --web-hostname 127.0.0.1
