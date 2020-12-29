# mini-breakpad-server

Minimum collecting server for crash reports sent by
[google-breakpad](https://code.google.com/p/google-breakpad/).


## Features

* No requirement for setting up databases or web servers.
* Collecting crash reports with minidump files.
* Simple web interface for viewing translated crash reports.
* DB, dumps and symbols will be in `pool` folder

## Prepare
* `npm install`
* `grunt`
* Put your breakpad symbols under `pool/symbols/PRODUCT_NAME` (for electron: `pool/symbols/electron.exe.pdb/<id>/electron.exe.sym`)

## Run
* `sudo API_KEY="<api_key>" npm run start`