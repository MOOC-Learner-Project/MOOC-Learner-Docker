# MOOC-Learner-Docker
-----------------------
## Table of Contents:
 - [Requirements](#requirements)
 - [Installation](#installation)
 - [Configuration](#configuration)
 - [Running Method](#running-method)
 - [Other Services](#other-services)
 - [Testing on Synthetic Data](#testing-on-synthetic-data)

## Requirements:
#### Softwares (with links to their docs)
 - [Docker](https://docs.docker.com/)
 - [Docker Compose](https://docs.docker.com/compose/)

#### Software Instaldetach from tmuxlation:
 - [Docker](https://docs.docker.com/engine/installation/)
 - [Docker Compose](https://docs.docker.com/compose/install/)

## Installation:
#### Recursively clone the repo
```
git clone --recursive git@github.mit.edu:ALFA-MOOCdb/MOOC-Learner-Docker.git
```
#### Build base images
For the convenience of testing and debugging, there is no complete image of each module. We rebuild each module on every execution of `docker-compose up`. So before building the images of modules and running the containers, you should build each base image. You can use
```
bash buildDockerImages.sh
```

And to remove with
```
bash cleanDockerImages.sh
```

Separately you can build with:

Enter directory `./curated_base_img` and run command:
```
docker build -t curated:base .
```
Enter directory `./quantified_base_img` and run command:
```
docker build -t quantified:base .
```
Enter directory `./visualized_base_img` and run command:
```
docker build -t visualized:base .
```
Enter directory `./modeled_base_img` and run command:
```
docker build -t modeled:base .
```

## Configuration:
Change the configuration by editing the `./config/config.yml` YAML file
#### MOOCdb config
In the `MOOCdb` section, change the default database name if you want.
#### Full Pipeline config
In the `full_pipeline` section, indicate that whether you want to run `MLC`, `MLQ`, `MLM` and `MLV`.

Note that you mush at least run MLC when executing the pipeline for the first time. But after that you may not need to run MLC again when the raw data is not updated.
#### Data file config
##### 1. To run MLC, first change the data dir in `docker-compose.yml`:
In section `services:curated:volumes` (at the second in-line comment), change the directory on the left to your local data dir
```
- [local data dir]:/data
```
##### 2. Then config the suffixes in `data_file` section if needed:
```
*_file: # the suffix of each raw data files
```
(no need to change for HKUSTx courses)
##### 3. (Optional) You can also change the directory where MySQL data mounts:
Since MySQL data are huge, you can mount them in another drive which has more spare space: In `docker-compose.yml`, section `services:db:volumes` (at the first in-line comment), change the on the left to your demanded directory
```
- [local mysql data dir]:/var/lib/mysql
```
Note you must create this folder in advance and have the read and write access to it.
#### MySQL password config
Using empty MySQL root password may be insecure. Note that phpMyAdmin is using the same set of username and password as MySQL server. Please secure your data by adding a root password.

##### 1. Modify the `docker-compose.yml` file:
In `docker-compose.yml` comment out line
```
- MYSQL_ALLOW_EMPTY_PASSWORD=yes
```
in section `services:db:environment`.

Then change empty string in the line above, and also the line in section `services:phpmyadmin:environment`
```
- MYSQL_ROOT_PASSWORD=[your password]
```
to your password. Note that you should not quoted your password string
##### 2. Modify the `./config/config.yml` correspondingly:
In `./config/config.yml`, under section `mysql:password`
```
password: [your password]
```
Modify it correspondingly.
#### Others
For the other configurations, please follow the comments in `./config/config.yml`.

## Running method:
#### Build and run full pipeline for the first time (or after killing all containers)
In the project's root directory, run command
```
docker-compose up -d --build --force-recreate
```
#### Run a part of pipeline again
Often, we want to run only a part of the pipeline with modified configurations.
##### 1. First change the configuration by editing the `./config/config.yml` YAML file.
For example, you only want to rerun `MLQ` again, then only turn on `MLQ` field in the `full_pipeline` section.
Also remember to change the `MLQ` related configurations.
##### 2. Re-start the full pipeline servies containers
By running command
```
docker-compose up -d
```
or
```
docker-compose up -d --build
```
(if there is some relevent code change in submodules)

Please do not turn on `--force-recreate` flag for re-running a part of pipeline.
#### Inspect the services
##### Inspect the stdout of each service
By running command
```
docker-compose logs [service name]
```
The service names include: `MLC`: `curated`, `MLQ`: `quantified`, `MLM`: `modeled`, `MLV`: `visualized`.
##### Inspect the resources usage of each service
By running command
```
docker stats
```
#### Stop a specific service
Sometimes, you want to stop a specific service which exposes too much information to the outside but you are not going to use it, (e.g. `MLV`).

You can stop it by running command:
```
docker-compose stop [service name]
```
and resume it by running command:
```
docker-compose start [service name]
```
#### Kill all the services
Caution: This will permanently remove the MOOCdb database. You have to run the full pipe again from raw data.
##### 1. In the project's root directory
Run command
```
docker-compose down
```
##### 2. You can check all relevant containers are killed and removed
By running command
```
docker ps -a
```
If not, you can kill and remove them separately by `docker kill [container_name]` and `docker rm [container_name]`
#### Inspect the `MOOCdb` database with `MySQL` only
##### 1. To attach to the db service container
Run command
```
docker exec -it mooclearnerdocker_db /bin/bash
```
##### 2. Log into the `MySQL` server
By running
```
mysql -uroot
```
(without password)
Then you can inspect the `MySQL` database `moocdb` as usual
##### 3 .Detach from the db service container
By simply typing `exit`
#### Inspect the `MOOCdb` database with `phpMyAdmin`
There is also a `phpMyAdmin` service running concurrently. To log in, visit `phpMyAdmin` on `http://[your server's ip]:8080`

Please leave the `Server` field empty and enter `root` in the `Username` filed and your password in the `Password` field. Note that `phpMyAdmin` is using the same set of login as the `MySQL` server. Press `Go` to browse the `MySQL` `MOOCdb` database.

`phpMyAdmin` is more user-friendly and easy-to-use. It also makes debugging with the `MOOCdb` database easier.

## Other Services
#### Running `VisMOOC-Docker`
Go into the folder `VisMOOC-Docker` and run command `docker-compose up -d` as usual. The services include `MLC`, `MOOCdb` and the complete set of services of `VisMOOC`. So you can also config `MLC` at `./moocdb_config/config.yaml`.

By starting all the services, you will have `VisMOOC` web server running on `http://[your server's ip]:9999`. As auxiliary tools for debugging, you will also have `phpMyAdmin` on port `8090` and `Mongo-Express` on `8091`.
#### Running another Parallel `MOOC-Learner-Docker`
You may want to run two `MOOC-Learner-Docker` pipelines at the same time, which can be done by running `docker-compose` under the folder `Second-Docker`. Or, if you have recursively cloned the MOOC-Learner-Docker repo to another machine, you'll notice that you now have `sample-docker-compose.yml` and `config/sample-config.yml` files, from which you can copy/modify to create an independent `docker-compose.yml` file and `config.yml` file.

Since there might be other docker containers running MOOC-Learner-Docker, you should change the `container_name`'s filed in `docker-compose.yml` to avoid naming conflict and also change the binding ports in `ports` fields if they are already currently being used. To check what docker containers are running, along with the container names and ports they are using, run:

```
docker ps
```

To change the `container_name`'s in `docker-compose.yml` you are essentially making the following name changes: `db` to `[some_prefix]_db`, `phpmyadmin` to `[some_prefix]_phpmyadmin`, `curated` to `[some_prefix]_curated` and so on... as well as specifying these new container names under each container's `depends_on` fields.

One final important note about changing the `db` container name: In order for the curated data to connect properly to the database, we must specify our new name for the `db` container in the `MOOC-Learner-Curated/Docker` file. Specifically, you need to change the hard-coded `db` value in the last line from:

```
CMD ["./wait_for_it.sh", "db", ...
```

to

```
CMD ["./wait_for_it.sh", "[some_prefix]_db", ...
```

Following this logic, you can run as many pipelines as you want simultaneously.

## Testing on Synthetic Data
To test `MOOC-Learner-Docker` without sensitive data. You can use the synthetic data generators in MLC. And run `MOOC-Learner-Docker` on it.

#### Simple Synthetic Data Generator
To run a simple synthetic data generator you can execute the bash command at any location since it recognize relative paths. At the root directory of `MOOC-Learner-Docker`, you can simply run
```
python MOOC-Learner-Curated/synthetic_generators/simple_synthetic_generator.py -o data
```
Then it will create a temporary data folder at `./data` with default course name `synthetic`.

#### Run `MOOC-Learner-Docker` on synthetic data
The default config files `config/config.yml` and `docker-compose.yml` are set up to run on synthetic data at default location directly.

So if you did not change them before, you can directly run the services by
```
docker-compose up -d --build
```

MLC is queued in the default pipeline config so after some time you can find a populated `moocdb` database in the `MySQL` container.

# Example of running on Synthetic Data


