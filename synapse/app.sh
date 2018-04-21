#!/usr/bin/env bash -e

replaceInConfig() {
  ENV_VAL="$1"
  REPLACE="%$1%"
  sed -i "s#$REPLACE#${!ENV_VAL}#" "$SYNAPSE_CONF_FILE_PATH"
}

SYNAPSE_CONF_FILE_PATH="$SYNAPSE_CONF_PATH/$SYNAPSE_CONF_FILE"
SYNAPSE_CONF_D_PATH="$SYNAPSE_CONF_PATH/$SYNAPSE_CONF_D_DIR"
CONFIGS="--config-path=$SYNAPSE_CONF_FILE_PATH"

if [ ! -f "$SYNAPSE_CONF_FILE_PATH" ]; then
    echo "No config file for synapse was found, generating new config"

    if ! [[ -n "$MATRIX_DOMAIN" ]]; then
        echo "Matrix domain is not given! cannot create config file!"
        exit 1
    fi

    echo "Copying default config files"
    cp "$SYNAPSE_DEFAULT_CONF_PATH/$SYNAPSE_CONF_FILE" "$SYNAPSE_CONF_FILE_PATH"

    echo "Replacing placeholder values in default config file"
    replaceInConfig MATRIX_DOMAIN

    replaceInConfig SYNAPSE_CONF_PATH
    replaceInConfig SYNAPSE_DATA_PATH
    replaceInConfig SYNAPSE_LOG_PATH

    replaceInConfig POSTGRES_HOST
    replaceInConfig POSTGRES_DB
    replaceInConfig POSTGRES_USER
    replaceInConfig POSTGRES_PASSWORD

    echo "Adding custom config"
    echo >> "$SYNAPSE_CONF_FILE_PATH"
    echo '### CUSTOM CONFIG ###' >> "$SYNAPSE_CONF_FILE_PATH"
    echo >> "$SYNAPSE_CONF_FILE_PATH"

    echo "server_name: \"$MATRIX_DOMAIN\"" >> "$SYNAPSE_CONF_FILE_PATH"

    echo "Generating keys"
    python -m synapse.app.homeserver $CONFIGS --generate-keys

    echo
else
    echo "Using existing config file: $SYNAPSE_CONF_FILE_PATH"
fi

echo "Starting synapse"
exec python -m synapse.app.homeserver $CONFIGS
