TMPDIR="$HOME/.udocker/logs"

mkdir -p $TMPDIR

UDOCKER_PYTHON_SCRIPT="python3 $HOME/.udocker/scripts/udocker-run.py"

udocker_prune(){
     udocker rm `udocker ps|cut -d\  -f1`
}

udocker_run(){

   name=$1
   
   container=$(ps a -o pid,command | grep "udocker run"| grep python |awk '{for (i=5; i<NF; i++) printf $i " "; printf $NF;print ""}' | grep $name)
   
   if [[ -n "$container" ]];then
   	echo "Container $container already running"
   	return 1
   fi

   screen -dmS $name -L -Logfile $TMPDIR/$name.log -m $UDOCKER_PYTHON_SCRIPT $@

}

udocker_start(){
  name=$1
  udocker_run $name    
}

udocker_exec(){

   name=$1
   
   echo "Do Ctrl-a + d detach"

   udocker run $@
}

udocker_enter(){

   name=$1

   screen -r $name
}

udocker_ps(){


   #ps aux | grep "udocker run" | head -n -1 |awk '{printf $2 " "} {for (i=13; i<NF; i++) printf $i " "; print $NF}'

lines=$(ps a -o pid,command | grep "udocker run"| grep python |awk '{for (i=5; i<NF; i++) printf $i " "; printf $NF;print ""}')

echo "CONTAINER ID|CONTAINER|IMAGE|COMMAND" > $TMPDIR/table.txt

OLDIFS="$IFS"
IFS=$'\n' # bash specific
for line in $lines;
do

  IFS="$OLDIFS"
  for v in $line;
  do
     if [[ $v != $'-'* ]]; then        
  	container=$v  	
  	break  	        
     fi
  done
  IFS=$'\n'
  
  cid=$(udocker ps | grep "\\['$container"|cut -d '-' -f 5| cut -d ' ' -f 1)
  echo -n "$cid|" >> $TMPDIR/table.txt

  echo -n "$container|" >> $TMPDIR/table.txt

  img=$(udocker ps | grep "\\['$container"|cut -d ']' -f 2 | sed 's/ //g')
  echo -n "$img|" >> $TMPDIR/table.txt

  IFS="$OLDIFS"
  for v in $line;
  do
     if [[ $v != $container ]]; then
  	echo -n "$v " >>$TMPDIR/table.txt
     fi
  done
  IFS=$'\n'
  echo "" >> $TMPDIR/table.txt
  
done
IFS="$OLDIFS"

cat $TMPDIR/table.txt  | column -t -s "|"

}

udocker_stop(){

   name=$1
   screen -S $name -X stuff $'\003'
}
