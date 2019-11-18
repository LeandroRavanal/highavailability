## High Availability

Hoy día tener un esquema de alta disponibilidad en nuestros servicios es esencial. Pensemos en una aplicación 24x7, Qué pasaría si se cae un servidor a altas horas de la noche? O, si necesitamos realizar una actualización? Sería óptimo que otra instancia comience a responder los pedidos sin necesidad de nuestra intervención.

Para permitir un crecimiento horizontal, desde un punto de vista arquitectónico, nuestros servicios deberían estar detrás de un balanceador de carga y cómo primer punto de alta disponibilidad, deberíamos tener dos balanceadores en esquema activo/pasivo, para que si el activo deja de estar disponible, el pasivo comience a responder los pedidos en estado activo. Por otro lado, el balanceador activo será el encargado de direccionar los pedidos entre los servidores disponibles.

Hay varios ejemplos en Internet con esta configuración, pero no encontré ninguno usando Apache2 & Keepalived. La idea de este ejercicio es crear una imagen con Apache2 para realizar el balanceo de carga como proxy reverso y Keepalived para administrar la IP virtual de entrada, y por tanto, el estado activo/pasivo de los contenedores.

Para el ejercicio, creé una simple API Rest usando SpringBoot que devuelve la fecha y hora actual del servidor, estas instancias estarán conectadas al balanceador.  

El ejercicio se encaró en Windows usando Docker con la salvedad que Docker para Windows corre sobre una VM y no permite usar la red host.

Los pasos a seguir son: crear una red, construir las imagenes del balanceador y de la API Rest, y ejecutar dos contenedores de cada imagen como se muestra a continuación.

```
docker network create ha-network --driver=bridge --subnet 192.168.1.0/24 --ip-range=192.168.1.0/24 --gateway 192.168.1.254

mvn clean package

docker build --tag app_service --build-arg JAR_FILE=target/highavailability-0.0.1-SNAPSHOT.jar --file dockerfiles/app_service/Dockerfile .

docker run --name app_service_1 --ip 192.168.1.20 --net=ha-network --detach app_service:latest

docker run --name app_service_2 --ip 192.168.1.21 --net=ha-network --detach app_service:latest

docker build --tag apache2_keepalived --file dockerfiles/apache2_keepalived/Dockerfile .

docker run --name apache2_keepalived_1 --ip 192.168.1.10 --env APACHE2_BALANCER_MEMBER_IPS="#PYTHON2BASH:['192.168.1.20', '192.168.1.21']" --env KEEPALIVED_VIRTUAL_IPS="#PYTHON2BASH:['192.168.1.1']" --env KEEPALIVED_UNICAST_PEERS="#PYTHON2BASH:['192.168.1.10', '192.168.1.11']" --cap-add=NET_ADMIN --cap-add=NET_BROADCAST --cap-add=NET_RAW --net=ha-network --detach apache2_keepalived:latest

docker run --name apache2_keepalived_2 --ip 192.168.1.11 --env APACHE2_BALANCER_MEMBER_IPS="#PYTHON2BASH:['192.168.1.20', '192.168.1.21']" --env KEEPALIVED_VIRTUAL_IPS="#PYTHON2BASH:['192.168.1.1']" --env KEEPALIVED_UNICAST_PEERS="#PYTHON2BASH:['192.168.1.10', '192.168.1.11']" --cap-add=NET_ADMIN --cap-add=NET_BROADCAST --cap-add=NET_RAW --net=ha-network --detach apache2_keepalived:latest
```

Como comentamos anteriormente en Windows no podemos usar la red host, por tanto, para poder visualizar nuestro ejercicio desde un navegador debemos usar el siguiente workaround.

Obtener la IP del host de Docker:

```
docker run --net=host --pid=host -it --privileged --rm alpine /bin/sh -c "ip addr show hvint0 | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b'"
-> 10.0.75.2
```

Agregar una regla de ruteo en Windows hacia la IP virtual compartida por nuestros balanceadores.

```
route add 192.168.1.1 mask 255.255.255.255 10.0.75.2 -p
```

Finalmente si ingresamos a http://192.168.1.1 vamos a visualizar la fecha y hora del servidor y si nos ponemos a jugar con los contenedores, bajando y subiendo de a uno, podemos probar que el servicio está disponible en todo momento (obviamente si bajamos ambos balanceadores y / o ambos servidores Rest esto no sucederá).


### Docker Compose

Los pasos asociados a la creación de la red, imagenes y contenedores los ensamblé en un compose usando la versión 2.x. De esta manera reducimos la ejecución de comandos por consola quedando solo la compilación y empaquetado del servicio Rest.

```
mvn clean package

docker-compose up
```

### Fuente

El ejercicio actual está basado en el proyecto https://github.com/osixia/docker-keepalived usando Docker & ShellScript y agregando Apache2.
