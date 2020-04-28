#!/usr/bin/env bash

# Save this file in a location where any user on your linux machine can read
# We saved it in /usr/local/bin/somefolder/cron-logging-script.sh
# Add or edit all files in cron.d whose outputs you want to collect by adding or changing the shell
# All top of the cron.d files should have SHELL=/usr/local/bin/somefolder/cron-logging-script.sh

# Get what command is going to be executed 
COMMAND="$(echo "$@" | sed 's/"/\\"/g')"

# Get home directory of user
USER_HOME_DIRECTORY="$(getent passwd $USER | cut -d: -f6)"

# Fail if user, user home directory or command is null
if [ -z "$USER" ] || [ -z "$USER_HOME_DIRECTORY" ] || [ -z "$COMMAND" ];then
	exit 1
fi

# Set log location for cron output
if [[ "$USER" == "root" ]]; then
	LOGS_DIRECTORY="/var/log/projects-cronlog.log"
else
	LOGS_DIRECTORY="$USER_HOME_DIRECTORY""/logs/projects-cronlog.log"
fi

write_status () {
	STATUS=$1
	EXIT_CODE=$2
	OUTPUT_RAW=$3

	# Below two if conditions are used while writing "START"
	if [[ -z "$EXIT_CODE" ]]; then
		EXIT_CODE="N/A"
	fi

	if [[ -z "$OUTPUT_RAW" ]]; then
		OUTPUT_RAW="No Output"
	fi

	OUTPUT_STATUS="$(echo "{\"timestamp\":\"$(date)\",\"command\":\"$COMMAND\",\"status\":\"$STATUS\",\"exit code\":\"$EXIT_CODE\"\"output\":\"$OUTPUT_RAW\"}")"
	echo "$OUTPUT_STATUS" >> "$LOGS_DIRECTORY"
}

# Starting writing log file
write_status START

# Execute the cron command and save the output in a variable
COMMAND_OUTPUT="$(/bin/bash "$@" 2>&1)"

# Capture Exit Code after command execution and define status
EXIT_CODE="$?"

# If exit code is anything other than 0, then log status as error
if [ "$EXIT_CODE" -eq "0" ]; then
	STATUS="FINISHED"
else
	STATUS="ERROR"
fi

# Remove ansi color codes and control characters from output except new line.
# Escape backslashes and double quotes
# Save "OUTPUT_RAW" to "OUTPUT_JSON" in JSON format by sending it to write_status
OUTPUT_CLEAN="$(echo "$COMMAND_OUTPUT" | sed 's/\x1b\[[0-9;]*m//g' | tr '\n' '\276' | tr -d "[:cntrl:]" | tr "\276" "\n" )"
OUTPUT_RAW="$(echo "$COMMAND_OUTPUT" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | awk '{printf "%s\\n", $0}' )"

# Write log to file
write_status "$STATUS" "$EXIT_CODE" "$OUTPUT_RAW"
