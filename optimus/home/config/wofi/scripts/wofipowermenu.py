#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os


def run_menu():
    keys = (
        "\uf2dc   Lock",
        "\uf2dc   Logout",
        "\uf186   Suspend",
        "\uf021   Reboot",
        "\uf011   Shutdown",
        "\uf021   UEFI Firmware",
    )

    actions = (
        "hyprlock",
        "loginctl terminate-session $(loginctl session-status | head -n 1 | awk '{print $1}')",
        "loginctl lock-sessions; systemctl suspend",
        "systemctl reboot",
        "systemctl poweroff",
        "systemctl reboot --firmware-setup",
    )

    options = "\n".join(keys)
    choice = (
        os.popen(
            "echo -e '"
            + options
            + "' | wofi -d -i -p 'Power Menu' -W 600 -H 300 -k /dev/null"
        )
        .readline()
        .strip()
    )
    if choice in keys:
        os.popen(actions[keys.index(choice)])


run_menu()
