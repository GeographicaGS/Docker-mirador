# Version: 0.0.1
FROM ubuntu:latest

MAINTAINER Alberto Asuero "alberto.asuero@geographica.gs"

RUN apt-get update && apt-get install -y build-essential gcc-4.7 python python-dev libreadline6-dev zlib1g-dev libssl-dev libxml2-dev libxslt-dev wget

RUN ["mkdir", "-p", "/usr/local/src/"]

# Build Proj4
WORKDIR /usr/local/src/
RUN ["wget","http://download.osgeo.org/proj/proj-4.8.0.tar.gz"]
RUN ["tar","xvzf","proj-4.8.0.tar.gz"]
WORKDIR /usr/local/src/proj-4.8.0
RUN ./configure CC='gcc-4.7 -m64' && make && make install

# Build GEOSS
WORKDIR /usr/local/src/
RUN ["wget","http://download.osgeo.org/geos/geos-3.3.2.tar.bz2"]
RUN ["tar","xvjf","geos-3.3.2.tar.bz2"]
WORKDIR /usr/local/src/geos-3.3.2
RUN ./configure CC='gcc-4.7 -m64' && make && make install

# Build PostgreSQL 9.1.2
RUN apt-get install -y flex bison
WORKDIR /usr/local/src/
RUN ["wget","https://ftp.postgresql.org/pub/source/v9.1.2/postgresql-9.1.2.tar.bz2"]
RUN ["tar","xvjf","postgresql-9.1.2.tar.bz2"]
WORKDIR postgresql-9.1.2
RUN ./configure --with-python  CC='gcc-4.7 -m64'
RUN make && make install 
WORKDIR contrib
RUN make all && make install

ENV POSTGRES_PASSWD postgres
RUN groupadd postgres
RUN useradd -r postgres -g postgres
RUN echo "postgres:${POSTGRES_PASSWD}" | chpasswd -e

RUN echo 'export PATH=$PATH:/usr/local/pgsql/bin/' >> /etc/profile

ADD data/environment /etc/environment
ADD data/postgresql-9.1.2 /etc/init.d/postgresql-9.1.2
RUN chmod +x /etc/init.d/postgresql-9.1.2
RUN mkdir -p /var/log/postgresql-9.1.2/ && chown postgres:postgres /var/log/postgresql-9.1.2/
RUN mkdir /home/postgres && chown postgres:postgres /home/postgres

RUN locale-gen en_US.UTF-8
RUN locale-gen es_ES.UTF-8

# Build GDAL
WORKDIR /usr/local/src/
RUN ["wget","http://download.osgeo.org/gdal/1.11.2/gdal-1.11.2.tar.gz"]
RUN ["tar","xvxf","gdal-1.11.2.tar.gz"]
WORKDIR gdal-1.11.2
RUN ./configure --with-pg=/usr/local/pgsql/bin/pg_config CC='gcc-4.7 -m64' && make && make install

# Build PostGIS-1.5.3
WORKDIR /usr/local/src/
RUN ["wget","http://postgis.refractions.net/download/postgis-1.5.3.tar.gz"]
RUN ["tar","xvxf","postgis-1.5.3.tar.gz"]
WORKDIR postgis-1.5.3
RUN ./configure --with-pgconfig=/usr/local/pgsql/bin/pg_config CC='gcc-4.7 -m64' && make && make install

# Install apache
RUN apt-get -y install apache2 php5 libapache2-mod-php5 php5-pgsql

# Postinstallation clean
WORKDIR /usr/local/
RUN rm -Rf src

ADD data/000-default.conf /etc/apache2/sites-available/000-default.conf
ADD data/php.ini /etc/php5/apache2/php.ini 

RUN apt-get -y install vim

# Configuration of database
RUN locale-gen en_US.UTF-8
RUN locale-gen es_ES.UTF-8

ADD scripts /scripts
RUN chmod +x /scripts/*

EXPOSE 80

CMD /scripts/start.sh












