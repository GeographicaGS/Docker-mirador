Mirador docker image
=================================================


##What does this Docker image contains?

Compiled from source, this is what this image contains:

- PostgreSQL 9.1.2;
- PROJ 4.8.0;
- GEOS 3.3.2;
- PostGIS 1.5.3.
- GDAL 1.11.2

##Usage Pattern

Build the image directly from GitHub (this can take a while):
```
docker build -t="geographica/mirador" https://github.com/GeographicaGS/Docker-mirador.git
```

or pull it from Docker Hub:
```
    docker pull geographica/mirador
```

Create a folder in the host to contain the data storage. We like to persist the
data storage in the host and not in the container:

```
mkdir /whatever/pgsqldata
```

Then create a temporary container to create the data storage. In the container,
/data will be always the data storage:
```
docker run --rm -v /whatever/pgsqldata:/var/pgsql/data/ -t -i geographica/mirador /bin/bash

chown postgres:postgres /var/pgsql/data/

chmod 700 /var/pgsql/data

su postgres -c "initdb --encoding=UTF-8 --locale=es_ES.UTF-8 --lc-collate=es_ES.UTF-8 --lc-monetary=es_ES.UTF-8 --lcnumeric=es_ES.UTF-8 --lc-time=es_ES.UTF-8 -D /var/pgsql/data"
```

Now we can exit the temporary container and create a new one that will use this
data storage:

```
    docker run -i -t --name="mirador" -v /whatever/pgsqldata:/data/ -p 80:80 geographica/mirador
```
