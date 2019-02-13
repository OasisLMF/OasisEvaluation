# OasisEvaluation
-----------------

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



#### [OasisUI Interface](http://localhost:8080) --- *localhost:8080* 
Main user interface for uploading exposure files and running analysis.


####[API Swagger UI](http://localhost:8000/) --- *localhost:8000*
Interactive API which lists and documents all endpoints. 
####[API Admin Panel](http://localhost:8000/admin) --- *localhost:8000/admin*
Admin interface to edit the database backing the API, allows access to create new users and update passwords.



## Exposure format (OED SPEC)
[Example Location Exposure]()


## Troubleshooting 
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
