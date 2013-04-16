require 'httparty'
require 'rubygems'
require 'json'
require 'iconv'

states = JSON.parse Iconv.iconv('utf-8', 'iso8859-1', HTTParty.get('http://aplicaciones4.sct.gob.mx/sibuac_internet/SerEscogeRuta?estados').body).join
  
data = {
	states: {},
	items: {}
}

states.each do |state|

	name = state['nombre']
	data[:states][state['id']] = name

	items = JSON.parse Iconv.iconv('utf-8', 'iso8859-1', HTTParty.get("http://aplicaciones4.sct.gob.mx/sibuac_internet/SerEscogeRuta?idEstado=#{state['id']}")).join, :symbolize_names => true

	items.each {|item|
		data[:items][item[:id]] = {
			state: item[:idEdo],
			coordinates: [item[:coordenadaX], item[:coordenadaY]],
			name: item[:nombre]
		}
	}

	File.open("cache.json", 'w') { |file| file.write(data.to_json) }

end