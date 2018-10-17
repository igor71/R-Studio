# R-Studio
This repository contains Dockerfiles for Docker containers of interest to R users

## Getting started ##

Here we outline how to use the rstudio image,  which enables you to use [RStudio](http://www.rstudio.com/products/RStudio/) in your browser via `docker`. These instructions also apply to using RStudio via the hadleyverse and ropensci images, just replace `rocker/rstudio` with `rocker/hadleyverse` or `rocker/ropensci ` in the examples below.

Install the most current version of `docker` software [as indicated for your platform](https://docs.docker.com/installation).  Mac or Windows users will need to download and install [The Docker Toolbox](https://www.docker.com/docker-toolbox), which creates a small virtual machine called. These users will have to launch a terminal first (eg. from a desktop shortcut) and then enter `docker` commands in shown in the resulting window.  Linux users (on either local or remote/cloud platforms) can simply enter these commands into a terminal once `docker` is installed.  

_Note: RStudio requires docker version `>= 1.2`_  Some Linux repositories may have only older versions available, to ensure you get the latest version run `curl -sSL https://get.docker.com/ubuntu/ | sudo sh`. Fresh installs of the Docker Toolkit on Mac/Windows following the instructions above should be fine.  

Before we begin, Mac/Windows users should first take note of the ip address assigned by `docker-machine`, the VM manager in the Docker Toolkit.  To find this address, open a regular terminal window and run the command:

```bash
docker-machine ls
```

which will show the VMs currently running on your machine, perhaps looking something like:

```bash
NAME      ACTIVE   DRIVER       STATE     URL                         SWARM   ERRORS
default   -        virtualbox   Running   tcp://192.168.99.100:2376 
```

then do

```bash
docker-machine ip default
```

which should return an ip address. Keep this window open or make a note of the ip address because we'll need it later. Linux users can just use `http://localhost` or the IP address of their remote server.  

## Running RStudio Server ##

1) From the docker window, run:

```bash
sudo docker run -d -p 8787:8787 -e PASSWORD=<password> --name rstudio rocker/rstudio # replace <password> with a password of your choice
```

That will take a while to download the image the first time you run it.  Linux users might want to add their user to the `docker` group to avoid having to use `sudo`.  To do so, just run `sudo usermod -a -G docker <username>`. You may need to login again to refresh your group membership. (Mac and Windows users do not need to use `sudo`.)

2) Once the download is finished RStudio-Server will launch invisibly.  To connect to it, open a browser and enter in the ip address noted above followed by `:8787`, e.g. http://192.168.59.103:8787, and you should be greeted by the RStudio welcome screen.  Log in using:

- username: rstudio 
- password: `<password>`

and you should be able to work with RStudio in your browser in much the same way as you would on your desktop.

## Folder sharing

To share files and folders between your `docker` image and your host OS you can use the `-v` option. This acts much like running `RStudio` in the working directory. More detailed instructions on running docker with folder sharing can be found [on this wiki page](https://github.com/rocker-org/rocker/wiki/Sharing-files-with-host-machine).

## Custom use

- To customize the username and password: (important for publicly hosted/cloud instances)

```bash
docker run -d -p 8787:8787 -e USER=<username> -e PASSWORD=<password> rocker/rstudio
```

- Launch an R terminal session instead of using RStudio.  While not strictly necessary, we recommend always running interactive sessions with `--user rstudio` to avoid working as root.  This is primarily a concern if you are linking local volumes (see below).

```bash
docker run --rm -it --user rstudio rocker/rstudio /usr/bin/R
```

- You can also launch a plain bash session

```bash
docker run --rm -it --user rstudio rocker/rstudio /bin/bash
```

## Enable root 

By default, the RStudio user does not have access to root, such that users cannot install binary libraries with `apt-get` without first entering the container (see `docker exec` as described below). To enable root from within RStudio, launch the container with the flag `-e ROOT=TRUE`, e.g.

    docker run -d -p 8787:8787 -e ROOT=TRUE rocker/rstudio

You can now open a shell from RStudio (see the "Tools" menu), or directly from the R console using `system()`, e.g.

    system("sudo apt-get install -y libgsl0-dev")

(Note that the `system()` commands are non-interactive, hence the `-y` flag to accept the install.)

## Multiple users

Once your RStudio-server instance is up and running on a publicly accessible web server, you may want to allow other users (such as collaborators or students) to access the same instance as well.  The default configuration declares only a single user. Assuming that your container is already up and running with Docker version `>= 1.3`, you can use the following command to log into the running container:

```
docker exec -it <container-id> bash
```

where `<container-id>` is the container name or id assigned to your running RStudio instance (see `docker ps`).  We can now do the usual linux root administration steps to add new users and passwords, e.g. run:

```
adduser <username>
```

to interactively create each new user and password (adding user contact details in the prompt is optional).  You can then exit the prompt (type `exit`); your RStudio container is still running and now has the new users added.  

**Note**: you should not link any shared volumes to the host on a container in which you are configuring multiple users.

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
rstudio (or any other specific user(s)) can be added to the sudoers file (using `visudo`) and given rights to run `apt-get`. This will make it possible to install system packages via the terminal in RStudio. These users can have root access depending on how permissive the sudoers settings are, so this approach should be used with caution.

## Troubleshooting

### Known Issues

The rstudio-based images will not on Centos-based systems that have installed docker from the default Centos repository.  To work around this, add the option `-v /run` to your `docker run` command, or install Docker using the official version from <http://get.docker.com>.  See [Issue #202](https://github.com/rocker-org/rocker/issues/202) for more information. 

### Suggestions

Using docker via `boot2docker` can be a slightly less smooth experience than using docker on Linux. General strategies for making it work include:
* Deleting the `.boot2docker`, `.VirtualBox` and `VirtualBox VMs` folders (take care to preserve your other VM images unrelated to `boot2docker`, if any). They will be replaced with new copies when you next run `boot2docker`. 
* Downgrading your version of [Oracle VirtualBox](https://www.virtualbox.org/wiki/Download_Old_Builds_4_3) to an earlier version. We've had success with VirtualBox 4.3.12 with `boot2docker` 1.3.0 on Windows 7. 
* If `boot2docker` is running ok but you get a connection error when trying to access RStudio in your browser, try quitting `boot2docker`, opening a regular terminal window and running `boot2docker ssh -L 8787:localhost:8787` to force a port open, then run `sudo docker run -d -p 8787:8787 rocker/rstudio` and then point your browser to `http://localhost:8787`
* If none of that helps, [ask a question](https://github.com/rocker-org/rocker/issues) to the maintainers of this repository or on [StackOverflow](http://stackoverflow.com/questions/tagged/boot2docker)
* To access the instance on <host_machine_ip>:8787 rather than <virtual_machine_ip>:8787 (forwarding host traffic to guest), do the following: (refer to https://github.com/docker/for-win/issues/204 for more info)
  * Go to VirtualBox -> Your BOX -> Settings -> Network ->
  * Choose NAT
  * Open Advanced
  * Click Port Forwarding
  * Add new rule to map whatever port you need from host to guest
  * Click OK, OK
  * Restart the docker instance if necessary (in case the running instance is not picking up the new config)
