import os.path
import sys
import signal
import yaml
import subprocess

def parse_args():
    params={}
    params["container"]=sys.argv[1]
    params["reset"]="false"

    if params["container"].startswith("-"):
        print("Invalid container name")
        sys.exit(1)

    i=2
    params1=""
    for j in range(2,len(sys.argv)):
        if sys.argv[j]=="--reinit":
           params["reset"]="true" 
           i+=1
        elif sys.argv[j].startswith("-"):
           params1+=sys.argv[j]+" "
           i+=1
        else:
           break

    params2=""
    for j in range(i,len(sys.argv)):
        params2+=sys.argv[j]+" "

    params["params1"]=params1
    params["params2"]=params2 
    return params 

def get_container_data(config,container):
    containers=config.get("containers",None)
    if not containers or len(containers) < 1:
        containers={}
    if not containers.get(container,None):        
        containers[container]={}
        
    config["containers"]=containers

    return containers[container]    


if len(sys.argv)<2:
    print("usage: "+sys.argv[0]+" <containername> '<params>'")
    sys.exit(1)

command_params=parse_args()


def handler_stop_signals(signum, frame):
    global run

signal.signal(signal.SIGINT, handler_stop_signals)
signal.signal(signal.SIGTERM, handler_stop_signals)

configfile=os.getenv("HOME")+'/.udocker/runconfig.yaml'

config = {}

if os.path.exists(configfile):
    with open(configfile) as f:
        config = yaml.safe_load(f)       

container = get_container_data(config,command_params["container"])

if not container.get("params1",None) or command_params["reset"]=="true":
   container["params1"]=command_params["params1"]
   container["params2"]=command_params["params2"]
       
   with open(configfile,"w+") as f:
      yaml.safe_dump(config,f)   

p=subprocess.Popen(["udocker run "+container["params1"]+" "+command_params["container"]+" "+container["params2"]], shell=True) 

p.communicate()