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

We use [docker](https://www.docker.com/) and [docker-compose](https://docs.docker.com/compose/) to run our application. Make sure you have the most up-to-date version of those tools. 

⚠️ **Important**: Make sure your docker has read/write permissions in the existing directory and sub-directories.


<h3> 💻 Hardware Requirements </h3>

OS: Ubuntu 20.04.4 LTS

Memory: 32GB (64GB - Recommended)

GPU: NVIDIA Corporation GV100GL [V100 PCIe 16GB]

NVIDIA Driver version: 470.141.03

Disk space: 50 GB is required for the docker, 25 GB of available free space is needed in the docker container storage

<h3> 🧩 Installation </h3>

1. Set the environment variable `PUBLIC_IP` to the ip address of the localhost. This host must be reachable from where you will be running the browser. Otherwise, please use VNC to access the host.
If running the application locally,  `PUBLIC_IP` can be set to `localhost`.

```
export PUBLIC_IP=<hostname>
```

2. Please ensure that the following three ports are free and available: `50051`, `50059` and `82`

2. Run `launch.sh`  

3. By default, step 2 launches the containers in 'cpu' mode. To launch with gpu support, run launch.sh with `-m gpu` argument as follows `launch.sh -m gpu`

🚨 **Note**: This process will take a while to complete as it will download necessary docker images and bring up services.


<h3>⚙️ Configuration </h3>

1. Run `docker ps` to verify that all the three containers (primeqa-ui, primqa-orchestrator and primeqa-service) are running.

2. You will need to configure a few additional settings before first use. These setting are intentionally left blank for security purposes. 

3. Open your browser of choice (Mozilla Firefox/Google Chorme) and visit "http://`{PUBLIC_IP}`:50059/docs". This url shows the available orchestrator APIs.

4. Click on [PATCH] `/settings`. Once expanded, click on the `Try it out` button and copy-paste the Retriever and Reader settings that you would like to use. 

    a. To use the IBM® Watson Discovery Cloud/CP4D retriever and PrimeQA reader, first configure a Watson Discovery instance using the instructions [here](https://cloud.ibm.com/catalog/services/watson-discovery).

    ```json
	{
        "retrievers": {
            "Watson Discovery": {
                "service_endpoint": "<IBM® Watson Discovery Cloud/CP4D Instance Endpoint>",
                "service_token": "<Bearer token (If using IBM® Watson Discovery CP4D Instance)>",
                "service_api_key": "<API key (If using IBM® Watson Discovery Cloud instance)>",
                "service_project_id": "<IBM® Watson Discovery Project ID>"
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
    
    b. To use the PrimeQA retriever and PrimeQA reader, first setup the collection index for the Retriever using the instructions [here](https://github.com/primeqa/primeqa/tree/main/primeqa/services).

    ```json
	{
        "retrievers": {
            "PrimeQA": {
                "service_endpoint": "primeqa:50051",
                "beta": 0.7
            }
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

5. Click the `Execute` button. You will see status code: 200 indicating success and updated settings when you scroll down.

6. Please allow 30 seconds for the primeqa-orchestrator to establish connectivity to Watson Discovery and PrimeQA service.

<h3> 🧪 Testing </h3>

1. You can test the PrimeQA orchestrator's connectivity to your IBM® Watson Discovery (WD) instance by executing the [GET] `/retrievers/{retriever_id}/collections` endpoint.

```sh
	curl -X 'GET' 'http://{PUBLIC_IP}:50059/retrievers/WatsonDiscovery/collections' -H 'accept: application/json'
```

2. To see all available retrievers, execute [GET] `/retrievers` endpoint

```sh
	curl -X 'GET' 'http://{PUBLIC_IP}:50059/retrievers' -H 'accept: application/json'
```

3. To run a sample question answering query, execute [POST] `/ask` endpoint

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

<h2> 🥁 Usage </h2>

You can now open a browser of your choice (Mozilla Firefox/Google Chrome) and visit "http://{PUBLIC_IP}:82" to interact with the PrimeQA application. You will see our Retrieval, Reader and QuestionAnswering components.  Some features include adjust settings and for users to provide feedback on retrieved answers. 

<h2> 🤨 User Feedback </h2>

Users can provide feedback via the thumbs up / thumbs down icons to the answers shown in the results page. 

To use the feedback, to fine-tune your Reader model

1. Get the feedback data:
  
  ```sh
    curl -X 'GET' \
  'http://localhost:50059/feedbacks?application=reading&application=qa&_format=primeqa' \
  -H 'accept: application/json' > feedbacks.json
  ```

3. Follow the instructions on how to finetune a PrimeQA reader with custom data [here](https://github.com/primeqa/primeqa/tree/main/examples/custom_mrc#finetuning-using-feedback-data). Generally, the finetuning would start with the model used when collecting the feedback data as specified in the `Model` field under `Reader` settings in the `Reading` and/or `QuestionAnswering` UI.

5. To deploy the finetuned model, follow the instructions in [FAQs #1](https://github.com/primeqa/create-primeqa-app#3-how-do-i-use-my-custom-model-for-reader-in-reading-or-qa-application-).


<h2> 🤨 Frequently Asked Questions (FAQs) </h2>

<h4> 1. Troubleshooting </h4>

a. If the UI is not loading properly or a field is blank, please try these quick steps:
   - clear the browser cache and retry
   - restart the containers by running `terminate.sh` and then `launch.sh`

b. To view the logs, use the docker logs command, for example:

```
docker logs primeqa-ui
docker logs primeqa-orchestrator
docker logs primeqa-services
```

<h4> 2. How do I switch to a different PrimeQA Reader model from the Huggingface model hub ? </h4>

 Paste the model name from the [Huggingface model hub](https://huggingface.co/PrimeQA) into the  `Model` field under `Reader` settings in the `Reading` and/or `QuestionAnswering` UI.

<h4> 3. How do I use my custom model for reader in `Reading` or `QA` application? </h4>

By default the reader initializes the `PrimeQA/tydiqa-primary-task-xlm-roberta-large` from the Huggingface model hub. 

To use your own reader model, place your model in a directory under `primeqa-store/model` and point to it from the UI.  From `Application Settings` scroll down to `Reader Settings` and to `Model` and set it to `/store/model/<model-dir>`,  replace `model-dir` with the name of the directory containing the model files.

The service will load the model and initialize a new reader.  This may take a few minutes. Subsequent queries will use this model.

<h4> How do I use my ColBERT index and checkpoint ? </h4>

Please follow the instructions in the [Store section](https://github.com/primeqa/primeqa/tree/main/primeqa/services) 

<h4> The Corpus field is blank in the 'Retriever' or 'Question Answering' page </h4>

See `./Troubleshooting`

