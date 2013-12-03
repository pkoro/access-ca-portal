#!/bin/sh
script/runner 'load "script/GetRequests.rb"' csrs_sqlite_file
script/SignRequests.rb csrs_sqlite_file CA_FOLDR TEMP_FOLDER certs_sqlite_file
script/runner 'load "script/UploadCerts.rb"' certs_sqlite_file
