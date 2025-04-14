    #!/bin/bash

    set -euo pipefail

    PROJECT_ROOT="$HOME/robotics-hub"
    ENV_ROOT="$PROJECT_ROOT/.env"
    NOTES_DIR="$HOME/SetupNotes"
    LOG_DIR="$NOTES_DIR/logs"
    BACKUP_DIR="$NOTES_DIR/backups"
    LOG_FILE="$LOG_DIR/setup_log_20250413_215612.txt"
    ERROR_LOG="$LOG_DIR/error_log_20250413_215612.txt"
    SYSTEMD_DIR="$HOME/.config/systemd/user"

    mkdir -p "$NOTES_DIR" "$LOG_DIR" "$BACKUP_DIR"
    exec > >(tee -a "$LOG_FILE") 2>&1

    echo "===== Robotics Project Setup Started at $(date) ====="

    echo "Installing build tools and Python headers..."
    sudo apt update
    sudo apt install -y build-essential python3-dev python3-venv python3-pip libffi-dev

    echo "Creating project directories..."
    mkdir -p "$PROJECT_ROOT"

    mkdir -p "$PROJECT_ROOT/esp32/firmware" "$PROJECT_ROOT/esp32/scripts" "$PROJECT_ROOT/esp32/logs"
    mkdir -p "$PROJECT_ROOT/camera/capture" "$PROJECT_ROOT/camera/streaming" "$PROJECT_ROOT/camera/processing" "$PROJECT_ROOT/camera/test_frames"
    mkdir -p "$PROJECT_ROOT/switch-emulation/joycontrol" "$PROJECT_ROOT/switch-emulation/hid-gadget" "$PROJECT_ROOT/switch-emulation/macros"
    mkdir -p "$PROJECT_ROOT/interface/web" "$PROJECT_ROOT/interface/endpoints" "$PROJECT_ROOT/interface/static"
    mkdir -p "$PROJECT_ROOT/utils/boot_scripts" "$PROJECT_ROOT/utils/monitor" "$PROJECT_ROOT/utils/setup"
    mkdir -p "$ENV_ROOT" "$SYSTEMD_DIR"

    backup_file() {
        FILE_PATH="$1"
        if [ -f "$FILE_PATH" ]; then
            cp "$FILE_PATH" "$BACKUP_DIR/$(basename $FILE_PATH).bak_20250413_215612"
            echo "Backup created for $(basename $FILE_PATH)"
        fi
    }

    create_venv() {
        MODULE_PATH=$1
        ENV_NAME=$2
        PACKAGES=$3

        echo "Setting up venv for $ENV_NAME..."
        cd "$MODULE_PATH" || { echo "Failed to access $MODULE_PATH"; exit 1; }

        if [ ! -d "$ENV_ROOT/$ENV_NAME" ]; then
            python3 -m venv "$ENV_ROOT/$ENV_NAME" || {
                echo "Failed to create venv for $ENV_NAME"
                exit 1
            }
        fi

        echo "#!/bin/bash" > activate.sh
        echo "source $ENV_ROOT/$ENV_NAME/bin/activate" >> activate.sh
        chmod +x activate.sh

        echo "Installing packages for $ENV_NAME..."
        source "$ENV_ROOT/$ENV_NAME/bin/activate"

        pip install --upgrade pip
        if ! pip install $PACKAGES bitarray; then
            echo "ERROR: Package installation failed for $ENV_NAME. See $ERROR_LOG"
            echo "[$(date)] Failed to install packages for $ENV_NAME: $PACKAGES" >> "$ERROR_LOG"
        fi
        deactivate
    }

    create_systemd_service() {
        SERVICE_NAME=$1
        EXEC_COMMAND=$2
        SERVICE_FILE="$SYSTEMD_DIR/$SERVICE_NAME.service"

        echo "Creating systemd user service for $SERVICE_NAME..."
        mkdir -p "$(dirname $SERVICE_FILE)"

        cat <<EOF > "$SERVICE_FILE"
[Unit]
Description=$SERVICE_NAME autostart

[Service]
ExecStart=$EXEC_COMMAND
Restart=on-failure

[Install]
WantedBy=default.target
EOF
        systemctl --user daemon-reexec
        systemctl --user enable --now "$SERVICE_NAME.service" || echo "Service $SERVICE_NAME failed to start."
    }

    # Backup and generate files
    backup_file "$PROJECT_ROOT/.gitignore"
    cat <<EOF > "$PROJECT_ROOT/.gitignore"
.env/
*.pyc
__pycache__/
logs/
capture/
test_frames/
EOF

    backup_file "$PROJECT_ROOT/README.md"
    cat <<EOF > "$PROJECT_ROOT/README.md"
# Robotics Hub - Raspberry Pi Zero 2 W

This project organizes components for robotics, ESP32 integration, camera processing, Switch controller emulation, and web control interface.

See \`utils/setup/\` for setup logs and boot scripts.
EOF

    echo "Creating virtual environments with package sets..."
    create_venv "$PROJECT_ROOT/esp32/scripts" "esp32" "pyserial esptool"
    create_venv "$PROJECT_ROOT/camera/processing" "camera" "opencv-python picamera2 numpy"
    create_venv "$PROJECT_ROOT/interface/web" "web" "flask gunicorn"

    echo "Initializing Git repository..."
    cd "$PROJECT_ROOT"
    git init
    git add .
    git commit -m "Initial project structure and environment setup"

    echo "Creating boot stub service..."
    EXAMPLE_SCRIPT="$PROJECT_ROOT/utils/boot_scripts/start_camera_stub.sh"
    echo -e "#!/bin/bash\necho 'Camera boot stub started at $(date)' >> $PROJECT_ROOT/camera/log.txt" > "$EXAMPLE_SCRIPT"
    chmod +x "$EXAMPLE_SCRIPT"

    create_systemd_service "start-camera-stub" "$EXAMPLE_SCRIPT"

    echo "===== Setup Complete at $(date) ====="
    echo "Main log: $LOG_FILE"
    echo "Errors (if any): $ERROR_LOG"
    echo "Backups stored in: $BACKUP_DIR"
