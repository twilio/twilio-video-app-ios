echo "My new script"

INFO_PLIST_FILE=${CODESIGNING_FOLDER_PATH}/Info.plist

echo $INFO_PLIST_FILE

app_center_app_secret=$(jq '.app_center_app_secret' ../Credentials/Credentials.json)

LC_ALL=C sed -i '' -e "s/APP_CENTER_APP_SECRET_PLACEHOLDER/$app_center_app_secret/" ${CODESIGNING_FOLDER_PATH}/Info.plist

# Add error handling 