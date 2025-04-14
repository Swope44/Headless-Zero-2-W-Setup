# Setup Notes

Place the 'SetupNotes' folder at the root of your setup, then add the remaining scripts inside this directory. The scripts use a path to reach and execute the functions used to automate the setup. They also store temporary backups and logs to allow you to easily restore any changes and manage error handling. The logs are included in the `.gitignore` to protect any potentially sensitive information.

When the setup is finished, this file can be removed to save space if needed. Just run:

```bash
sudo rm -r /SetupNotes
sudo rm -r ~/SetupNotes

# Further instructions

There is additional details inside of the folder.