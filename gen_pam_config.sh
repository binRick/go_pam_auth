#!/usr/bin/env

sqlite3 pam_line-otp.db 'CREATE TABLE "users" ("account_name" varchar(32) UNIQUE,"line_id" varchar(40) )'
sqlite3 pam_line-otp.db 'INSERT INTO "users" VALUES ("test", "12345");'

echo -e "auth    required  $(pwd)/pam_line-otp.so DbPath=$(pwd)/pam_line-otp.db LineAccessToken=XXXXXX"
