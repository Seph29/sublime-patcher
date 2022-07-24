#!/bin/bash
prompt_yn() {
	def=$2

	# Normalize default answer and prompt
	case $def in
		[yY]) def="y"; read -r -p "${1} [Y/n] " input;;
		[nN]) def="n"; read -r -p "${1} [y/N] " input;;
	esac

	# Echo 1 if yes else 0
	case $input in
		"")
			if [ $def = "y" ]; then
	echo 1
			else
	echo 0
			fi
		;;
		[yY][eE][sS]|[yY]) echo 1;;
		[nN][oO]|[nN]|*) echo 0;;
	esac
}

get_license_path() {
  locations=(
    "/home/$SUDO_USER/.config/sublime-text/Local"
    "/home/$SUDO_USER/.config/sublime-text-3/Local"
  )
  for i in "${locations[@]}"; do
    if [ -d "$i" ]; then
      echo "$i/License.sublime_license"
      break
    fi
  done
}

# update_check
get_update_check() {
  python -c "import ast;print(ast.literal_eval(open(r\"${1}\").read().replace('true','True').replace('false','False')).get('update_check'))"
}

set_update_check() {
  python -c "import ast,json;j=ast.literal_eval(open(r\"${1}\").read().replace('true','True').replace('false','False'));j['update_check']=$2;json.dump(j,open(r\"${1}\",mode='w'),indent=2)"
}
# update_check

backup() {
	echo "Backing up '${1}' to '${2}'"
	sudo cp "${1}" "${2}"
}

patch() {
	if [ ! -f "$1" ]; then
		echo "Invalid file '$1'"
		exit 1
	fi

	# Patching an executable
	echo "Patching '$1'..."
	md5sum -c <<<"995ECF34C58C6096E2AA7570BAC2B7A6  $1" || exit
	printf '\x48\x31\xC0\xC3'                 | dd of=$1 bs=1 seek=$((0x003A1BF4)) conv=notrunc status=none
	printf '\x90\x90\x90\x90\x90'             | dd of=$1 bs=1 seek=$((0x00397CE7)) conv=notrunc status=none
	printf '\x90\x90\x90\x90\x90'             | dd of=$1 bs=1 seek=$((0x00397D02)) conv=notrunc status=none
	printf '\x48\x31\xC0\x48\xFF\xC0\xC3'     | dd of=$1 bs=1 seek=$((0x003A37E0)) conv=notrunc status=none
	printf '\xC3'                             | dd of=$1 bs=1 seek=$((0x003A18B8)) conv=notrunc status=none
	printf '\xC3'                             | dd of=$1 bs=1 seek=$((0x0038B4D0)) conv=notrunc status=none
	# Applyting license file
	echo "Applying license..."
	echo "Free license <3" > $2
	echo "Done."
}

restore() {
	sudo mv "$2" "$1"
	echo "Patches removed."

	if [ -f "$3" ]; then
		sudo rm "$3"
		echo "License file removed."
	fi
}

# Superuser check
if [ ! "$SUDO_USER" ]; then
	echo "Script requires superuser privileges"
	echo "Try using: sudo ${0}"
	exit 1
fi

# Apt installation check
FILE=/opt/sublime_text/sublime_text
if [ ! -f "$FILE" ]; then
	echo "Sublime Text must be an APT package"
	echo "Check out https://www.sublimetext.com/docs/linux_repositories.html#apt"
	exit 1
fi

# Detecting version
BUILD=$(subl --version | sed -E "s/Sublime Text Build ([0-9]+)/\1/")
echo "Sublime Text ($BUILD) detected"

# License file path
LICENSE=$(get_license_path)

# User preferences file path
PREFERENCES="/home/$SUDO_USER/Library/Application Support/Sublime Text 3/Packages/User/Preferences.sublime-settings"

# Making backup
BACKUP="${FILE}_backup"
if [ ! -f "$BACKUP" ]; then
	backup "${FILE}" "${BACKUP}"
	patch "$FILE" "$LICENSE" "$PREFERENCES"
else
	PS3="Select an option: "

	select opt in "Patch" "Restore from backup"
	do
		if [[ $REPLY == 1 ]]; then
			yn=$(prompt_yn "Backup file '${BACKUP}' already exists. Replace?" "n")
			if [ $yn -eq 1 ]; then
				backup "${FILE}" "${BACKUP}"
			fi

			patch "$FILE" "$LICENSE"
		elif [[ $REPLY == 2 ]]; then
			restore "$FILE" "$BACKUP" "$LICENSE"
		else
			echo "Invalid option."
		fi
		exit 1
	done
fi
