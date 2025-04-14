# Headless-Zero-2-W-Setup
For setting a Raspberry Pi Zero 2 W up for Dev Projects.

# Pi Zero Robotics Setup

A terminal-first, modular setup suite for embedded robotics and automation projects using Raspberry Pi Zero 2 W.

## Features

- **Structured project layout** for ESP32 scripting, camera streaming, and Nintendo Switch controller emulation
- **CLI-driven installer** with robust error handling, backup protection, and virtual environment provisioning
- **Automatic logging** of all steps, warnings, and failures to `~/SetupNotes/logs/`
- **Post-install integrity checker** that ensures directories, venvs, and dependencies are all in expected locations
- **Optional cleanup prompts** to keep your headless system lightweight

## Directory Layout

```plaintext
~/robotics-hub/
├── esp32/                # UART and firmware flashing tools
├── camera/               # Video capture and processing scripts
├── switch-emulation/     # JoyControl and HID gadget scripts
├── interface/            # Web-based control dashboard (Flask)
├── utils/                # Setup, monitor, and boot scripts
└── .env/                 # Python virtual environments
```

## Setup

```bash
chmod +x final_setup_with_bitarray_fix.sh
./final_setup_with_bitarray_fix.sh
```

Run the optional file structure validator:

```bash
./verify_project_integrity.sh
```

## Logs and Backups

- Setup logs: `~/SetupNotes/logs/`
- Backups before overwrite: `~/SetupNotes/backups/`

## Repository

GitHub: [github.com/swope44/pi-zero-robotics-setup](https://github.com/swope44/pi-zero-robotics-setup)

## License

MIT License — open for use, modification, and extension with attribution.
