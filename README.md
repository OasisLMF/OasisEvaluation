<img src="https://oasislmf.org/packages/oasis_theme_package/themes/oasis_theme/assets/src/oasis-lmf-colour.png" alt="Oasis LMF logo" width="250"/>

# Oasis Evaluation 1.0.0 Release 

The Oasis Platform 1.0.0 release includes a full API for operating catastrophe models and a general consolidation of the platform architecture.
Windows SQL server is no longer a strict requirement.
The platform can be run via docker containers on a single machine or, if required, scaled up to run on a cluster.

Docker support is the main requirement for running the platform.
A Linux based installation is the main focus of this example Evaluation deployment. 
Running the install script from this repository automates install process of the OasisPlatform API 1.0.0, User Interface and example PiWind model. 

## Install Prerequisites
* Host Operating system with docker support, see [Docker compatibility matrix](https://success.docker.com/article/compatibility-matrix).
* For this example we’ve used [Docker compose](https://docs.docker.com/compose/) which is required for running the install script

## Cloud Provisioning 
PiWind is an example Toy model so only requires a small to medium sized Instance for demonstration. This of course will change depending on the size and complexity of the models hosted on the platform. 

* For running in AWS EC2 we recommend a a medium sized general purpose Instance such as *T2.medium* or larger 
* To host on Azure use a *Standard_B2s* or larger instance 
  
## Installation Steps

1) install git, docker and docker-compose

For example on an Ubuntu/Debian based Linux system use:
```
sudo apt update && sudo apt install git docker docker-compose 
```

2) Clone this repository 
```
git clone https://github.com/OasisLMF/OasisEvaluation.git 
cd OasisEvaluation
```
3) Run the deployment script 
```
sudo ./install.sh
```
> Note: sudo is not required if the Dcoker [post-install steps](https://docs.docker.com/install/linux/linux-postinstall/) are followed to run docker as a non-root user.

#### Oasis Docker Components 

* [(UI) shiny_proxy](https://hub.docker.com/r/coreoasis/oasisui_proxy/tags) - The shiny-proxy host which creates a new UI session for each incoming connection request.
* [(UI) oasisui_app](https://hub.docker.com/r/coreoasis/oasisui_app/tags) - The R-Shiny application container running the Oasis UI.
* [(API) server](https://hub.docker.com/r/coreoasis/api_server/tags) - The API server which is based on Django REST framework.
* [(API) worker-monitor](https://hub.docker.com/r/coreoasis/api_server/tags) - Celery worker which watches all connected model_workers and pushes status updates to the API.
* [(API) worker](https://hub.docker.com/r/coreoasis/model_worker/tags) - The Oasis worker which executes, model lookups, oasis files generation and ktools analysis. 

#### External Docker Components 
* [(API) server-db](https://hub.docker.com/_/mysql) - MySQL database for the Django API Server 
* [(API) celery-db](https://hub.docker.com/_/mysql) - MySQL database for Celery
* [(API) rabbit](https://hub.docker.com/_/rabbitmq) - message broker

## Web interfaces 
On installation a single admin account is created which is used to access the following web interfaces.

```
User: admin
Pass: password
```

### [OasisUI Interface](http://localhost:8080/app/BFE_RShiny) - *localhost:8080/app/BFE_RShiny* 
![alt text](https://github.com/OasisLMF/OasisEvaluation/raw/master/.img/oasisui.png)

### [API Swagger UI](http://localhost:8000/) - *localhost:8000*
![alt text](https://github.com/OasisLMF/OasisEvaluation/raw/master/.img/api_swagger.png)

### [API Admin Panel](http://localhost:8000/admin) - *localhost:8000/admin*
![alt text](https://github.com/OasisLMF/OasisEvaluation/raw/master/.img/admin_panel.png)

## Exposure inputs

The Oasis platform supports the [Open Exposure Data (OED)](https://github.com/Simplitium/OED) standard for importing exposure.
Example files are available for the PiWind model:

* [SourceLocOEDPiWind10.csv](https://raw.githubusercontent.com/OasisLMF/OasisPiWind/master/tests/data/SourceLocOEDPiWind10.csv) --- Locations Data
* [SourceAccOEDPiWind.csv](https://raw.githubusercontent.com/OasisLMF/OasisPiWind/master/tests/data/SourceAccOEDPiWind.csv) --- Accounts Data
* [SourceReinsInfoOEDPiWind.csv](https://raw.githubusercontent.com/OasisLMF/OasisPiWind/master/tests/data/SourceReinsInfoOEDPiWind.csv) --- Reinsurance Info 
* [SourceReinsScopeOEDPiWind.csv](https://raw.githubusercontent.com/OasisLMF/OasisPiWind/master/tests/data/SourceReinsScopeOEDPiWind.csv) --- Reinsurance Scope 

## Troubleshooting 
Feedback and error reports are invaluable for improving the stability and performance of the Oasis Platform, If you encounter an issue please consider [submitting an issue here](https://github.com/OasisLMF/OasisPlatform/issues)

#### Viewing logs 

`docker logs oasisplatform_worker_1`
```
Generating losses
[2019-02-13 17:48:44,166: INFO/ForkPoolWorker-1] 
Switching CWD to /tmp/tmp3ddy2doi
[2019-02-13 17:48:44,166: INFO/ForkPoolWorker-1] STARTED: oasislmf.model_execution.runner.run
[2019-02-13 17:48:46,356: INFO/ForkPoolWorker-1] COMPLETED: oasislmf.model_execution.runner.run in 2.19s
[2019-02-13 17:48:46,356: INFO/ForkPoolWorker-1] 
Loss outputs generated in /tmp/tmp3ddy2doi/output
[2019-02-13 17:48:46,356: INFO/ForkPoolWorker-1] 
Finished loss generation (2.286 seconds)
[2019-02-13 17:48:46,373: INFO/ForkPoolWorker-1] Output location = b05026a0ea1e4c2cbcc47bacab4af95b.tar
[2019-02-13 17:48:46,373: INFO/ForkPoolWorker-1] COMPLETED: src.model_execution_worker.tasks.start_analysis in 2.31s
[2019-02-13 17:48:46,381: INFO/ForkPoolWorker-1] Task run_analysis[6ea4a9b3-b829-4046-82dd-bfb2c714bc10] succeeded in 2.3318499579982017s: 'b05026a0ea1e4c2cbcc47bacab4af95b.tar'

...
```

`docker logs oasisplatform_server_1`
```
[pid: 67|app: 0|req: 45/105] 192.168.192.1 () {38 vars in 805 bytes} [Thu Feb 14 12:15:07 2019] GET /static/drf-yasg/insQ.min.js => generated 0 bytes in 1 msecs (HTTP/1.1 304) 2 headers in 92 bytes (0 switches on core 0)
[pid: 65|app: 0|req: 17/106] 192.168.192.1 () {38 vars in 819 bytes} [Thu Feb 14 12:15:07 2019] GET /static/drf-yasg/swagger-ui-init.js => generated 0 bytes in 1 msecs (HTTP/1.1 304) 2 headers in 92 bytes (0 switches on core 0)
INFO 2019-02-14 12:15:07,339 generators 68 139841283544896 view <class 'src.server.oasisapi.auth.views.TokenRefreshView'> uses URLPathVersioning but URL /refresh_token/ has no param {version}
INFO 2019-02-14 12:15:07,339 generators 68 139841283544896 view <class 'src.server.oasisapi.auth.views.TokenObtainPairView'> uses URLPathVersioning but URL /access_token/ has no param {version}
INFO 2019-02-14 12:15:07,339 generators 68 139841283544896 view <class 'src.server.oasisapi.healthcheck.views.HealthcheckView'> uses URLPathVersioning but URL /healthcheck/ has no param {version}

...
```
`docker logs oasisplatform_worker-monitor_1`
```
[2019-02-14 11:23:39,709: INFO/MainProcess] Connected to amqp://rabbit:**@rabbit:5672//
[2019-02-14 11:23:39,728: INFO/MainProcess] mingle: searching for neighbors
[2019-02-14 11:23:40,777: INFO/MainProcess] mingle: all alone
[2019-02-14 11:23:40,807: WARNING/MainProcess] /usr/local/lib/python3.6/site-packages/celery/fixups/django.py:202: UserWarning: Using settings.DEBUG leads to a memory leak, never use this setting in production environments!
  warnings.warn('Using settings.DEBUG leads to a memory leak, never '
[2019-02-14 11:23:41,616: INFO/MainProcess] Received task: run_register_worker[21e8c3b5-116e-41d7-8a73-e0109796fb04]  
/usr/local/lib/python3.6/site-packages/celery/platforms.py:795: RuntimeWarning: You're running the worker with superuser privileges: this is
absolutely not recommended!

Please specify a different user using the -u option.

User information: uid=0 euid=0 gid=0 egid=0

  uid=uid, euid=euid, gid=gid, egid=egid,
[2019-02-14 11:23:41,618: INFO/ForkPoolWorker-1] run_register_worker[21e8c3b5-116e-41d7-8a73-e0109796fb04]: model_supplier: OasisIM, model_name: PiWind, model_id: 1
[2019-02-14 11:23:42,422: INFO/MainProcess] Events of group {task} enabled by remote.

...
```

#### Checking that the containers are up
                                            
`docker ps -a`
```
CONTAINER ID        IMAGE                            COMMAND                  CREATED             STATUS                      PORTS                                                                                        NAMES
8e7ca227c0cb        coreoasis/oasisui_app:latest     "R -e flamingo::runF…"   21 hours ago        Exited (137) 17 hours ago                                                                                                ecstatic_ramanujan
a0e34d052776        coreoasis/model_worker:latest    "/bin/sh -c ./startu…"   21 hours ago        Up 2 hours                                                                                                               oasisplatform_worker_1
e04153bd9c3d        coreoasis/api_server:latest      "startup wait-for-se…"   21 hours ago        Up 2 hours                  8000/tcp                                                                                     oasisplatform_worker-monitor_1
02d674c97796        coreoasis/api_server:latest      "startup ./uwsgi/run…"   21 hours ago        Up 2 hours                  0.0.0.0:8000->8000/tcp                                                                       oasisplatform_server_1
95a26c60ad4f        iserko/docker-celery-flower      "flower --port=5555 …"   21 hours ago        Up 2 hours                  0.0.0.0:5555->5555/tcp                                                                       oasisplatform_flower_1
6ff9e92e55d1        mysql                            "docker-entrypoint.s…"   21 hours ago        Up 2 hours                  3306/tcp, 33060/tcp                                                                          oasisplatform_celery-db_1
e2b36b1bf91c        rabbitmq:3-management            "docker-entrypoint.s…"   21 hours ago        Up 2 hours                  4369/tcp, 5671/tcp, 0.0.0.0:5672->5672/tcp, 15671/tcp, 25672/tcp, 0.0.0.0:15672->15672/tcp   oasisplatform_rabbit_1
804f7d64015b        mysql                            "docker-entrypoint.s…"   21 hours ago        Up 2 hours                  3306/tcp, 33060/tcp                                                                          oasisplatform_server-db_1
561ac5c8cf5f        coreoasis/oasisui_proxy:latest   "/bin/sh -c ./startu…"   22 hours ago        Up 15 hours                 0.0.0.0:8080->8080/tcp                                                                       oasisui_proxy
                                                                     oasisui_proxy

```
