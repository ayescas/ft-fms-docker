# fmg-dockerfms
Run FileMaker Server for Linux in Docker Desktop for Mac or Windows. Everything you need to automatically build a ready-to-run Docker image.

**Windows**: there are currently some issues (see below). 

We are constantly improving the scripts and try to get rid of the remaining issues. If you want to stay up-to-date, make sure to watch the repo and maybe follow us on twitter: [@fmgarage](https://twitter.com/fmgarage)


## Installation on macOS



### Docker Desktop

Download and install the latest version of Docker Desktop.



### Repo

Clone or download the repo and move it to your documents folder. You may rename it to something like

```~/Documents/FMS-Linux
~/Documents/FMS-Linux
```



### FileMaker Server

Download a copy of the FileMaker Server installer for Linux from your Claris account page, unpack the zip file and move the Red Hat Package Manager (rpm) file to the build folder in the repo. You can also put a  link into the config.txt, the installer will be downloaded instead then. 

With the current version of the installer it will look like this:

```
~/Documents/FMS-Linux/build/filemaker_server-19.2.1-23.x86_64.rpm
```

You can adjust the settings in the *Assisted Install.txt* file, but you don't need to. The server admin console login will be admin/admin then, which can be changed later.



### SSL Certificate

If you have a certificate that you might want to use for this server, simply copy the files (key, cert and intermediate) into the *build* directory, the installer will automatically look for the appropriate file endings (.pem, .crt and .ca-bundle). If you don' t provide any, the server will use the default self-signed certificate instead.



### Build Image and run Container

Open Terminal.app, drag the **install.sh** into the terminal window and hit return.

After the install process is finished, check the Dashboard in Docker Desktop, there should be a running container named **fms** (fmc-c if installed with a certificate).

Open the admin console by clicking the *Open in Browser* button in the container actions. In case you installed without certificate you will have to confirm the self-signed one.

Clicking the CLI button will open a terminal window where you can use the fmsadmin command to control your server.







## Installation on Windows 10



In addition to the macOS instructions you will have to install the Windows Subsystem for Linux WSL first. To do so, follow these instructions: https://docs.microsoft.com/de-de/windows/wsl/install-win10 ("Manual Installation Steps").

The Linux distro used for running the installer and then the container needs systemd, which is not yet officially supported in WSL2. Still, it's possible  (as of now, for Ubuntu) with the following script:
(https://github.com/damionGans/ubuntu-wsl2-systemd-script)

Download and install a Linux distribution of your preference and run it. (Ubuntu 20.04 recommended)

Run the installer – assuming, you copied the folder to Documents and renamed it to "fms":

```
/mnt/c/Users/your_windows_username/Documents/fms/build/install.sh
```

Yet, it's recommended to mount volumes from the WSL filesystem. It's easy to copy the installer into the Linux filesystem like so
```
sudo cp -r /mnt/c/Users/your_windows_username/Documents/fms ~
```

The Linux filesystem can be mounted as network volume into the Windows Explorer by using a path like:
```
\\wsl$\your_linux_distro\
```

#### Issues: 

As of now it is not possible to run both FileMaker Server (in Docker) and FileMaker Pro at the same time on a Windows machine. FileMaker Pro also binds port 5003 on launch and it is not possible to make a connection to the local server. 

Folders (for databases, backups…) are created on container start but not reconnected if you quit/reboot and start Docker Desktop again. Existing files will not be overwritten, but new volumes must be created and attached to the local folders.

Some logfiles are not created because of missing permissions.





## Administration



### Stopping and Restarting the Server

At the moment, quitting Docker Desktop will not gracefully close your databases or stop the server. To prevent your databases from being corrupted by the hard shutdown, always stop the container or use the *fmsadmin stop server* command beforehand.



### Accessing files

Relevant directories are being mounted into the container as volumes. These volumes are bound to their corresponding folders on the host in the `fms-data` folder. In case the container is removed, it is possible to run a new container with the persisted state from the compose file. It is recommended not to edit these files, while the server is running.

The directories include databases, logs, configs and extensions.
