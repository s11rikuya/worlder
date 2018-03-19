require_relative 'fetch_facebook_data.rb'
require_relative 'point_calculation.rb'

class History
  include GetFBData
  include PointCalculation
  attr_accessor :since_time, :until_time
  def initialize(access_token)
    @access_token = access_token
  end
end
