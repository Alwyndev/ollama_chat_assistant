# Mobile Connection Guide for Ollama Chat Assistant

## Quick Setup Steps

### 1. Find Your Computer's IP Address

**On Windows:**
```cmd
ipconfig
```
Look for "IPv4 Address" under your WiFi adapter (usually starts with 192.168.x.x)

**On Mac/Linux:**
```bash
ifconfig
# or
ip addr show
```

### 2. Configure Ollama to Accept External Connections

**Stop Ollama first:**
```bash
ollama stop
```

**Start Ollama with external access:**
```bash
# Windows (PowerShell)
$env:OLLAMA_HOST="0.0.0.0:11434"
ollama serve

# Mac/Linux
OLLAMA_HOST=0.0.0.0:11434 ollama serve
```

### 3. Configure Firewall

**Windows:**
1. Open Windows Defender Firewall
2. Click "Allow an app or feature through Windows Defender Firewall"
3. Click "Change settings" → "Allow another app"
4. Browse to your Ollama executable
5. Make sure both Private and Public are checked

**Mac:**
- System Preferences → Security & Privacy → Firewall
- Add Ollama to allowed applications

### 4. Connect Your Mobile Device

1. Install the APK on your Android device
2. Open the app
3. Tap the settings icon (⚙️) or floating action button
4. Enter your computer's IP address (e.g., 192.168.1.8)
5. Port should be 11434
6. Tap "Save & Test"

### 5. Troubleshooting

**If connection fails:**
- Ensure both devices are on the same WiFi network
- Check that Ollama is running with `OLLAMA_HOST=0.0.0.0:11434`
- Verify firewall settings
- Try pinging your computer's IP from another device
- Check that port 11434 is not blocked by your router

**Common IP addresses:**
- 192.168.1.x (common home networks)
- 192.168.0.x (some routers)
- 10.0.0.x (some networks)

**Test connection from command line:**
```bash
curl http://YOUR_COMPUTER_IP:11434/api/tags
```

## App Features

- **File Support**: Upload any file type (up to 512MB)
- **Image Processing**: Extract text from images
- **Code Formatting**: Automatic syntax highlighting for code files
- **Model Switching**: Choose from 8 different AI models
- **Chat History**: Separate conversations for each model

## Supported Models

- phi3:latest - Lightweight and efficient
- gemma:latest - Google's open model
- mistral:latest - Strong reasoning
- dolphin-mistral:latest - Tuned for conversations
- neural-chat:latest - Interactive chatbot
- deepseek-coder:latest - Programming tasks
- starcoder2:latest - Coding + general use
- codellama:latest - Coding tasks

## Tips

- Use the floating action button (⚙️) to quickly access settings
- Tap "Change" next to the connection status to modify settings
- The app automatically shows connection settings on physical devices
- Settings are saved locally on your device
- Large files are processed efficiently without loading into memory 