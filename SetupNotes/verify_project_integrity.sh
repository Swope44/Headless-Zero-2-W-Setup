#!/bin/bash

set -euo pipefail

PROJECT_ROOT="$HOME/robotics-hub"
SETUP_NOTES="$HOME/SetupNotes"
LOG_DIR="$SETUP_NOTES/logs"
BACKUP_DIR="$SETUP_NOTES/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
VERIFICATION_LOG="$LOG_DIR/verify_log_$TIMESTAMP.txt"

exec > >(tee -a "$VERIFICATION_LOG") 2>&1

echo "===== Verifying Robotics Hub Structure: $TIMESTAMP ====="

declare -A EXPECTED_DIRS=(
  ["esp32/scripts"]=1 ["esp32/firmware"]=1 ["esp32/logs"]=1
  ["camera/capture"]=1 ["camera/streaming"]=1 ["camera/processing"]=1 ["camera/test_frames"]=1
  ["switch-emulation/joycontrol"]=1 ["switch-emulation/hid-gadget"]=1 ["switch-emulation/macros"]=1
  ["interface/web"]=1 ["interface/endpoints"]=1 ["interface/static"]=1
  ["utils/boot_scripts"]=1 ["utils/monitor"]=1 ["utils/setup"]=1
  [".env"]=1
)

echo
echo "Checking expected directories under $PROJECT_ROOT..."

pushd "$PROJECT_ROOT" > /dev/null

missing=0
for dir in "${!EXPECTED_DIRS[@]}"; do
    if [ ! -d "$dir" ]; then
        echo "MISSING: $dir"
        missing=1
    fi
done

echo
echo "Checking for unknown files or folders..."

unknown_items=()
while IFS= read -r path; do
    relpath="${path#$PROJECT_ROOT/}"
    if [ -z "${EXPECTED_DIRS[$relpath]+_}" ]; then
        unknown_items+=("$relpath")
    fi
done < <(find "$PROJECT_ROOT" -mindepth 1 -maxdepth 2 -type d)

if [ ${#unknown_items[@]} -gt 0 ]; then
    echo
    echo "WARNING: The following unexpected directories were found:"
    for item in "${unknown_items[@]}"; do
        echo "  - $item"
    done
    echo
    read -p "Do you recognize these directories and want to keep them? (yes/no): " answer
    if [[ "$answer" != "yes" ]]; then
        echo "Cleaning up unknown directories..."
        for item in "${unknown_items[@]}"; do
            rm -rf "$PROJECT_ROOT/$item"
            echo "Removed: $item"
        done
    else
        echo "Keeping all unknown items as per user confirmation."
    fi
else
    echo "No unexpected directories found."
fi

echo
echo "Checking venvs and required dependencies..."

if [ ! -d "$PROJECT_ROOT/.env/esp32" ] || [ ! -d "$PROJECT_ROOT/.env/camera" ] || [ ! -d "$PROJECT_ROOT/.env/web" ]; then
    echo "One or more venvs are missing."
else
    source "$PROJECT_ROOT/.env/esp32/bin/activate"
    pip freeze | grep -q bitarray || echo "MISSING: bitarray in esp32 venv"
    deactivate

    source "$PROJECT_ROOT/.env/camera/bin/activate"
    pip freeze | grep -q opencv-python || echo "MISSING: opencv-python in camera venv"
    deactivate

    source "$PROJECT_ROOT/.env/web/bin/activate"
    pip freeze | grep -q flask || echo "MISSING: flask in web venv"
    deactivate
fi

popd > /dev/null

echo
echo "===== Verification Complete. Log: $VERIFICATION_LOG ====="
