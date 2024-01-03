# PowerShell-Skript-Version von WebSerpent Setup

# Clear the screen
Clear-Host
Write-Host ""
Write-Host "************************************************************"
Write-Host "*                    WebSerpent Setup                     *"
Write-Host "************************************************************"
Write-Host ""

# Write some information about the script
Write-Host "WebSerpent will create an .exe file for your Web-App."
Write-Host "The .exe file will be created in the 'dist' directory."
Write-Host "To configure the Output, please create and modify a 'webserpent_config.json' file."
Write-Host "For more information, please visit WebSerpent's GitHub page."
Write-Host "This script needs to be run as administrator."
Write-Host ""
Write-Host "This script depends on a valid Python installation on the system. All other dependencies will be installed automatically."

# arguments - 1: app name, 3: index.html, 4: favicon.png

# Check if the script was executed with arguments
if (!($args.Length -eq 3)){
    Write-Host "[Error] Please run this script with the following arguments:"
    Write-Host "<app name> <path 2 index.html> <path 2 favicon.png>"
    pause
    return
}

# Assign the argument to a variable
$APPNAME = $args[0]
$INDEX = $args[1]
$FAVICON = $args[2]

# replace backslashes with forward slashes
$INDEX = $INDEX.Replace("\", "/")
$FAVICON = $FAVICON.Replace("\", "/")

# replace ./ with nothing
$INDEX = $INDEX.Replace("./", "")
$FAVICON = $FAVICON.Replace("./", "")

# Check if script is executed as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    Write-Host "[Error] Please run this script as administrator."
    pause
    return
}

# Check for Python installation
$pythonInstalled = $null -ne (Get-Command python -ErrorAction SilentlyContinue)
if (-not $pythonInstalled) {
    Write-Host "[Error] Python is not installed. Please install Python first."
    pause
    return
}

# Check if favicon.png exists
if (!(Test-Path -Path $FAVICON)) {
    Write-Host "[Error] Icon not found."
    pause
    return
}

# Check if index.html exists
if (!(Test-Path -Path $INDEX)) {
    Write-Host "[Error] Index-File not found."
    pause
    return
}

# Check for pip installation
$pipInstalled = $null -ne (Get-Command pip -ErrorAction SilentlyContinue)
if (-not $pipInstalled) {
    Write-Host "[Pre-Setup] Pip is not installed. Installing pip..."
    python -m ensurepip
}


Write-Host "[Step 1] Installing required Python packages..."
python -m pip install --upgrade pip
python -m pip install PyQt5 PyQtWebEngine pyinstaller -ErrorAction Stop

Write-Host "[Step 2] Creating Python script for $APPNAME..."
$pythonCode = @"
import sys
import os
from PyQt5.QtWidgets import QApplication, QMainWindow
from PyQt5.QtWebEngineWidgets import QWebEngineView
from PyQt5.QtGui import QIcon
from PyQt5.QtCore import QUrl
from PyQt5.QtCore import Qt
from PyQt5.QtWebEngineWidgets import QWebEngineSettings
import json

def resource_path(relative_path):
    """Get absolute path to resource, for PyInstaller."""
    base_path = getattr(sys, '_MEIPASS', os.path.dirname(os.path.abspath(__file__)))
    return os.path.join(base_path, relative_path)

class BrowserWindow(QMainWindow):
    def __init__(self):
        super().__init__()

   # Default settings
        default_config = {
            "window": {
                "width": 1200,
                "height": 800,
                "x_position": 0,
                "y_position": 0,
                "zoom_factor": 1.0,
                "frameless": False,
                "resizable": True,
                "always_on_top": False,
                "fullscreen": False,
                "context_menu_enabled": True
            },
            "browser": {
                "plugins_enabled": True,
                "javascript_enabled": True,
                "javascript_can_open_windows": True,
                "javascript_can_access_clipboard": True,
                "local_storage_enabled": True,
                "local_content_can_access_remote_urls": True,
                "local_content_can_access_file_urls": True,
                "screen_capture_enabled": True
            }
        }

        # Load settings from config.json if it exists, otherwise use default settings
        config_file = 'webserpent_config.json'
        if os.path.isfile(config_file):
            with open(config_file) as f:
                config = json.load(f)
        else:
            config = default_config

        # Apply window settings
        self.setGeometry(config['window']['x_position'], config['window']['y_position'], 
                         config['window']['width'], config['window']['height'])
        self.setWindowFlags(Qt.FramelessWindowHint) if config['window']['frameless'] else None
        self.setWindowFlags(self.windowFlags() | Qt.WindowStaysOnTopHint) if config['window']['always_on_top'] else None
        self.setWindowFlags(self.windowFlags() | Qt.CustomizeWindowHint | Qt.MSWindowsFixedSizeDialogHint) if not config['window']['resizable'] else None
        self.showFullScreen() if config['window']['fullscreen'] else None

        self.browser = QWebEngineView()
        self.setCentralWidget(self.browser)

        self.browser.setContextMenuPolicy(Qt.PreventContextMenu) if not config['window']['context_menu_enabled'] else None

        # Apply browser settings
        settings = QWebEngineSettings.globalSettings()
        settings.setAttribute(QWebEngineSettings.PluginsEnabled, config['browser']['plugins_enabled'])
        settings.setAttribute(QWebEngineSettings.JavascriptEnabled, config['browser']['javascript_enabled'])
        settings.setAttribute(QWebEngineSettings.JavascriptCanOpenWindows, config['browser']['javascript_can_open_windows'])
        settings.setAttribute(QWebEngineSettings.JavascriptCanAccessClipboard, config['browser']['javascript_can_access_clipboard'])
        settings.setAttribute(QWebEngineSettings.LocalStorageEnabled, config['browser']['local_storage_enabled'])
        settings.setAttribute(QWebEngineSettings.LocalContentCanAccessRemoteUrls, config['browser']['local_content_can_access_remote_urls'])
        settings.setAttribute(QWebEngineSettings.LocalContentCanAccessFileUrls, config['browser']['local_content_can_access_file_urls'])
        settings.setAttribute(QWebEngineSettings.ScreenCaptureEnabled, config['browser']['screen_capture_enabled'])

        index_path = resource_path('index.html')
        self.browser.setUrl(QUrl.fromLocalFile(index_path))

        icon_path = resource_path('favicon.png')
        self.setWindowIcon(QIcon(icon_path))

if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = BrowserWindow()
    window.show()
    sys.exit(app.exec_())

"@

Set-Content -Path browser_app.py -Value $pythonCode

Write-Host "[Step 3] checking for webserpent directory..."
if (Test-Path -Path webserpent) {
    Write-Host "[Step 3] Webserpent directory already exists. Skipping..."
    Write-Host ""
} else {
    Write-Host "[Step 3] Creating Webserpent directory for $APPNAME..."
    # Create the webserpent directory if it does not exist
    if (!(Test-Path -Path webserpent)) {
        New-Item -ItemType Directory -Path webserpent
    }

    # Use robocopy to move all files and folders in the current directory to the webserpent directory
    # Exclude the browser_app.py, WebSerpent.ps1, and .spec files
    robocopy . webserpent /E /XD dist build __pycache__ /XF browser_app.py WebSerpent.ps1 *.spec
}

Write-Host "[Step 4] Creating executable for $APPNAME..."

# Run PyInstaller with the generated add-data options
pyinstaller --onefile --windowed --name "$APPNAME" -i "./webserpent/$FAVICON" --add-data "./webserpent:data" browser_app.py


Write-Host "[Step 5] Cleaning up..."
Remove-Item -Path browser_app.py -ErrorAction SilentlyContinue
Remove-Item -Path webserpent -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path build -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path "$APPNAME.spec" -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "************************************************************"
Write-Host "*           Setup Complete! Executable Created.           *"
Write-Host "* Find the executable in the 'dist' directory. Enjoy!     *"
Write-Host "************************************************************"
Write-Host ""
pause
