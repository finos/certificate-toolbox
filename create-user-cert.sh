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
echo "**          Create an X.509 (User) Identity Certificate            **"
echo "**          for a Symphony Bot                                     **"
echo "**                                                                 **"
echo "*********************************************************************"

if [ -z "$DURATION_IN_DAYS" ]; then
  	DURATION_IN_DAYS=3650
else
	echo "NOTE! Overriding DURATION_IN_DAYS with $DURATION_IN_DAYS"
fi

mkdir -p ./users

if [ -f openssl-user.ini ]; then
  echo "Found openssl-user.ini file"
else
	cp openssl-user.ini.sample openssl-user.ini
  echo "Copied openssl-user.ini.sample to openssl-user.ini"
fi

if [ -f root/ca_signing_key.pem ]; then
  echo "Found root/ca_signing_key.pem file"
else
	echo "ERROR: Please create signing certificate by running 'make-root-ca-cert.sh'"
	exit -1
fi

if [ -z "$1" ]; then
	echo "ERROR: Please specify the certificate filename on the command line such as 'make-user-cert.sh botuser1'"
	exit -1
else
	echo "Running: openssl req -new -nodes -out users/$1-req.pem -keyout users/$1-key.pem -days ${DURATION_IN_DAYS} -config ./openssl-user.ini"
	openssl req -new -nodes -out users/$1-req.pem -keyout users/$1-key.pem -days ${DURATION_IN_DAYS} -config ./openssl-user.ini

	echo "Running: openssl ca -out users/$1-cert.pem -days ${DURATION_IN_DAYS} -config ./openssl-user.ini -infiles users/$1-req.pem"
	openssl ca -out users/$1-cert.pem -days ${DURATION_IN_DAYS} -config ./openssl-user.ini -infiles users/$1-req.pem

	echo "Running: openssl pkcs12 -export -in users/$1-cert.pem -inkey users/$1-key.pem -certfile root/ca_signing_cert.pem -name $1 -out users/$1-cert.p12"
	openssl pkcs12 -export -in users/$1-cert.pem -inkey users/$1-key.pem -certfile root/ca_signing_cert.pem -name $1 -out users/$1-cert.p12

	if [ -f users/$1-cert.p12 ]; then
    echo "Created signed certificate file users/$1-cert.p12 ; you can now (securely) distribute it to the owner of '$1' Service Account."
  fi
fi
