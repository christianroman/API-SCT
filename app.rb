require 'httparty'
require 'rubygems'
require 'json' 
require 'sinatra'
require 'builder'
require 'nokogiri'
require 'open-uri'

ENDPOINT = 'http://aplicaciones4.sct.gob.mx/sibuac_internet/ControllerUI'

post '/rutas' do

	COMBUSTIBLE = 11.25
	RENDIMIENTO = 14.00

	json = File.open('data.json', 'r')
	data = JSON.parse json.read, :symbolize_names => true

	#params = JSON.parse(request.env["rack.input"].read)
	params = JSON.parse request.body.read

	ciudadOrigen = params["ciudad_origen"]
	ciudadDestino = params["ciudad_destino"]

	ciudadOrigen = ciudadOrigen.ljust(4, '0')
	ciudadDestino = ciudadDestino.ljust(4, '0')

	estadoOrigen = data[:puntos][:"#{ciudadOrigen}"][:estado]
  	estadoDestino = data[:puntos][:"#{ciudadDestino}"][:estado]

  	vehiculos = params["vehiculos"] ? params["vehiculos"] : 2
  	calculaRendimiento = params["calcula_rendimiento"] ? params["calcula_rendimiento"] == 'true' ? 'si' : nil : nil
  	tamanioVehiculo = params["tamanio_vehiculo"] ? params["tamanio_vehiculo"] : 2
  	rendimiento = params["rendimiento"] ? params["rendimiento"] : RENDIMIENTO
  	combustible = params["combustible"] ? params["combustible"] : COMBUSTIBLE

  	zonasUrbanas = params["zonas_urbanas"] ? params["zonas_urbanas"] == 'true' ? true : false : false

	query = {
		action: 'cmdSolRutas',
		tipo: 1,
		red: 'simplificada',
		edoOrigen: estadoOrigen,
		ciudadOrigen: ciudadOrigen,
		edoDestino: estadoDestino,
		ciudadDestino: ciudadDestino,
		vehiculos: vehiculos,
		calculaRendimiento: calculaRendimiento,
		tamanioVehiculo: tamanioVehiculo,
		rendimiento: rendimiento,
		combustible: combustible
	}

	respuesta = HTTParty.get(ENDPOINT, :query => query).body

	html = Nokogiri::HTML(respuesta)

	tramos = []
	puntos = []

	html.css('input[name=destino]')[0].attr('value').split('&').each do |punto|

		inicio, inicio_x, inicio_y, fin, fin_x, fin_y, inicio_tipo, fin_tipo, tipo_punto = punto.split('#')

		puntos.push({
			inicio: {
				nombre: inicio,
				lat: inicio_x,
				lng: inicio_y,
				tipo: inicio_tipo
			},
	    	fin: {
	    		nombre: fin,
	    		lat: fin_x,
	    		lng: fin_y,
	    		tipo: fin_tipo
	    	},
	    	tipo: tipo_punto
  		})

	end

	trs = html.css('#tContenido tr')

	distanciaTotal = 0.0
	tiempoTotal = 0
	peajeTotal = 0.0
	combustibleTotal = 0.0
	costoTotal = 0.0

	trs[2..trs.count-5].each do |tr|

		tramo = {}
		next unless tr.content.strip != ''

		nbsp = Nokogiri::HTML('&nbsp;').text

		if tr.at_css('td').text.strip == 'Totales'
			if calculaRendimiento
				combustibleTotal += tr.next.next.css('td')[4].text.gsub(nbsp, ' ').strip.to_f
			end
			costoTotal = peajeTotal + combustibleTotal
			break
		end

		nombre = tr.css('td')[0].text.gsub(nbsp, ' ').strip
		estado = tr.css('td')[1].text.gsub(nbsp, ' ').strip
		carretera = tr.css('td')[2].text.gsub(nbsp, ' ').strip

		if !zonasUrbanas
			next unless carretera != 'Zona Urbana'
		end

		longitud = tr.css('td')[3].text.gsub(nbsp, ' ').strip
		distanciaTotal += longitud.to_f

		tiempo = tr.css('td')[4].text.gsub(nbsp, ' ').strip
		horas, minutos = tiempo.split(':')
		tiempoTotal += horas.to_i * 60 + minutos.to_i

		caseta = tr.css('td')[5].text.gsub(nbsp, ' ').strip
		costo = tr.css('td')[6].text.gsub(nbsp, ' ').strip
		peajeTotal += costo.to_f

		tramo['nombre'] = nombre
		tramo['estado'] = estado
		tramo['carretera'] = carretera
		tramo['longitud'] = longitud
		tramo['tiempo'] = tiempo
		tramo['caseta'] = caseta
		tramo['costo'] = costo
	  	tramos.push(tramo)

	end

	response = {
	  tramos: tramos,
	  puntos: puntos,
	  distancia: distanciaTotal,
	  tiempo: tiempoTotal,
	  peaje: peajeTotal,
	  combustible: combustibleTotal,
	  costo: costoTotal
	}

	response.to_json

end