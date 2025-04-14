# Robotics Hub - CLI Setup Guide

This system is designed for headless, terminal-first deployment. The following instructions outline how to run the setup, verify integrity, handle errors, and maintain a lightweight configuration.

---

## 1. Run the Setup Script

From the terminal, execute the following commands:

```bash
chmod +x final_setup_with_bitarray_fix.sh
./final_setup_with_bitarray_fix.sh
```

This script will:

- Set up the full project directory structure.
- Create Python virtual environments.
- Install required packages (e.g., `pyserial`, `bitarray`, `opencv`).
- Create `systemd` services and log actions.

---

## 2. Logs and Backups

- **Logs** are saved in: `~/SetupNotes/logs/`
  - Setup logs: `setup_log_YYYYMMDD_HHMMSS.txt`
  - Error logs: `error_log_YYYYMMDD_HHMMSS.txt`
- **Backups** (for critical files like `README` and `.gitignore`) are stored in: `~/SetupNotes/backups/`

---

## 3. If You Encounter Errors

1. **Check error logs**:

   ```bash
   cat ~/SetupNotes/logs/error_log_*.txt
   ```

2. **Fix missing dependencies** (e.g., `Python.h`):

   ```bash
   sudo apt install -y build-essential python3-dev
   ```

3. **Re-activate the virtual environment and retry installation**:

   ```bash
   source ~/robotics-hub/.env/esp32/bin/activate
   pip install bitarray
   ```

---

## 4. File Structure Check and Cleanup (Optional)

After the initial setup, you can run the verification script:

```bash
./verify_project_integrity.sh
```

This script will:

- Check if files and folders are in their expected locations.
- Warn if there are deviations.
- Prompt to clean up orphaned or unnecessary files.

---

## 5. Revert to a Clean State

To restore a backup of a critical file, use the following command:

```bash
cp ~/SetupNotes/backups/README.md.bak_YYYYMMDD_HHMMSS ~/robotics-hub/README.md
```

---

This guide ensures headless users can fully manage and troubleshoot the system from the terminal. **No GUI required.**
