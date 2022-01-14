#!/bin/bash

# Add local user
# Either use the LOCAL_USER_ID if passed in at runtime or
# fallback

USER_ID=${LOCAL_USER_ID:-101}
GROUP_ID=${LOCAL_GROUP_ID:-100}
USER_NAME="nginx"

if (( $USER_ID < 1 || $GROUP_ID < 1 )); then
  echo "Skipping UID: $USER_ID GID: $GROUP_ID change for $USER_NAME"
else
  echo "Changing to UID: $USER_ID GID: $GROUP_ID for $USER_NAME"
  usermod -u $USER_ID $USER_NAME
  groupmod -g $GROUP_ID $USER_NAME
fi

exec "$@"
