#!/bin/bash
#
#	Author:		Jorge González
#
# 	Description:	Script para sacar los datos de redes sociales y de contacto de los diputados del congreso de España.
#
#	Version:	0.1
#
#	Modifications:	v0.1; first version.
#

TOTAL_DIPUTADOS=388
LEGISLATURA="XIV"
FICHERO="datos-personales-diputados.csv"

rm "${FICHERO}" 2>/dev/null

echo "ID_DIPUTADO;NOMBRE;PROVINCIA;GRUPO;TWITTER;FACEBOOK;CORREO" >> "${FICHERO}"

for ID_DIPUTADO in $(seq 1 ${TOTAL_DIPUTADOS}); do
	#Limpiar variables que puede que no existan
	TWITTER=""
	FACEBOOK=""
	CORREO=""

	URL="https://www.congreso.es/busqueda-de-diputados?p_p_id=diputadomodule&p_p_lifecycle=0&p_p_state=normal&p_p_mode=view&_diputadomodule_mostrarFicha=true&codParlamentario=${ID_DIPUTADO}&idLegislatura=${LEGISLATURA}&mostrarAgenda=false"

	TEMPORAL=$(wget -qO - "${URL}")

	NOMBRE=$(echo "${TEMPORAL}" | grep "nombre-dip" -A 1 | tail -n 1 | sed 's/\r$//' | sed -e 's/^[ \t]*//')
	PROVINCIA=$(echo "${TEMPORAL}" | grep "cargo-dip" -A 1 | tail -n 1 | sed 's/\r$//' | sed -e 's/^[ \t]*//')
	GRUPO=$(echo "${TEMPORAL}" | grep "grupo-dip" -A 3 | tail -n 1 | sed 's/\r$//' | sed -e 's/^[ \t]*//')
	TWITTER=$(echo "${TEMPORAL}" | grep -m 1 "twitter.com" | awk -F"=" '{print $2}' | awk '{print $1}' | tr -d "\"" | sed -e 's/^[ \t]*//')
	FACEBOOK=$(echo "${TEMPORAL}" | grep -m 1 "facebook.com" | awk -F"=" '{print $2}' | awk '{print $1}' | tr -d "\"" | sed -e 's/^[ \t]*//')
	CORREO=$(echo "${TEMPORAL}" | grep "mailto:" | awk -F"=" '{print $4}' | awk -F":" '{print $2}' | awk -F">" '{print $1}' | tr -d "\"" | sed -e 's/^[ \t]*//')

	if [[ "${TWITTER}" == "https://twitter.com/Congreso_Es" ]]; then
		TWITTER=""
	fi
	if [[ "${FACEBOOK}" == "https://www.facebook.com/CongresodelosDiputados" ]]; then
		FACEBOOK=""
	fi

	echo "${ID_DIPUTADO};${NOMBRE};${PROVINCIA};${GRUPO};${TWITTER};${FACEBOOK};${CORREO}" >> "${FICHERO}"
done
