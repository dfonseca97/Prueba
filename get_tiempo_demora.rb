#! usr/bin/env ruby

require 'firebase'
require 'httpclient'
require 'json'
 
# Accede a la base de datos con la información proporcionada desde la aplicación, en este caso la parada destino, retorna un String con 
# el tiempo aproximado de demora de un bus hasta esa parada. Esto se hace posible con un método de la Distance Matrix API de Google
# la cual requiere de las coordenadas de origen y de destino. Este algoritmo retorna un JSON con la información solicitada. Este JSON 
# se convierte en un Hash para poder recuperar el tiempo de demora. 
#
# @param parada [String] la parada destino del bus
# @param bus [String] el bus solicitado
# @return [String] tiempo estimado de llegada del bus a la parada solicitada.
def get_tiempo_demora(parada, bus)

	# URI de la base de datos del proyecto en Firebase.
	uri = 'https://prueba-2a1c3.firebaseio.com/'
	firebase = Firebase::Client.new(uri)

	#Coordenadas actuales del bus solicitado
	coordenada_x_origen = firebase.get('https://prueba-2a1c3.firebaseio.com/Buses/' + bus + '/coordenada_x').response.content
	coordenada_y_origen = firebase.get('https://prueba-2a1c3.firebaseio.com/Buses/' + bus + '/coordenada_y').response.content

	#Coordenadas de la parada actual
	coordenada_x_destino = firebase.get('https://prueba-2a1c3.firebaseio.com/Paradas/' + parada + '/coordenada_x').response.content
	coordenada_y_destino = firebase.get('https://prueba-2a1c3.firebaseio.com/Paradas/' + parada + '/coordenada_y').response.content

	#Definición del objeto HTTP para realizar la petición a la base de datos
	request = HTTPClient.new

	#Llamada al Distance Matrix API de Google
	response = request.get_content('https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=' + coordenada_x_origen.to_s() +
	 ',' + coordenada_y_origen.to_s() + '&destinations=' + coordenada_x_destino.to_s() +',
	' + coordenada_y_destino.to_s() + '&key=AIzaSyA-AXmZm4tiDLl0fs_AIjRstEme4IMGrjU')

	#Extracción de la información necesaria. En este caso el tiempo de demora
	time = JSON.parse(response)["rows"][0]["elements"][0]["duration"]["text"]
end

parada = gets.chomp
bus = gets.chomp

puts get_tiempo_demora(parada, bus)