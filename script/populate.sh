#!/bin/sh
rm db/dev.db
rake migrate
script/runner 'load "db/synchronise_cert_people.rb"'
