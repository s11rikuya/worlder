module PointCalculation
  require 'json'
  require 'open-uri'

  DISTANCE_API = 'http://vldb.gsi.go.jp/sokuchi/surveycalc/surveycalc/bl2st_calc.pl?'.freeze

  def distance(lat1, lng1, lat2, lng2)
    req_params = {
      outputType: 'json',    # 出力タイプ
      ellipsoid:  'bessel',  # 楕円体
      latitude1:  lat1,      # 出発点緯度
      longitude1: lng1,      # 出発点経度
      latitude2:  lat2,      # 到着点緯度
      longitude2: lng2       # 到着点経度
    }
    req_param = req_params.map { |k, v| "#{k}=#{v}" }.join('&')
    result = JSON.parse(open(DISTANCE_API + req_param).read)
    result['OutputData']['geoLength']
  end

  def calculation(range_indexes)
    distanes = []
    range_indexes.each_cons(2) do |a, b|
      c = distance(a["lat"], a["lng"], b["lat"], b["lng"])
      c = c.to_i
      distanes.push(c)
    end

    sum_distance = distanes.inject(:+) / 1000
    return sum_distance
  end
end
