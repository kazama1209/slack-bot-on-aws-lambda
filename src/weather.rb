require 'json'

class Weather
  def current_temp(locate)
    end_point_url = 'http://api.openweathermap.org/data/2.5/weather'
    api_key = ENV['OPEN_WEATHER_API']

    res = Faraday.get(end_point_url + "?q=#{locate},jp&APPID=#{api_key}")
    res_body = JSON.parse(res.body)

    temp = res_body['main']['temp']
    celsius = temp - 273.15
    celsius_round = celsius.round

    return "現在の練馬の気温は#{celsius_round.to_s}℃です。"
  end
end
