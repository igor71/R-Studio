# R-Studio
This repository contains Dockerfiles for Docker containers of interest to R users

## Getting started ##

Here we outline how to use the rstudio image,  which enables you to use [RStudio](http://www.rstudio.com/products/RStudio/) in your browser via `docker`. 

Install the most current version of `docker` software [as indicated for your platform](https://docs.docker.com/installation). 

_**Note:** RStudio requires docker version `>= 1.2`_  Some Linux repositories may have only older versions available, to ensure you get the latest version run `curl -sSL https://get.docker.com/ubuntu/ | sudo sh`. Fresh installs of the Docker Toolkit on Mac/Windows following the instructions above should be fine.  

Linux users can just use `http://localhost` or the IP address of their remote server. 

## Building Docker Images Manually:
```
git clone --branch=master --depth=1 https://github.com/igor71/R-Studio/

cd R-Studio

./tflow-build-all.sh
```

## Running RStudio Server Inside Docker Container ##

1) From the docker window, run:
```
docker run -d -p 8787:8787 -e PASSWORD=<password> --name rstudio yi/r-studio:0.0 # replace <password> with a password of your choice
```
_**Note:** Password cannot be same as username, `rstudio` docker will fail on run command in this case_

Linux users might want to add their user to the `docker` group to avoid having to use `sudo`.  To do so, just run `sudo usermod -a -G docker <username>`. You may need to login again to refresh your group membership.

2) Running docker image will launch RStudio-Server invisibly.  To connect to it, open a browser and enter in the ip address noted above followed by `:8787`, e.g. http://192.168.2.103:8787, and you should be greeted by the RStudio welcome screen.  Log in using:

- username: rstudio 
- password: `<password>`

and you should be able to work with RStudio in your browser in much the same way as you would on your desktop.

## Folder sharing

To share files and folders between your `docker` image and your host OS you can use the `-v` option. This option will mount host shared folder into running docker container. For example if you need mount host `media` into the docker `media`, run the docker as following:
```bash
docker run -d -p 8787:8787 -e PASSWORD=<password> --name rstudio -v /media:/media yi/r-studio:0.0 # replace <password> with a password of your choice
```
This acts much like running `RStudio` in the working directory. More detailed instructions on running docker with folder sharing can be found [on this wiki page](https://github.com/rocker-org/rocker/wiki/Sharing-files-with-host-machine).

## Custom use

- To customize the username and password: (important for publicly hosted/cloud instances)

```bash
docker run -d -p 8787:8787 -e USER=<username> -e PASSWORD=<password> yi/r-studio:0.0
```

- Launch an R terminal session instead of using RStudio.  While not strictly necessary, we recommend always running interactive sessions with `--user rstudio` to avoid working as root.  This is primarily a concern if you are linking local volumes (see below).

```bash
docker run --rm -it --user rstudio yi/r-studio:0.0 /usr/bin/R
```

- You can also launch a plain bash session

```bash
docker run --rm -it --user rstudio yi/r-studio:0.0 /bin/bash
```

## Enable root 

By default, the RStudio user does not have access to root, such that users cannot install binary libraries with `apt-get` without first entering the container (see `docker exec` as described below). To enable root from within RStudio, launch the container with the flag `-e ROOT=TRUE`, e.g.

    docker run -d -p 8787:8787 -e ROOT=TRUE rocker/rstudio

You can now open a shell from RStudio (see the "Tools" menu), or directly from the R console using `system()`, e.g.

    system("sudo apt-get install -y libgsl0-dev")

_**Note:** The `system()` commands are non-interactive, hence the `-y` flag to accept the install._

In the other hand you can become `root` if you are running docker as `rstudio` user by running `sudo su` command in the terminal session.

## Multiple users

Once your RStudio-server instance is up and running on a publicly accessible web server, you may want to allow other users (such as collaborators or students) to access the same instance as well.  The default configuration declares only a single user. Assuming that your container is already up and running with Docker version `>= 1.3`, you can use the following command to log into the running container:

```
docker exec -it <container-id> bash
```

where `<container-id>` is the container name or id assigned to your running RStudio instance (see `docker ps`).  We can now do the usual linux root administration steps to add new users and passwords, e.g. run:

```
sudo useradd -m -s /bin/bash <username>

sudo passwd <username>

Adding user to staff group:

sudo usermod -aG staff <username> 
```

to interactively create each new user and password (adding user contact details in the prompt is optional).  You can then exit the prompt (type `exit`); your RStudio container is still running and now has the new users added.  

**Note:** you should not link any shared volumes to the host on a container in which you are configuring multiple users.

## Dependencies external to the R system

Many R packages have dependencies external to R, for example `GSL`, `GDAL`, `JAGS` and so on. To install these on a running rocker container you need to go to the docker command line and type the following:

```
docker ps # find the ID of the running container you want to add a package to
docker exec -it <container-id> bash # a docker command to start a bash shell in your container
apt-get install libgsl0-dev # install the package, in this case GSL
```
The `apt-get install` line is a Debian command, and if you want to install library `foo`, the thing to install usually takes the form `libfoo-dev`.

**Note:** If you get an error such as "E: The value 'testing' is invalid for APT::Default-Release as such a release is not available in the sources", you should run `apt-get update`. In general with docker images you are expected to run `apt-get update` before installing.

### Adding super users
rstudio (or any other specific user(s)) can be added to the sudoers file (using `visudo`) already given rights to run `apt-get` command. This will make it possible to install system packages via the terminal in RStudio. These users can have root access depending on how permissive the sudoers settings are, so this approach should be used with caution.

### Maintances & Installation of R Packages

Once you are logged into web interface, you can add R packages by issuing following comman:

`install.packages("<package-name"), e.g install.packages("tidyverse")`

### Original WIKI and repos are here:

[WIKI](https://github.com/rocker-org/rocker/wiki/Using-the-RStudio-image)

[Rocker-Versioned](https://github.com/rocker-org/rocker-versioned)

[Rocker](https://github.com/rocker-org/rocker)
