#!/bin/sh

mount="/"
warning=20
critical=10

df -h -P -l "$mount" | awk -v warning=$warning -v critical=$critical '
/\/.*/ {
  text=$4
  tooltip="Filesystem: "$1"\rSize: "$2"\rUsed: "$3"\rAvail: "$4"\rUse%: "$5"\rMounted on: "$6
  use=$5
  exit 0
}
END {
  class=""
  gsub(/%$/,"",use)
  if ((100 - use) < critical) {
    class="critical"
  } else if ((100 - use) < warning) {
    class="warning"
  }
  print "{\"text\":\""text"\", \"percentage\":"use",\"tooltip\":\""tooltip"\", \"class\":\""class"\"}"
}
'


IFS='|' read -r storage_text storage_tooltip storage_use storage_class <<< "$storage_info"
# Get the max CPU frequency
max_frequency=$(lscpu | grep "CPU max MHz" | awk '{print $4/1000}')
# Get the used and total memory
used_memory=$(free -h --giga | awk '/^Mem:/ {print $3}')
total_memory=$(free -h --giga | awk '/^Mem:/ {print $2}')
# Combine all information
output="{\"text\": \" ${max_frequency}GHz  ${used_memory}GB  ${storage_text}\", \"tooltip\": \"CPU: ${max_frequency}GHz\nMemory: ${used_memory} / ${total_memory} GB\nStorage: ${storage_tooltip}\", \"class\": \"${storage_class}\"}"
# Print the output in JSON format for Waybar
echo "$output"
# Wait for 1 second before updating
sleep 1

