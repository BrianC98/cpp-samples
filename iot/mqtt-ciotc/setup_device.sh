# Copyright 2017 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#!/bin/bash

REGISTRY_NAME=my-registry
REGISTRY_REGION=us-central1
REGISTRY_TELEMETRY_TOPIC=device-events
DEVICE_ID=my-device

if [ ! -f rsa_private.pem ]; then
    openssl req -x509 -newkey rsa:2048 -keyout rsa_private.pem -nodes  -out rsa_cert.pem -subj "/CN=unused"
fi    

HAS_REGISTRY=`gcloud iot registries list --region=${REGISTRY_REGION} | grep ${REGISTRY_NAME} | wc -l`
if [ $HAS_REGISTRY == "0" ]; then
    gcloud iot registries create ${REGISTRY_NAME} \
        --region=${REGISTRY_REGION} \
        --enable-mqtt-config \
        --no-enable-http-config \
        --event-notification-config=topic=${REGISTRY_TELEMETRY_TOPIC}
fi
HAS_DEVICE=`gcloud iot devices list --registry=${REGISTRY_NAME} --region=${REGISTRY_REGION} --device-ids=${DEVICE_ID} | grep ${DEVICE_ID} | wc -l`
if [ $HAS_DEVICE == "0" ]; then
    gcloud iot devices create ${DEVICE_ID} \
        --region=${REGISTRY_REGION} \
        --registry=${REGISTRY_NAME} \
        --public-key=path=./rsa_cert.pem,type=rsa-x509-pem
        
fi

if [ ! -f roots.pem ]; then
    wget https://pki.google.com/roots.pem
fi    