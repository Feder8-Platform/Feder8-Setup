# Separate scripts

Table of Contents
=================
  * [Requirements](#requirements)
    * [Hardware](#hardware)
    * [Operating system](#operating-system)
    * [Docker](#docker)
    * [Docker images](#docker-images)
  * [Zeppelin installation instructions](#zeppelin-installation-instructions)
  * [Distributed Analytics installation instructions](#distributed-analytics-installation-instructions)
  * [Feder8 Studio installation instructions](#feder8-studio-installation-instructions)
  * [Post ETL installation steps](#post-etl-installation-steps)
    * [Add constraints and indexes](#add-constraints-and-indexes)
    * [Update custom concepts](#update-custom-concepts)
  * [Backup and restore](#backup-and-restore)
  * [Vocabulary update](#vocabulary-update)
  * [Custom concepts update](#custom-concepts-update)

## Requirements

### Hardware
Modern 64 bit (x86) dual core processor (or better)
8 GB RAM, 16 GB RAM recommended
100 GB free disk space (or more)

### Operating system
Linux (Ubuntu, CentOS, Debian, …), Windows 10 or MacOS
Linux is recommended

### Docker
Linux: https://docs.docker.com/install/linux/docker-ce/ubuntu/
Windows: https://docs.docker.com/docker-for-windows/install/
MacOS: https://docs.docker.com/docker-for-mac/install/
Assign 2 or more CPU’s, 8 GB of RAM and 100 GB of disk space to Docker in Docker Desktop.
On Linux Docker compose (v1.24 or higher) should be installed separately.

### Docker images
The docker images are located on a central repository. Make sure you have a central platform account before trying to run the local setup installation scripts:

* For HONEUR: https://portal.honeur.org
* For PHederation: https://portal.phederation.org
* For ESFURN: https://portal.esfurn.org

Please request access by sending a mail to Michel Van Speybroeck (mvspeybr@its.jnj.com)

## Zeppelin installation instructions
Zeppelin can be installed by running the installation script.

1. Download the installation script (**_start-zeppelin.sh_** for Linux/MacOS or **_start-zeppelin.cmd_** for Windows) using the following command:

Linux/MacOS
```
curl -fsSL https://raw.githubusercontent.com/Feder8-Platform/Feder8-Setup/main/local-installation/separate-scripts/start-zeppelin.sh --output start-zeppelin.sh && chmod +x start-zeppelin.sh
```

Windows
```
curl -fsSL https://raw.githubusercontent.com/Feder8-Platform/Feder8-Setup/main/local-installation/separate-scripts/start-zeppelin.cmd --output start-zeppelin.cmd
```

2. You can run this script using the following command:

Linux/MacOS
```
./start-zeppelin.sh
```

Windows
```
.\start-zeppelin.cmd
```

3. The script will prompt to select the applicable therapeutic area.
4. The script will prompt to enter the email address of the account you use to login on the central platform.
5. The script will prompt to enter your CLI secret for pulling our images. This secret can be found on our central image repository. Surf to:
    * https://harbor.honeur.org for HONEUR
    * https://harbor.phederation.org for PHederation
    * https://harbor.esfurn.org for ESFURN
    * https://harbor.athenafederation.org for ATHENA
    * https://harbor.lupusnet.org for Lupus
6. Login using the button "LOGIN VIA OIDC PROVIDER". Then click your account name on the top right corner of the screen and click "User Profile". Copy the CLI secret by clicking the copy symbol next to the text field.
7. The script will prompt to enter a directory on the host machine to save the zeppelin logs and notebooks. Please provide an absolute path.
8. The script will prompt you to enter the security options for Zeppelin. If you have existing HONEUR Components like Postgres/Atlas/WebAPI or Feder8 Studio. Please use the same security settings as with these previous installation.
9. (OPTIONAL when **_ldap_** is chosen for the installation security) Additional connections details will be asked to connect to the existing LDAP Server.

Once done, the script will download the Zeppelin docker image and will create the docker container.

:warning: Please run the installation script of the [Proxy server](#proxy-server) after installing or updating Zeppelin. The proxy is necessary for accessing Zeppelin through the browser.


## Distributed Analytics installation instructions
:warning: Distributed Analytics requires you to install the [Zeppelin](#zeppelin-installation-instructions) component.

Distributed Analytics can be installed by downloading and running the installation script.

1. Download the installation script (**_start-distributed-analytics.sh_** for Linux/MacOS or **_start-distributed-analytics.cmd_** for Windows) using the following command:

Linux/MacOS
```
curl -fsSL https://raw.githubusercontent.com/Feder8-Platform/Feder8-Setup/main/local-installation/separate-scripts/start-distributed-analytics.sh --output start-distributed-analytics.sh && chmod +x start-distributed-analytics.sh
```

Windows
```
curl -fsSL https://raw.githubusercontent.com/Feder8-Platform/Feder8-Setup/main/local-installation/separate-scripts/distributed-analytics.cmd --output start-distributed-analytics.cmd
```

2. Run this script using the following command:

Linux/MacOS
```
./start-distributed-analytics.sh
```

Windows
```
.\start-distributed-analytics.cmd
```

3. The script will prompt to select the applicable therapeutic area.
4. The script will prompt to enter the email address of the account you use to login on the central platform.
5. The script will prompt you to enter your CLI secret for pulling our images. This secret can be found on our central image repository. Surf to:
    * https://harbor.honeur.org for HONEUR
    * https://harbor.phederation.org for PHederation
    * https://harbor.esfurn.org for ESFURN
    * https://harbor.athenafederation.org for ATHENA
    * https://harbor.lupusnet.org for Lupus
6. Login using the button "LOGIN VIA OIDC PROVIDER". Then click your account name on the top right corner of the screen and click "User Profile". Copy the CLI secret by clicking the copy symbol next to the text field.
7. The script will prompt to select the name of your organization.

Once done, the script will download the Distributed Analytics docker images and will create the docker containers.

## Feder8 Studio installation instructions
Feder8 Studio can be installed by downloading and running the installation script.

1. Download the installation script (**_start-feder8-studio.sh_** for Linux/MacOS or **_start-feder8-studio.cmd_** for Windows) using the following command:

Linux/MacOS
```
curl -fsSL https://raw.githubusercontent.com/Feder8-Platform/Feder8-Setup/main/local-installation/separate-scripts/start-feder8-studio.sh --output start-feder8-studio.sh && chmod +x start-feder8-studio.sh
```

Windows
```
curl -fsSL https://raw.githubusercontent.com/Feder8-Platform/Feder8-Setup/main/local-installation/separate-scripts/start-feder8-studio.cmd --output start-feder8-studio.cmd
```

2. Run the script using the following command:

Linux/MacOS
```
./start-feder8-studio.sh
```

Windows
```
.\start-feder8-studio.cmd
```

3. The script will prompt to select the applicable therapeutic area.
4. The script will prompt to enter the email address of the account you use to login on the central platform.
5. The script will prompt to enter your CLI secret for pulling our images. This secret can be found on our central image repository. Surf to:
    * https://harbor.honeur.org for HONEUR
    * https://harbor.phederation.org for PHederation
    * https://harbor.esfurn.org for ESFURN
    * https://harbor.athenafederation.org for ATHENA
    * https://harbor.lupusnet.org for Lupus
6. Login using the button "LOGIN VIA OIDC PROVIDER". Then click your account name on the top right corner of the screen and click "User Profile". Copy the CLI secret by clicking the copy symbol next to the text field.
7. The script will prompt to enter a Fully Qualified Domain Name (FQDN) or IP Address of the host machine. Feder8 Studio will only be accessible on the host machine (via localhost) if you enter ‘localhost’ as host name.
8. The script will prompt to enter the directory of where the Feder8 Studio will store its working directory files.
9. The script will prompt to enter the security options for FEDER8 Studio. If you have existing HONEUR Components like postgres/webapi and zeppelin. Please use the same security settings as with this previous installation.
10. (OPTIONAL when **_ldap_** is chosen for the installation security) Additional connections details will be asked to connect to the existing LDAP Server

Once done, the script will download the Feder8 Studio docker image and will create the docker container.

:warning: Please run the installation script of the [Proxy server](#proxy-server) after installing or updating FEDER8 Studio. The proxy is necessary for accessing FEDER8 Studio through the browser.

## Post ETL installation steps
### Add constraints and indexes
After the ETL is successfully executed, it’s recommended to add the constraints and indexes to the OMOP CDM tables. It will improve the performance and reduce the risk of corrupt data in the database.
Installation steps:
1.	Open a terminal window (Command Prompt on Windows)
2.	Download the installation file

Linux/MacOS
```
curl -fsSL https://raw.githubusercontent.com/Feder8-Platform/Feder8-Setup/main/local-installation/separate-scripts/start-add-indexes-and-constraints.sh --output start-add-indexes-and-constraints.sh && chmod +x start-add-indexes-and-constraints.sh
```
Windows
```
curl -fsSL https://raw.githubusercontent.com/Feder8-Platform/Feder8-Setup/main/local-installation/separate-scripts/start-add-indexes-and-constraints.cmd --output start-add-indexes-and-constraints.cmd
```
3.	Run the script

Linux/MacOS
```
./start-add-indexes-and-constraints.sh
```
Windows
```
.\start-add-indexes-and-constraints.cmd
```

### Update custom concepts
When new custom concepts are available, they can be easily loaded in the OMOP CDM database.
Installation steps:
1.	Open a terminal window (Command Prompt on Windows)
2.	Download the installation script

Linux/MacOS
```
curl -fsSL https://raw.githubusercontent.com/Feder8-Platform/Feder8-Setup/main/local-installation/separate-scripts/start-custom-concepts-update.sh --output start-custom-concepts-update.sh && chmod +x start-custom-concepts-update.sh
```
Windows
```
curl -fsSL https://raw.githubusercontent.com/Feder8-Platform/Feder8-Setup/main/local-installation/separate-scripts/start-custom-concepts-update.cmd --output start-custom-concepts-update.cmd
```
3.	Run the script

Linux/MacOS
```
./start-custom-concepts-update.sh
```
Windows
```
.\start-custom-concepts-update.cmd
```

## Backup and restore

### Backup
1. Download the backup script:

Linux/MacOS
```
curl -fsSL https://raw.githubusercontent.com/Feder8-Platform/Feder8-Setup/main/local-installation/separate-scripts/backup-full.sh --output backup-full.sh && chmod +x backup-full.sh
```
Windows
```
curl -fsSL https://raw.githubusercontent.com/Feder8-Platform/Feder8-Setup/main/local-installation/separate-scripts/backup-full.cmd --output backup-full.cmd
```
2. Run the script

Linux/MacOS
```
./backup-full.sh
```
Windows
```
.\backup-full.cmd
```
The backup script will create a tar file name '<db_name>_<date_time>.tar.bz2' in the current directory. Creating the backup file can take a long time depending on the size of the database.
Copy the backup file to a save location for long term storage.

### Restore
1. Download the restore script:

Linux/MacOS
```
curl -fsSL https://raw.githubusercontent.com/Feder8-Platform/Feder8-Setup/main/local-installation/separate-scripts/restore.sh  --output restore.sh  && chmod +x restore.sh
```
Windows
```
curl -fsSL https://raw.githubusercontent.com/Feder8-Platform/Feder8-Setup/main/local-installation/separate-scripts/restore.cmd --output restore.cmd
```
2. Run the script

Linux/MacOS
```
./restore.sh
```
Windows
```
.\restore.cmd
```

## Vocabulary update
When a new vocabulary is available, it can be easily loaded in the OMOP CDM database.
Installation steps:
1.	Open a terminal window (Command Prompt on Windows)
2.	Download the installation script

Linux/MacOS
```
curl -fsSL https://raw.githubusercontent.com/Feder8-Platform/Feder8-Setup/main/local-installation/separate-scripts/start-vocabulary-update.sh --output start-vocabulary-update.sh && chmod +x start-vocabulary-update.sh
```
Windows
```
curl -fsSL https://raw.githubusercontent.com/Feder8-Platform/Feder8-Setup/main/local-installation/separate-scripts/start-vocabulary-update.cmd --output start-vocabulary-update.cmd
```
3.	Run the script

Linux/MacOS
```
./start-vocabulary-update.sh
```
Windows
```
.\start-vocabulary-update.cmd
```

## Custom concepts update
When new custom concepts become available, they can be loaded in the OMOP CDM database.
Installation steps:
1.	Open a terminal window (Command Prompt on Windows)
2.	Download the installation script

Linux/MacOS
```
curl -fsSL https://raw.githubusercontent.com/Feder8-Platform/Feder8-Setup/main/local-installation/separate-scripts/start-custom-concepts-update.sh --output start-custom-concepts-update.sh && chmod +x start-custom-concepts-update.sh
```
Windows
```
curl -fsSL https://raw.githubusercontent.com/Feder8-Platform/Feder8-Setup/main/local-installation/separate-scripts/start-custom-concepts-update.cmd --output start-custom-concepts-update.cmd
```
3.	Run the script

Linux/MacOS
```
./start-custom-concepts-update.sh
```
Windows
```
.\start-custom-concepts-update.cmd
```

## DQD Viewer
To locally visualise the DQD results, follow these steps:

1.	Open a terminal window (Command Prompt on Windows)
2.	Download the installation script

Linux/MacOS
```
curl -fsSL https://raw.githubusercontent.com/Feder8-Platform/Feder8-Setup/main/local-installation/separate-scripts/run-dqd-viewer.sh --output run-dqd-viewer.sh && chmod +x run-dqd-viewer.sh
```
Windows
```
curl -fsSL https://raw.githubusercontent.com/Feder8-Platform/Feder8-Setup/main/local-installation/separate-scripts/run-dqd-viewer.cmd --output run-dqd-viewer.cmd
```
3.	Run the script

Linux/MacOS
```
./run-dqd-viewer.sh
```
Windows
```
.\run-dqd-viewer.cmd
```