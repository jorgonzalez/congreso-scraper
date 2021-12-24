#!/bin/bash
#
#	Author:		Jorge González
#
# 	Description:	Script para sacar los datos de redes sociales y de contacto de los diputados del congreso de España.
#
#	Version:	0.2
#
#	Modifications:	v0.1; primera version.
#			v0.2; comentarios, quitar borrado de fichero de salida, mejora bucle de extraccion de datos.
#

LEGISLATURA="XIV"
FICHERO="datos-contacto-diputados.csv"

echo "ID_DIPUTADO;NOMBRE;PROVINCIA;GRUPO;TWITTER;FACEBOOK;CORREO" > "${FICHERO}"


ID_DIPUTADO=1
while [[ "${DIPUTADO_EXISTENTE}" != 1 ]]; do

	# Limpiar variables que puede que no existan
	TWITTER=""
	FACEBOOK=""
	CORREO=""

	# URL de cada diputado
	URL="https://www.congreso.es/busqueda-de-diputados?p_p_id=diputadomodule&p_p_lifecycle=0&p_p_state=normal&p_p_mode=view&_diputadomodule_mostrarFicha=true&codParlamentario=${ID_DIPUTADO}&idLegislatura=${LEGISLATURA}&mostrarAgenda=false"

	# Variable temporal
	TEMPORAL=$(wget -qO - "${URL}")

	# Variables de interes
	NOMBRE=$(echo "${TEMPORAL}" | grep "nombre-dip" -A 1 | tail -n 1 | sed 's/\r$//' | sed -e 's/^[ \t]*//')
	PROVINCIA=$(echo "${TEMPORAL}" | grep "cargo-dip" -A 1 | tail -n 1 | sed 's/\r$//' | sed -e 's/^[ \t]*//')
	GRUPO=$(echo "${TEMPORAL}" | grep "grupo-dip" -A 3 | tail -n 1 | sed 's/\r$//' | sed -e 's/^[ \t]*//')
	TWITTER=$(echo "${TEMPORAL}" | grep -m 1 "twitter.com" | awk -F"=" '{print $2}' | awk '{print $1}' | tr -d "\"" | sed -e 's/^[ \t]*//')
	FACEBOOK=$(echo "${TEMPORAL}" | grep -m 1 "facebook.com" | awk -F"=" '{print $2}' | awk '{print $1}' | tr -d "\"" | sed -e 's/^[ \t]*//')
	CORREO=$(echo "${TEMPORAL}" | grep "mailto:" | awk -F"=" '{print $4}' | awk -F":" '{print $2}' | awk -F">" '{print $1}' | tr -d "\"" | sed -e 's/^[ \t]*//')

	# Comprobacion de cuenta de twitter personal
	if [[ "${TWITTER}" == "https://twitter.com/Congreso_Es" ]]; then
		TWITTER=""
	fi
	# Comprobacion de cuenta de facebook personal
	if [[ "${FACEBOOK}" == "https://www.facebook.com/CongresodelosDiputados" ]]; then
		FACEBOOK=""
	fi

	echo "${ID_DIPUTADO};${NOMBRE};${PROVINCIA};${GRUPO};${TWITTER};${FACEBOOK};${CORREO}" >> "${FICHERO}"

	# Comprobacion de diputado existente
	DIPUTADO_EXISTENTE=$(echo "${TEMPORAL}" | grep "Se ha producido un error al obtener la información solicitada" | wc -l)

	# Incrementar ID_DIPUTADO
	let ID_DIPUTADO=${ID_DIPUTADO}+1
done
