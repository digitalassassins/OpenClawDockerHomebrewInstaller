## Change these top variables to what you require
folder="my-openclaw" # change git storage folder and Docker Stack name
export OPENCLAW_GATEWAY_PORT=18789
export OPENCLAW_BRIDGE_PORT=18790
saveDirectory="config" # where to save the config files
export OPENCLAW_IMAGE_VERSION="2026.4.22" # last known stable version is 2026.4.22 as of 01-05-2026

## edit these if you know what you are doing
export OPENCLAW_IMAGE="ghcr.io/openclaw/openclaw:${OPENCLAW_IMAGE_VERSION}"
export OPENCLAW_HOME_VOLUME="home_data"
export OPENCLAW_CONFIG_DIR="./../${saveDirectory}/.openclaw/"
export OPENCLAW_WORKSPACE_DIR="${OPENCLAW_CONFIG_DIR}/workspace/"
export OPENCLAW_DOCKER_APT_PACKAGES="jq" # poppler-utils tesseract-ocr python3 python3-pip
export OPENCLAW_LINUXBREW_DIR="${OPENCLAW_CONFIG_DIR}/linuxbrew/"
export DOCKER_CLI_HINTS=false

## additional variables you may find useful.
#export OPENCLAW_EXTRA_MOUNTS="${OPENCLAW_LINUXBREW_DIR}:/home/linuxbrew/,${OPENCLAW_CONFIG_DIR}/.config:/home/.config/"
#export OPENCLAW_EXTENSIONS=""

## clean up old install
read -p "Would you like to clean the old install? [y/n]: " confirm
if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] ; then
	if [ -d "./${folder}/" ] ; then
		echo "Removing Git Folder.."
		rm -r -f "./${folder}/";
	fi
	if [ -d "./${saveDirectory}/.openclaw/linuxbrew/.linuxbrew/var/homebrew/tmp/" ]; then
		echo "Temp LinuxBrew Directory found.. Removing files.."
		rm -r -f "./${saveDirectory}/.openclaw/linuxbrew/.linuxbrew/var/homebrew/tmp/"
	fi
fi
if [ ! -d "./${folder}/" ]; then
	# pull from git
	if [ OPENCLAW_IMAGE_VERSION == "latest" ] ; then
		git clone https://github.com/openclaw/openclaw.git $folder
	else
		git clone -b v${OPENCLAW_IMAGE_VERSION} --single-branch https://github.com/openclaw/openclaw.git $folder
	fi
fi
## Would you like to skip onboarding?
read -p "Would you like to skip onboarding? [y/n]: " confirm
if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] ; then
	export OPENCLAW_SKIP_ONBOARDING="1"
else
	export OPENCLAW_SKIP_ONBOARDING="0"
fi
## now run the script
echo "Running main installer script.."
./$folder/scripts/docker/setup.sh
read -p "Would you like to install Linux Brew? [y/n]: " confirm
if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] ; then
	docker exec -it -u root $(docker ps -a --filter name=$folder --format '{{ .Names }}' | grep $folder) bash -c 'mkdir -p /home/linuxbrew/.linuxbrew && curl -L https://github.com/Homebrew/brew/tarball/main | tar xz --strip-components 1 -C /home/linuxbrew/.linuxbrew && useradd -m -s /bin/bash brewuser && echo '"'"'brewuser:brewpass'"'"' | chpasswd && chown -R brewuser:brewuser /home/linuxbrew && printf '"'"'#!/bin/bash\necho brewpass | su - brewuser -c "/home/linuxbrew/.linuxbrew/bin/brew $*"\n'"'"' > /usr/bin/brew && chmod +x /usr/bin/brew && echo '"'"'export PATH="/usr/bin:$PATH"'"'"' >> ~/.bashrc && echo '"'"'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'"'"' >> ~/.bashrc && source ~/.bashrc'
	read -p "Would you like to install OpenAI Whisper? [y/n]: " confirm
	if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] ; then
		docker exec -it -u root $(docker ps -a --filter name=$folder --format '{{ .Names }}' | grep $folder) bash -c 'brew install openai-whisper'
	fi
fi
read -p "Would you like to install Himalaya? [y/n]: " confirm
if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] ; then
	docker exec -it -u root $(docker ps -a --filter name=$folder --format '{{ .Names }}' | grep $folder) bash -c 'curl -sSL https://raw.githubusercontent.com/pimalaya/himalaya/master/install.sh | sh'
fi
## set the current clawdock directory to this working container. Many of Clawdock's features are included in OpenClaw now and will probably be sunset soon.
## If you do not use Clawdock, ignore..
export CLAWDOCK_DIR="${folder}"
