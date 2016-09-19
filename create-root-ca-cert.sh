#!/bin/bash

# Licensed to the Symphony Software Foundation (SSF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The SSF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

echo `date`
echo "*********************************************************************"
echo "**                                                                 **"
echo "**          Create a PKI (Root CA) Signing Certificate to import   **"
echo "**          on a Symphony Pod and authenticate Symphony bots       **"
echo "**                                                                 **"
echo "*********************************************************************"

mkdir -p ./root

if [ -f openssl-root-ca.ini ]; then
  echo "Found openssl-root-ca.ini file"
else
	cp openssl-root-ca.ini.sample openssl-root-ca.ini
  echo "Copied openssl-root-ca.ini.sample to openssl-root-ca.ini"
fi

if [ -d certs ]; then
  echo "Found certs folder"
else
  mkdir -p ./certs
  touch ./certs/certindex.txt
  echo "100000" > ./certs/serial
fi

if [ -f ./root/ca_signing_key.pem ]; then
		echo "ERROR: Signing cert already exists in 'root/ca_signing_key.pem'"
		echo "back up and/or delete before continuing"
		exit -1
fi
echo 'Running: openssl req -new -x509 -extensions v3_ca -keyout root/ca_signing_key.pem -out root/ca_signing_cert.pem -days 3650 -config ./openssl-root-ca.ini'
openssl req -new -x509 -extensions v3_ca -keyout root/ca_signing_key.pem -out root/ca_signing_cert.pem -days 3650 -config ./openssl-root-ca.ini

if [ -f ./root/ca_signing_key.pem ]; then
		echo "SUCCESS!"
		echo "Back up 'root/ca_signing_key.pem' and 'root/ca_signing_cert.pem'"
		echo "Do not share 'root/ca_signing_key.pem'"
		echo "Import 'root/ca_signing_cert.pem' into the Managed Certificates dashboard of the Symphony Admin Console"
fi
