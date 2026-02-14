# Image Gallery - LÖVE2D

A simple and elegant image gallery application built with LÖVE2D (Love2D), featuring a grid view and fullscreen viewing with multiple input methods.

## Features

- **Grid View**: Browse all images in a responsive thumbnail grid
- **Fullscreen View**: View images fitted to your window size
- **Multiple Input Methods**:
  - **Keyboard**: Arrow keys to navigate, Enter to view fullscreen, Escape to return
  - **Mouse**: Click thumbnails to view, right-click to return to grid
  - **Gamepad**: D-pad to navigate, A button to select, B button to go back
- **Auto-loading**: Automatically loads all .jpg and .png files from the `images/` folder
- **Responsive**: Grid layout adjusts to window size, window is resizable

## Controls

### Grid View
- **Arrow Keys / D-Pad**: Navigate through images
- **Enter / A Button / Left Click**: View selected image fullscreen
- **Mouse Wheel**: Scroll through the grid

### Fullscreen View
- **Left/Right Arrows / D-Pad**: Navigate to previous/next image
- **Escape / B Button / Right Click**: Return to grid view

## Installation

1. Install LÖVE2D from [https://love2d.org/](https://love2d.org/)
2. Clone this repository:
   ```bash
   git clone https://github.com/ETdoFresh/image-gallery-love2d.git
   cd image-gallery-love2d
   ```

## Running the Application

### On macOS/Linux:
```bash
love .
```

### On Windows:
Drag the project folder onto the LÖVE executable, or run:
```cmd
"C:\Program Files\LOVE\love.exe" .
```

### Creating a Standalone Executable:
Follow the [LÖVE distribution guide](https://love2d.org/wiki/Game_Distribution) to package the application for your platform.

## Adding Your Own Images

1. Place your `.jpg` or `.png` images in the `images/` folder
2. The application will automatically load them on startup
3. No code changes needed!

## Project Structure

```
image-gallery-love2d/
├── main.lua          # Main application logic
├── conf.lua          # LÖVE configuration
├── images/           # Image folder (contains 4 sample landscape images)
│   ├── image1.jpg
│   ├── image2.jpg
│   ├── image3.jpg
│   └── image4.jpg
└── README.md         # This file
```

## Sample Images

This repository includes 4 beautiful landscape/nature images from Unsplash:
- Mountain landscape
- Forest scene
- Ocean/beach view
- Sunset sky

Images are sourced from [Unsplash](https://unsplash.com/) and are free to use under the Unsplash License.

## Technical Details

- **Framework**: LÖVE2D 11.4+
- **Language**: Lua
- **Default Resolution**: 1280x720 (resizable)
- **Thumbnail Size**: 256x144 pixels
- **Supported Formats**: JPG, JPEG, PNG

## Requirements

- LÖVE2D version 11.4 or higher

## License

This project is open source and available under the MIT License.

## Author

Created by ETdoFresh

---

Enjoy browsing your images! 📷✨
