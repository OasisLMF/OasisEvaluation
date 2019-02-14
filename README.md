Oasis Evaluation 1.0.0 Release 
--------------------------------

The shift to Oasis Platform 1.0.0 represents a significant shift in architecture, since the Windows SQL server is no longer required the entire platform can be run via docker containers on a single machine or, if required, scaled up in size to run on a container orchestration based system such as [kubernetes](https://kubernetes.io).

Docker support is the main requirement for running the platform, this is generally limited to Linux so that is the main focus of this example Evaluation deployment. Running the install script from this repository automates install process of the **OasisPlatform API 1.0.0**, **User Interface** and example **PiWind model**. 


### Instalation Steps

1) install git, docker and docker-compose

For example on an Ubuntu/Debian based Linux system use:
```
apt update && apt install git docker docker-compose 
```

 
2) Clone this repository 
```
git clone https://github.com/OasisLMF/OasisEvaluation.git 
cd OasisEvaluation
```
3) Run the depoyment script 
```
./install.sh
```


## Web interfaces 
On installation a single admin account is created which is used to accessing the following web interfaces.

```
User: admin
Pass: password
```



### [OasisUI Interface](http://localhost:8080) - *localhost:8080* 
![alt text](https://github.com/OasisLMF/OasisEvaluation/raw/master/.img/oasisui.png)

### [API Swagger UI](http://localhost:8000/) - *localhost:8000*
![alt text](https://github.com/OasisLMF/OasisEvaluation/raw/master/.img/api_swagger.png)

### [API Admin Panel](http://localhost:8000/admin) - *localhost:8000/admin*
![alt text](https://github.com/OasisLMF/OasisEvaluation/raw/master/.img/admin_panel.png)

## Exposure inputs

This Beta example only supports the [Open Exposure Data (OED)](https://github.com/Simplitium/OED) standard as exposure inputs.

Example files are avalible for the PiWind model:

* [SourceLocOEDPiWind10.csv](https://raw.githubusercontent.com/OasisLMF/OasisEvaluation/master/example_files/SourceLocOEDPiWind10.csv?token=AJbotaz-o8d1bp01mc3hSHdokCrXQpxAks5cboSvwA) --- Locations Data
* [SourceAccOEDPiWind.csv](https://raw.githubusercontent.com/OasisLMF/OasisEvaluation/master/example_files/SourceAccOEDPiWind.csv?token=AJbotXImZFbEH21jJP8yd6CxCULvTkQSks5cboSywA) --- Accounts Data
* [SourceReinsInfoOEDPiWind.csv](https://raw.githubusercontent.com/OasisLMF/OasisEvaluation/master/example_files/SourceReinsInfoOEDPiWind.csv?token=AJbotVOYhdlth1bALv-qrw9neW0iU8osks5cboS3wA) --- Reisurance Info 
* [SourceReinsScopeOEDPiWind.csv](https://raw.githubusercontent.com/OasisLMF/OasisEvaluation/master/example_files/SourceReinsScopeOEDPiWind.csv?token=AJbotdVn3Jxvlf0l4ZWy1Y76btVtxT-gks5cboS6wA) --- Reinsurance Scope 



## Troubleshooting 
Feedback and error reports are invaluable for improving the stability and performance of the Oasis Platform, If you encounter an issue please consider [submitting an issue here](https://github.com/OasisLMF/OasisPlatform/issues)

### Checking that the containers are up


**OasisAPI**
```
$ docker-compose -f OasisPlatform/docker-compose.yml ps

             Name                           Command               State   
--------------------------------------------------------------------------------
oasisplatform_celery-db_1        docker-entrypoint.sh --def ...   Up      3306/tcp, 33060/tcp                                                                       
oasisplatform_flower_1           flower --port=5555 --broke ...   Up      0.0.0.0:5555->5555/tcp                                                                    
oasisplatform_rabbit_1           docker-entrypoint.sh rabbi ...   Up      15671/tcp, 0.0.0.0:15672->15672...
oasisplatform_server-db_1        docker-entrypoint.sh --def ...   Up      3306/tcp, 33060/tcp                                                                       
oasisplatform_server_1           startup ./uwsgi/run-uwsgi.sh     Up      0.0.0.0:8000->8000/tcp                                                                    
oasisplatform_worker-monitor_1   startup wait-for-server se ...   Up      8000/tcp                                                                                  
oasisplatform_worker_1           /bin/sh -c ./startup.sh          Up   
```

**OasisUI**
```
$ docker-compose -f OasisUI/docker-compose.yml ps

    Name                Command           State           Ports         
------------------------------------------------------------------------
oasisui_proxy   /bin/sh -c ./startup.sh   Up      0.0.0.0:8080->8080/tcp

```

```
$ docker network ls
NETWORK ID          NAME                          DRIVER              SCOPE
9c18005bb50c        bridge                        bridge              local
af79e1aabc47        host                          host                local
8fe6ef78edb0        none                          null                local
35a827cc08f5        oasisplatform_default         bridge              local
aa336481f023        patch-oasisplatform_default   bridge              local
28cd502f5b2a        patch_oasisplatform_default   bridge              local
f206aa4a0f58        shiny-net                     bridge              local
```









## Configuration 
