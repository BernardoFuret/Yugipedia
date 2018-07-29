#!/bin/sh

LIGHT_BLUE="\033[1;34m"
NO_COLOR="\033[0m"
DUMP_FOLDER=files

echo -e ">> ${LIGHT_BLUE}Creating dump folder.${NO_COLOR}"
rm -rf ${DUMP_FOLDER}
mkdir ${DUMP_FOLDER}

echo -e ">> ${LIGHT_BLUE}Installing dependencies.${NO_COLOR}"
npm install --save node-fetch

echo -e ">> ${LIGHT_BLUE}Executing.${NO_COLOR}"
node DownloadFromWikia.js

echo -e ">> ${LIGHT_BLUE}Cleanup.${NO_COLOR}"
find . -maxdepth 1 ! \( -name "*.js" -o -name "*.sh" -o -name "." -o -name ${DUMP_FOLDER} \) -exec rm -rf {} \;
