#!/bin/bash
source ~/redenv/bin/activate
python -m pip install -U pip setuptools wheel
python -m pip install -U Red-DiscordBot
redbot-setup
redbot-launcher
