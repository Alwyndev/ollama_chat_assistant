# Distribution Guide for Ollama Chat Assistant

## Available Builds

### Android APK (25.7 MB)
- **File**: `build/app/outputs/flutter-apk/app-release.apk`
- **Best for**: Android phones and tablets
- **Installation**: Enable "Install from unknown sources" and open the APK

### Windows Executable (19.2 MB)
- **File**: `build/windows/x64/runner/Release/ollama_assistant.exe`
- **Dependencies**: `flutter_windows.dll`, `file_selector_windows_plugin.dll`, `data/` folder
- **Best for**: Windows computers

## Distribution Methods

### 1. **Direct File Sharing (Simplest)**

**For Android:**
- Share the APK file via:
  - Email attachment
  - Google Drive/Dropbox/OneDrive
  - USB transfer
  - Direct download link

**For Windows:**
- Create a ZIP file containing:
  - `ollama_assistant.exe`
  - `flutter_windows.dll`
  - `file_selector_windows_plugin.dll`
  - `data/` folder (entire folder)

### 2. **Create a Windows Installer Package**

**Option A: Simple ZIP Package**
```bash
# Create a distribution folder
mkdir ollama_assistant_windows
copy build\windows\x64\runner\Release\* ollama_assistant_windows\
# Zip the folder and share
```

**Option B: Use Inno Setup (Professional)**
- Download Inno Setup
- Create an installer script
- Generates a single .exe installer

### 3. **Network Distribution**

**Option A: Shared Network Drive**
- Place the app on a shared network drive
- Users can run directly from the network location

**Option B: Web Server**
- Upload to a web server
- Provide download links
- Users download and install locally

## Installation Instructions for Users

### Android Installation:
1. Enable "Install from unknown sources" in Settings → Security
2. Download the APK file
3. Open the APK file to install
4. Launch the app and configure connection settings

### Windows Installation:
1. Extract the ZIP file to a folder
2. Run `ollama_assistant.exe`
3. The app will create necessary folders automatically
4. Configure connection settings in the app

## Prerequisites for Users

### All Users Need:
- Ollama installed and running on their computer
- Ollama configured to accept external connections:
  ```bash
  OLLAMA_HOST=0.0.0.0:11434 ollama serve
  ```
- Firewall configured to allow port 11434

### Network Requirements:
- Both devices on the same network
- Computer's IP address accessible from mobile device
- Port 11434 not blocked by router

## Troubleshooting for Users

### Common Issues:
1. **"Failed to connect" error**
   - Check if Ollama is running with external access
   - Verify IP address is correct
   - Ensure firewall allows port 11434

2. **"App won't install" (Android)**
   - Enable "Install from unknown sources"
   - Check if APK is corrupted (re-download)

3. **"App won't start" (Windows)**
   - Ensure all DLL files are in the same folder
   - Check Windows Defender isn't blocking the app
   - Run as administrator if needed

## Security Considerations

### For Distribution:
- The app doesn't require internet access
- All data stays local
- No personal information is collected
- Users control their own Ollama server

### For Users:
- Only install from trusted sources
- Keep Ollama server secure
- Use strong passwords if exposing to internet

## Version Management

### To Update the App:
1. Build new versions using:
   ```bash
   flutter build apk --release
   flutter build windows --release
   ```
2. Share new files with users
3. Users replace old files with new ones

### Version Tracking:
- Consider adding version numbers to filenames
- Example: `ollama_assistant_v1.2.0.apk`
- Keep a changelog for users

## Support

### For Users:
- Provide the connection guide (`CONNECTION_GUIDE.md`)
- Share the debug button in the app for troubleshooting
- Encourage users to check the connection guide first

### For You:
- Monitor for common issues
- Update the app based on user feedback
- Consider creating a simple FAQ document 