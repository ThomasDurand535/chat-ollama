#!/bin/bash

# Electron application installation/uninstallation script
# Usage: ./install.sh -b (build and install) or ./install.sh -i (install only) or ./install.sh -u (uninstall)

set -e

# Colors for messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="chat-ollama"
DIST_DIR="./dist"
ICON_SOURCE="./html/public/horrible-logo.png"
INSTALL_DIR="/opt/$APP_NAME"
DESKTOP_FILE="/usr/share/applications/$APP_NAME.desktop"
ICON_DIR="/usr/share/icons/hicolor/512x512/apps"
ICON_FILE="$ICON_DIR/$APP_NAME.png"

print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_error "This script requires root privileges. Use sudo."
        exit 1
    fi
}

# Build function
build_app() {
    print_message "Building application..."

    if [ ! -f "package.json" ]; then
        print_error "package.json file not found"
        exit 1
    fi

    # Remove old build if exists
    if [ -d "$DIST_DIR" ]; then
        print_message "Removing old build..."
        rm -rf "$DIST_DIR"
    fi

    # Build the application
    npm run build || {
        print_error "Application build failed"
        exit 1
    }

    print_message "Build completed successfully!"
}

# Installation function
install_app() {
    print_message "Starting installation of $APP_NAME..."

    # Check if dist directory exists
    if [ ! -d "$DIST_DIR" ]; then
        print_error "Directory $DIST_DIR does not exist."
        print_error "Please run with -b option to build first, or build manually."
        exit 1
    fi

    # Find AppImage in dist
    APPIMAGE=$(find "$DIST_DIR" -name "*.AppImage" | head -n 1)

    if [ -z "$APPIMAGE" ]; then
        print_error "No AppImage file found in $DIST_DIR"
        exit 1
    fi

    print_message "AppImage found: $APPIMAGE"

    # Remove old installation if exists
    if [ -d "$INSTALL_DIR" ]; then
        print_message "Removing old installation..."
        rm -rf "$INSTALL_DIR"
    fi

    # Create installation directory
    print_message "Creating installation directory..."
    mkdir -p "$INSTALL_DIR"

    # Copy AppImage
    print_message "Installing application..."
    cp "$APPIMAGE" "$INSTALL_DIR/$APP_NAME.AppImage"
    chmod +x "$INSTALL_DIR/$APP_NAME.AppImage"

    # Install icon
    print_message "Installing icon..."
    mkdir -p "$ICON_DIR"

    # Copy icon from project source
    if [ -f "$ICON_SOURCE" ]; then
        cp "$ICON_SOURCE" "$ICON_FILE"
        print_message "Icon installed from $ICON_SOURCE"
    else
        print_warning "Icon not found at $ICON_SOURCE"
        # Try to extract from AppImage as fallback
        cd "$INSTALL_DIR"
        ./"$APP_NAME.AppImage" --appimage-extract >/dev/null 2>&1 || true

        if [ -f "squashfs-root/usr/share/icons/hicolor/512x512/apps/"*.png ]; then
            cp squashfs-root/usr/share/icons/hicolor/512x512/apps/*.png "$ICON_FILE"
        elif [ -f "squashfs-root/"*.png ]; then
            cp squashfs-root/*.png "$ICON_FILE"
        else
            print_warning "No icon found"
        fi

        # Clean temporary folder
        rm -rf squashfs-root
        cd - > /dev/null
    fi

    # Create .desktop file
    print_message "Creating application launcher..."
    cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=$APP_NAME
Comment=My Electron Application
Exec=$INSTALL_DIR/$APP_NAME.AppImage
Icon=$APP_NAME
Terminal=false
Type=Application
Categories=Utility;
EOF

    chmod 644 "$DESKTOP_FILE"

    # Remove old symbolic link if exists
    if [ -L "/usr/local/bin/$APP_NAME" ]; then
        rm -f "/usr/local/bin/$APP_NAME"
    fi

    # Create symbolic link in /usr/local/bin
    print_message "Creating symbolic link..."
    ln -sf "$INSTALL_DIR/$APP_NAME.AppImage" "/usr/local/bin/$APP_NAME"

    # Update icon cache
    print_message "Updating icon cache..."
    gtk-update-icon-cache -f -t /usr/share/icons/hicolor >/dev/null 2>&1 || true
    update-desktop-database /usr/share/applications >/dev/null 2>&1 || true

    print_message "${GREEN}Installation completed successfully!${NC}"
    print_message "You can launch the application with: $APP_NAME"
    print_message "Or from your applications menu."
}

# Build and install function
build_and_install() {
    build_app
    check_root
    install_app
}

# Uninstallation function
uninstall_app() {
    print_message "Starting uninstallation of $APP_NAME..."

    # Remove installation directory
    if [ -d "$INSTALL_DIR" ]; then
        print_message "Removing installation directory..."
        rm -rf "$INSTALL_DIR"
    fi

    # Remove .desktop file
    if [ -f "$DESKTOP_FILE" ]; then
        print_message "Removing launcher..."
        rm -f "$DESKTOP_FILE"
    fi

    # Remove icon
    if [ -f "$ICON_FILE" ]; then
        print_message "Removing icon..."
        rm -f "$ICON_FILE"
    fi

    # Remove symbolic link
    if [ -L "/usr/local/bin/$APP_NAME" ]; then
        print_message "Removing symbolic link..."
        rm -f "/usr/local/bin/$APP_NAME"
    fi

    # Update cache
    print_message "Updating cache..."
    gtk-update-icon-cache -f -t /usr/share/icons/hicolor >/dev/null 2>&1 || true
    update-desktop-database /usr/share/applications >/dev/null 2>&1 || true

    print_message "${GREEN}Uninstallation completed successfully!${NC}"
}

show_help() {
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  -b, --build        Build and install the application (requires sudo)"
    echo "  -i, --install      Install the application (requires dist folder and sudo)"
    echo "  -u, --uninstall    Uninstall the application (requires sudo)"
    echo "  -h, --help         Show this help"
    echo ""
    echo "Example:"
    echo "  sudo $0 -b         # Build and install"
    echo "  sudo $0 -i         # Install only (dist must exist)"
    echo "  sudo $0 -u         # Uninstall"
}

# Process arguments
if [ $# -eq 0 ]; then
    show_help
    exit 1
fi

case "$1" in
    -b|--build)
        # Build doesn't need root, but install does
        build_app
        check_root
        install_app
        ;;
    -i|--install)
        check_root
        install_app
        ;;
    -u|--uninstall)
        check_root
        uninstall_app
        ;;
    -h|--help)
        show_help
        ;;
    *)
        print_error "Invalid option: $1"
        show_help
        exit 1
        ;;
esac

exit 0
