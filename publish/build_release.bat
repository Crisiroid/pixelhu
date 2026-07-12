@echo off
REM ========================================
REM PixelHu - Build Release AAB Script
REM ========================================

echo ========================================
echo   PixelHu - Build Release AAB
echo ========================================
echo.

REM Check if Flutter is installed
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: Flutter is not installed or not in PATH
    echo Please install Flutter first: https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

REM Clean previous builds
echo Cleaning previous builds...
flutter clean
if %errorlevel% neq 0 (
    echo ERROR: Failed to clean project
    pause
    exit /b 1
)
echo.

REM Get dependencies
echo Getting dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Failed to get dependencies
    pause
    exit /b 1
)
echo.

REM Check if key.properties exists
if not exist "..\android\key.properties" (
    echo WARNING: key.properties not found!
    echo.
    echo Please follow these steps first:
    echo 1. Run generate_key.bat to create a signing key
    echo 2. Move the key.jks file to android/ directory
    echo 3. Update android/key.properties with your passwords
    echo.
    pause
    exit /b 1
)

REM Check if keystore file exists
for /f "tokens=2 delims==" %%i in ('findstr "storeFile" "..\android\key.properties"') do set storeFile=%%i
if not exist "..\android\%storeFile%" (
    echo ERROR: Keystore file not found: %storeFile%
    echo Please generate a signing key first using generate_key.bat
    pause
    exit /b 1
)

REM Build the AAB
echo.
echo Building release AAB...
echo This may take a few minutes...
echo.
flutter build appbundle --release
if %errorlevel% neq 0 (
    echo.
    echo ERROR: Failed to build AAB
    echo Please check the error messages above
    pause
    exit /b 1
)

echo.
echo ========================================
echo   Build Successful!
echo ========================================
echo.
echo AAB file location:
echo build\app\outputs\bundle\release\app-release.aab
echo.
echo Next steps:
echo 1. Test the AAB file using Google Play's internal testing
echo 2. Upload to Google Play Console
echo 3. Fill in store listing details (see STORE_LISTING.md)
echo 4. Submit for review
echo.
echo IMPORTANT: Keep your keystore file safe!
echo You will need it for all future updates.
echo.
pause
