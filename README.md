![webserpent (Klein)](https://github.com/THEBROTHERHD/webserpent/assets/96993697/2dff13dd-d22d-4f54-859f-e934aaa33b8f)

# Welcome to Webserpent
Webserpent offers a convenient way to transform your web application into a standalone executable (EXE) file using Python. It requires a valid Python installation on the system. All other necessary components are installed automatically.

## What is Webserpent Used For?
Webserpent is ideal for smaller web projects that you wish to distribute as Windows applications to your users. It allows for the conversion of website source code into a desktop app. However, it's important to note:
- Webserpent does not substitute your backend infrastructure.
- It is not an alternative to Node.js Packagers like NodeJS-Natifier.

## Capabilities of Webserpent
- Converts plain HTML, JavaScript, and CSS webpages or web apps into native applications.
- Includes additional resources in the packaging.
- Compiles all dependencies into a single executable file.
- Offers customizable output window settings for the Webserpent app.

## Limitations of Webserpent
- It does not provide backend functionalities for your web app (like PHP, Node.js frameworks, REST APIs, etc.).
- Only the frontend part of web apps can be 'natified'.
- It cannot natify Node.js applications.

## How to Use Webserpent
Before starting, ensure you have Python 3 installed. Here’s a step-by-step guide:
1. Download `Webserpent.exe` and place it in the root of your source directory.
2. Add an icon file (PNG) to your directory, which will be used for your app's icon.
3. Optionally, create a `webserpent_config.json` file for additional configurations.
4. Run the Command Prompt as Administrator in your directory.
5. Execute the command: `./WebSerpent.exe "App Name" "index.html" "icon.png"`. Replace placeholders with the actual paths to your source files.
6. Watch the process unfold!
7. Locate your newly created EXE file in the `dist` folder.

## Configure the Output
Put a `webserpent_config.json` inside your root folder
```json
{
    "window": {
        "width": 1200,
        "height": 800,
        "x_position": 0,
        "y_position": 0,
        "zoom_factor": 1.0,
        "frameless": false,
        "resizable": true,
        "always_on_top": false,
        "fullscreen": false,
        "context_menu_enabled": false
    },
    "browser": {
        "plugins_enabled": true,
        "javascript_enabled": true,
        "javascript_can_open_windows": true,
        "javascript_can_access_clipboard": true,
        "local_storage_enabled": true,
        "local_content_can_access_remote_urls": true,
        "local_content_can_access_file_urls": true,
        "screen_capture_enabled": true
    }
}
```

## How Does Webserpent Work?
Interested in the mechanics? Webserpent generates a PyQT5 Web Browser Application in the background, displaying your webpage. It temporarily copies your entire source to a `webserpent` directory. Finally, it uses PyInstaller to bundle an executable file containing all source files and the Python script.
