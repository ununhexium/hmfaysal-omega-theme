require 'cgi'
require 'open-uri'
require 'json'

GEO_CACHE_PATH = File.expand_path('../jekyll_geocache.json', __FILE__)
GEO_CACHE = JSON.parse(File.exist?(GEO_CACHE_PATH) ? File.read(GEO_CACHE_PATH) : '{}')

Jekyll::Hooks.register :posts, :pre_render do |post|

  data=post.data
  location = data['location'] rescue nil # unencode

  if location and location['name'] and ( not location['lat'] or not location['lon'])
    puts location.inspect
    loc = GEO_CACHE[location['name']]
    unless loc
      puts "geocoding... #{location['name']}"

      # get location from name
      url="http://maps.googleapis.com/maps/api/geocode/json?address=#{CGI.escape location['name']}&sensor=false"
      result = JSON.parse(open(url).read)
      loc = result['results'][0]['geometry']['location'] rescue 'none'

      # get the country from the location
      url = "http://maps.googleapis.com/maps/api/geocode/json?latlng=#{loc['lat']},#{loc['lng']}&sensor=false"
      result = JSON.parse(open(url).read)
      countries = result['results'][0]['address_components'].select{|x| x['types'].include? 'country'}
      unless countries.empty?
        countrycode = countries[0]['short_name']
        loc['countrycode'] = countrycode.downcase
      end

      GEO_CACHE[location['name']] = loc
      update_geo_cache!
    end
    data['location'].merge!(loc) if loc != 'none'
  end
end

def self.update_geo_cache!
  File.open(GEO_CACHE_PATH, 'w') { |f| f.write GEO_CACHE.to_json }
end

