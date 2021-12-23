# sublime-patcher
Bash script for patching/cracking Sublime Text on Linux including newest build 4121

> **NOTES**
> 
> This script only works with an *apt* installation of Sublime Text, *snap* package cannot be supported because of it's read-only structure.
> 
> Sublime Text user preferences file interaction depends on Python so please make sure it's installed.

## Usage
### Patching (cracking)
1. Clone repository
2. Add exec rights to the script if needed
```bash
chmod +x ./sublime_patch-v4126.sh
```
3. Run script with superuser privileges
```bash
sudo ./sublime_patch-v4126.sh
```
4. Done

<details>
  <summary>Screenshots</summary>

  ![Patching proccess](https://i.imgur.com/xv2c223.png)
  ![Patching result](https://i.imgur.com/3SiVRqu.png)

</details>

### Removing patches
You have an option to remove patches and rollback to the original Sublime Text state.
In order to do that you need to run script again and choose "Restore from backup" option.


<details>
  <summary>Screenshots</summary>

  ![Restoring process](https://i.imgur.com/5Wjl3cq.png)
  ![Restoring result](https://i.imgur.com/TkKC4FE.png)

</details>
