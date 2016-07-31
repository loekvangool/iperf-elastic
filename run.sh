#!/bin/bash
 
if ! [ -x "$(type -P iperf3)" ]; then
  echo "ERROR: script requires iperf"
  echo "If you have it, perhaps you don't have permissions to run it, try 'sudo $(basename $0)' and make sure it's in \$PATH"
  exit 1
fi
 
if [ "$#" -ne "4" ]; then
  echo "ERROR: script needs four arguments, where:"
  echo
  echo "1. Number of times to repeat test (e.g. 10 or 0 for infinite)"
  echo "2. Host running 'iperf3 -s' (e.g. somehost)"
  echo "3. Port of host (normally 5201)"
  echo "4. Time to wait between tests (in seconds)"
  echo
  echo "Example:"
  echo "  $(basename $0) 10 <host> <port> 60"
  echo 
  echo "The above will run iperf3 10 times with 60 seconds of sleep."
  exit 1
else
  runs=$1
  host=$2
  port=$3
  zzzz=$4
fi
 
log=iperf.$host.log
output=iperf.${host}.out
tmpout=iperf.${host}.tmp

if [ -f $log ]; then
  echo removing $log
  rm $log
fi

if [ -f $tmpout ]; then
  echo removing $tmpout
  rm $tmpout
fi

echo "Running iperf3 pointed at ${host}:${port}, ${runs} times with ${zzzz} seconds sleep between cycles, ${zzzz} seconds of sleep between upload/download tests"
run=1
while [ $run -le $runs -o $runs -eq 0 ]
do
  printf "${run}/${runs}"
  iperf3 --client ${host} --port ${port} --json --logfile ${tmpout} -O 3 -i 0
  cat ${tmpout} | json-minify >> ${output} && rm ${tmpout}
  sleep ${zzzz}
  iperf3 --client ${host} --port ${port} --json --logfile ${tmpout} -O 3 -i 0 -R
  cat ${tmpout} | json-minify >> ${output} && rm ${tmpout}
  run=$[$run+1]
  sleep ${zzzz}
  printf "..."
done
echo "Done"
