#!/bin/bash
override_file='/etc/hiera/override/plugins_nsxv.yaml'
symlink_file='/etc/hiera/override/plugins.yaml'

if [ -L "$symlink_file" -a "$(readlink -f $symlink_file)" == "$override_file" ]; then
    rm -f "$symlink_file" "$override_file"
fi
