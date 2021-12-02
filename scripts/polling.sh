#!/bin/bash

declare -i duration=1
declare hasUrl=""
declare endpoint

usage() {
    cat <<END
    polling.sh [-i] [-h] endpoint
    
    Report the health status of the endpoint
    -i: include Uri for the format
    -h: help
END
}

while getopts "ih" opt; do 
  case $opt in 
    i)
      hasUrl=true
      ;;
    h) 
      usage
      exit 0
      ;;
    \?)
     echo "Unknown option: -${OPTARG}" >&2
     exit 1
     ;;
  esac
done

shift $((OPTIND -1))

if [[ $1 ]]; then
  endpoint=$1
else
  echo "Please specify the endpoint."
  usage
  exit 1 
fi 


healthcheck() {
    declare url=$1
    result=$(curl --http2 -i $url 2>/dev/null | grep "HTTP/[12][12\.]*")
    echo $result
}
start_time=$SECONDS
durationLoop=$((duration * 10))
curr_time=$start_time  # Want this to be the same value
echo "Start time: $start_time"
echo "Start time: $(($curr_time + $durationLoop))"
while [[ $(($curr_time)) < $(($start_time + $durationLoop)) ]]; do
   result=`healthcheck $endpoint` 
   declare status
   if [[ -z $result ]]; then 
      status="N/A"
   else
      status=${result:7:3}
   fi 
   curr_time=$SECONDS
   timestamp=$(date "+%Y%m%d-%H%M%S")
   if [[ -z $hasUrl ]]; then
     echo "$status "
     echo ::set-output name=status::"$status"
   else
     echo "$timestamp | $status | $endpoint " 
   fi 
   curr_time=$SECONDS
   sleep $duration
done