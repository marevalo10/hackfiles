#!/bin/bash
echo $EUID
if [[ "$EUID" != 0 ]]; then
        echo "Should run it as sudo $0";
        username=$(whoami);
        echo $username;
        exit 0;
else
        echo "Running as root";
fi
echo "Test"
