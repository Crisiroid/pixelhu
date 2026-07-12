@echo off
REM Script to generate a new signing key for the app
REM Run this script from the android/app directory

echo Generating signing key for PixelHu...

keytool -genkey -v ^
  -keystore key.jks ^
  -keyalg RSA ^
  -keysize 2048 ^
  -validity 10000 ^
  -alias pixelhu_key

echo.
echo Key generation complete!
echo IMPORTANT: Move the key.jks file to the android/ directory (one level up)
echo IMPORTANT: Keep this file secure and backed up!
echo IMPORTANT: Never share this file or commit it to version control
echo.
echo After generating the key:
echo 1. Update android/key.properties with your passwords
echo 2. Run: flutter build appbundle --release
pause
