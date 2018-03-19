module GetFBData
  require 'pp'
  def gets_data(since_time, until_time)
    @since_time = Time.parse(since_time)
    @until_time = Time.parse(until_time)
    graph = Koala::Facebook::API.new(@access_token)
    graph_result = graph.get_connection('me', 'posts',since: @since_time, until: @until_time, fields: %w(place created_time) )
    @results = graph_result.to_a
    until (next_results = graph_result.next_page).nil?
      @results += next_results.to_a
      graph_result = next_results
    end
    @results.select do |di|
      !di['place'].nil?
    end.map do |di|
      di['place']['name'] = 'NO NAME' if di['place']['name'] == ''
      {
        'time' => di['created_time'],
        'name' => di['place']['name'],
        'lat' => di['place']['location']['latitude'],
        'lng' => di['place']['location']['longitude']
      }
    end
  end
end
