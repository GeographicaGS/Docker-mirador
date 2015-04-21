#!/bin/bash
export PATH=$PATH:/usr/local/pgsql/bin
service apache2 start
service postgresql-9.1.2 start
bash