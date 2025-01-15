
# udocker-functions
Provides features which docker provides but are missing from udocker.

## Description
[udocker](https://github.com/indigo-dc/udocker) is software for running docker containers without using docker. It uses lightweight container binaries such as proot instead.

udocker does not provide all docker functions. It lacks the following: 
- Container running and tracking in the background
- A command like `docker ps` command which shows the currently running containers
- Container run parameter tracking. udocker requires parameters to be supplied everytime a container is run. This can be tedious to use.

This project (udocker-functions) provides the above features using the linux screen program, bash functions and a python script. The following functions are made available which can be used as commands in bash:
- udocker_ps - list running containers
- udocker_run - run containers with supplies params and remember them, old params can also be changed using --reinit param.
- udocker_start - start a container, similar to the run command
- udocker_stop - stop a running container
- udocker_prune - delete all containers except protected ones
- udocker_exec - execute a new process using a running container 
- udocker_enter - enter into the console of a running container 

## Dependencies
udocker, bash, screen and python3

## Installation 

```
# first clone this repo then
cd udocker-functions

mkdir -p ~/.udocker/scripts
cp udocker-bashrc.sh ~/.udocker/scripts
cp udocker-run.py ~/.udocker/scripts

#install screen
sudo apt install screen

#install udocker
pip install udocker

#Add the following to .bashrc
source ~/.udocker/scripts/udocker-bash.sh

#then do
source ~/.bashrc
```

## Example usage
- udocker_run, udocker_ps
```
localhost:$ udocker pull nginx:1-alpine3.18-slim

localhost:$ udocker create --name=nginx nginx:1-alpine3.18-slim

localhost:$ udocker_run nginx --reinit --publish=2080:80

localhost:$ udocker_ps
CONTAINER ID  CONTAINER  IMAGE                    COMMAND
4fbbce015381  nginx      nginx:1-alpine3.18-slim 
```

- udocker_ps full output
```
udocker_ps -f
CONTAINER ID  CONTAINER  IMAGE                    COMMAND
96ddcd9be0e7  alpine     alpine:latest            
4fbbce015381  nginx      nginx:1-alpine3.18-slim  --publish=2080:80

```

- udocker_start, udocker_stop

```

localhost:$ udocker_stop nginx
localhost:$ udocker_ps
CONTAINER ID  CONTAINER  IMAGE  COMMAND

localhost:$ udocker_start nginx 
localhost:$ udocker_ps
CONTAINER ID  CONTAINER  IMAGE                    COMMAND
4fbbce015381  nginx      nginx:1-alpine3.18-slim  --publish=2080:80 
```
- udocker_enter
```
localhost:$ udocker_enter nginx 
# then precess ctrl+A+d to detach from the screen again

```
- udocker_exec
```
localhost:$ udocker_exec nginx sh
Error: this container exposes privileged TCP/IP ports
 
 ****************************************************************************** 
 *                                                                            * 
 *               STARTING 11219c25-2475-3020-80e4-4fbbce015381                * 
 *                                                                            * 
 ****************************************************************************** 
 executing: docker-entrypoint.sh
11219c25#

#type exit to exit when done
```
- multiple container running
```
localhost:$ udocker pull alpine
localhost:$ udocker create --name=alpine alpine

localhost$ udocker_run alpine
localhost$ udocker_ps
CONTAINER ID  CONTAINER  IMAGE                    COMMAND
4fbbce015381  nginx      nginx:1-alpine3.18-slim  --publish=2080:80 
96ddcd9be0e7  alpine     alpine:latest  

```
## Config options
You can manually manage ~/.udocker/runconfig.yaml. It is used to manage launching containers with complex parameters without having to specifiy the parameters everytime a container is launched.
params1 - are proot options
params2 - are params that come after the main command that is launched in the container
Just a note to use proot options with = i.e. -v=/tmp:/tmp. Dont use -v /tmp:/tmp

## Special notes
Some containers with interactive shell, like alpine, may not terminate when issuing udocker_stop. In this case you have to enter the container manually using udocker_enter and exit or kill the container with "exit" command or Ctrl+c.

## Disclamer
Since this project relies on bash scripts, we cannot guarantee the functions will always work. If the output formatting of the udocker program changes then it may break.

We have tested the functions with udocker version: 1.3.10 on ubuntu 22.04 and termux.

