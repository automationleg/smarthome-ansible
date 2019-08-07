#!/bin/bash

# Backup
sudo docker exec db /usr/bin/mysqldump -u zmuser --password=zmpass zm > backup.sql

