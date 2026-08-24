@echo off
set "SystemRoot=C:\Windows"
set "PATH=%PATH%;C:\Windows\System32;C:\Windows;C:\Windows\System32\WindowsPowerShell\v1.0"
if not defined PORT set "PORT=8765"
rem Public, non-secret value (same one deploy.yml bakes in from the repo's
rem GOOGLE_OAUTH_CLIENT_ID Actions variable) — set here purely so local
rem dev builds exercise Drive sync without an extra env var per session.
if not defined GOOGLE_OAUTH_CLIENT_ID set "GOOGLE_OAUTH_CLIENT_ID=277465842702-02nhrqclicbstvjltlfqafhprj9e4j13.apps.googleusercontent.com"
flutter run -d web-server --web-port %PORT% --web-hostname 127.0.0.1 --dart-define=GOOGLE_OAUTH_CLIENT_ID=%GOOGLE_OAUTH_CLIENT_ID%
