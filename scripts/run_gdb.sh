#!/bin/bash

if (echo >/dev/tcp/localhost/1234) &>/dev/null; then
    echo "Port 1234 is already in use"
    exit 1
else
    echo "Port 1234 is not in use"
    echo "Are you running qemu with debug mode?"
    exit 1
fi