#!/bin/bash
# Entry script to start Xvfb and set display
set -e

# Set sensible defaults for env variables that can be overridden while running
# the container
DEFAULT_LOG_LEVEL="INFO"
DEFAULT_RES="1280x1024x24"
DEFAULT_DISPLAY=":99"
DEFAULT_ROBOT="pybot"

# Use default if none specified as env var
LOG_LEVEL=${LOG_LEVEL:-$DEFAULT_LOG_LEVEL}
RES=${RES:-$DEFAULT_RES}
DISPLAY=${DISPLAY:-$DEFAULT_DISPLAY}
ROBOT_MODE=${ROBOT_MODE:-$DEFAULT_ROBOT}

if [[ -n ${ROBOT_TESTS} ]];
then
  echo ""
else
  echo "Error: Please specify the robot test or directory as env var ROBOT_TESTS"
  exit 1
fi

if [[ -n ${ROBOT_LOGS} ]];
then
  echo ""
else
  echo "Error: Please specify the robot test or directory as env var ROBOT_LOGS"
  exit 1
fi

# Process optional parameters passed to pybot/pabot
OPTIONAL_PARAMETERS=""

if [[ -n ${ROBOT_VAR} ]]
then
    OPTIONAL_PARAMETERS+="--variablefile ${ROBOT_VAR} "
fi

if [[ -n ${ROBOT_ITAG} ]]
then
    OPTIONAL_PARAMETERS+="-i ${ROBOT_ITAG} "
fi

if [[ -n ${ROBOT_ETAG} ]]
then
    OPTIONAL_PARAMETERS+="-e ${ROBOT_ETAG} "
fi

if [[ -n ${ROBOT_TEST} ]]
then
    OPTIONAL_PARAMETERS+="-t ${ROBOT_TEST} "
fi

if [[ -n ${ROBOT_SUITE} ]]
then
    OPTIONAL_PARAMETERS+="-s ${ROBOT_SUITE} "
fi

# Start Xvfb
echo -e "Starting Xvfb on display ${DISPLAY} with res ${RES}"
Xvfb ${DISPLAY} -ac -screen 0 ${RES} +extension RANDR &
export DISPLAY=${DISPLAY}

# Execute tests
if [ "${ROBOT_MODE}" != "pabot" ]
then
  echo -e "Executing robot tests at log level ${LOG_LEVEL}, parameters ${OPTIONAL_PARAMETERS}with pybot"
  pybot --loglevel ${LOG_LEVEL} ${OPTIONAL_PARAMETERS}--outputdir ${ROBOT_LOGS} ${ROBOT_TESTS}
else
  echo -e "Executing robot tests at log level ${LOG_LEVEL}, parameters ${OPTIONAL_PARAMETERS}with pabot"
  pabot --loglevel ${LOG_LEVEL} ${OPTIONAL_PARAMETERS}--outputdir ${ROBOT_LOGS} ${ROBOT_TESTS}
fi



# Stop Xvfb
kill -9 $(pgrep Xvfb)