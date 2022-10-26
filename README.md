<!---
Copyright 2022 PrimeQA Team

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
-->
<!-- START sphinx doc instructions - DO NOT MODIFY next code, please -->
<div align="center">
    <img src="static/PrimeQA.png" width="150"/>
</div>
<!-- END sphinx doc instructions - DO NOT MODIFY above code, please -->

# PrimeQA Application

This repository provides easy scripts to run PrimeQA applications via docker.
<br>

[![LICENSE|Apache2.0](https://img.shields.io/github/license/saltstack/salt?color=blue)](https://www.apache.org/licenses/LICENSE-2.0.txt)

<h3> ✅ Prerequisites </h3>

We use [docker](https://www.docker.com/) and [docker-compose](https://docs.docker.com/compose/) to run application. Make sure you have most up-to-date version of the those tools. 

⚠️ **Important**: Make sure your docker has read/write permissions in existing directory and sub-directories.


<h3> 💻 Hardware Requirements </h3>

OS: Ubuntu 20.04.4 LTS

Memory: 32GB (64GB - Recommended)

GPU: NVIDIA Corporation GV100GL [V100 PCIe 16GB]

NVIDIA Driver version: 470.141.03

Disk space: 50 GB required for the docker, 25 GB available free space in the docker container storage

<h3> 🧩 Installation </h3>

1. Set environment variable `PUBLIC_IP` to the ip address of the localhost.

2. Run `launch.sh`.  

3. By default, step 2 launches the containers in 'cpu' mode. To launch with gpu support, run launch.sh with `-m gpu` argument as follows `launch.sh -m gpu`. 

🚨 **Note**: This process will take a while to complete as it will download necessary docker images and bring up services.


<h3>⚙️ Configuration </h3>

1. Run `docker ps` to verify all three containers (primeqa-ui, primqa-orchestrator and primeqa-service) are running.

2. You will need to configure few additional settings before first use. These setting are intentionally left blank for security purposes, 

3. Open browser of choice (Mozilla Firefox/Google chorme) and visit "http://`{PUBLIC_IP}`:50059/docs". This url shows available orchestrator APIs.

4. Click on [PATCH] `/settings`. Once expanded, click on `Try it out` button and copy-paste following content in the request body section.
    
    a. For IBM® Watson Discovery based retriever, update `Watson Discovery` releated section in `retrievers`
    ```json
        "Watson Discovery": {
            "service_endpoint": "<IBM® Watson Discovery Cloud/CP4D Instance Endpoint>",
            "service_token": "<Bearer token (If using IBM® Watson Discovery CP4D Instance)>",
            "service_api_key": "<API key (If using IBM® Watson Discovery Cloud instance)>",
            "service_project_id": "<IBM® Watson Discovery Project ID>"
        }
    ```

    b. For PrimeQA based retrievers, update `PrimeQA` related section in `retrievers` as follows
    ```json
        "PrimeQA": {
            "service_endpoint": "primeqa:50051"
        }
    ```

    c. For PrimeQA based readers, update `PrimeQA` related section in `readers` as follows
    ```json
        "PrimeQA": {
            "service_endpoint": "primeqa:50051",
            "beta": 0.7
        }
    ```


    For example,  when IBM® Watson Discovery CP4D instance based retriever and PrimeQA based reader is used, the settings will look as follows

    ```json
	{
        "retrievers": {
            "Watson_Discovery": {
                "service_endpoint": "<IBM® Watson Discovery CP4D Instance Endpoint>",
                "service_token": "<Bearer token>",
                "service_project_id": "<IBM® Watson Discovery Project ID>"
            },
            "PrimeQA": {
                "service_endpoint": "primeqa:50051"
            },
            "alpha": 0.8
        },
        "readers": {
            "PrimeQA": {
                "service_endpoint": "primeqa:50051",
                "beta": 0.7
            }
        }
    }
    ```

5. Click `Execute` button. You will see status code: 200 and updated setting once you scroll down.

<h3> 🧪 Testing </h3>

1. You can test out primeqa orchestrator's connectivity to your IBM® Watson Discovery (WD) instance by executing [GET] `/retrievers/{retriever_id}/collections` endpoint as follows

```sh
	curl -X 'GET' 'http://{PUBLIC_IP}:50059/retrievers/WatsonDiscovery/collections' -H 'accept: application/json'
```

2. To see all available retrievers, execute [GET] `/retrievers` endpoint

```sh
	curl -X 'GET' 'http://{PUBLIC_IP}:50059/retrievers' -H 'accept: application/json'
```

3. To run a sample question answering query, execture [POST] `/ask` endpoint

```sh
	curl -X 'POST' 'http://{PUBLIC_IP}:50059/ask' -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
  "question": "<SAMPLE QUERY>",
  "retriever": {
    "retriever_id": "WatsonDiscovery"
  },
  "collection": {
    "collection_id": "<collection_id> from collections returned by [GET]/collections API.",
    "name": "Name of corresponding collection"
  },
  "reader": {
    "reader_id": "ExtractiveReader"
  }
}'
```

<h2> 🥁 Enjoy </h2>
You can now open browser of choice (Mozilla Firefox/Google chorme) and visit "http://{PUBLIC_IP}:82" to interact with PrimeQA application.