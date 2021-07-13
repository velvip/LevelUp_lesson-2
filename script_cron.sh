#!/bin/bash
crontab -l > foocron
echo "* * * * * /tmp/log.sh" >> foocron
crontab foocron
rm foocron