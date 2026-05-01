## for use if you have already got a running container and want to install Homebrew
## enter your container ID by copying it from Docker and pasting it below
## This will install Homebrew into your currently running Container and test to make sure it is working correctly.
## then you may install skills as normal
YourContainerID="" ## enter your container ID here
docker exec -it -u root ${YourContainerID} bash -c 'mkdir -p /home/linuxbrew/.linuxbrew && curl -L https://github.com/Homebrew/brew/tarball/main | tar xz --strip-components 1 -C /home/linuxbrew/.linuxbrew && useradd -m -s /bin/bash brewuser && echo '"'"'brewuser:brewpass'"'"' | chpasswd && chown -R brewuser:brewuser /home/linuxbrew && printf '"'"'#!/bin/bash\necho brewpass | su - brewuser -c "/home/linuxbrew/.linuxbrew/bin/brew $*"\n'"'"' > /usr/bin/brew && chmod +x /usr/bin/brew && echo '"'"'export PATH="/usr/bin:$PATH"'"'"' >> ~/.bashrc && echo '"'"'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'"'"' >> ~/.bashrc && source ~/.bashrc'
docker exec -it -u node ${YourContainerID} bash -c 'brew --version'
