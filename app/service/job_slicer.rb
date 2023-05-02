require_relative '../../config/environment'

class JobSlicer
  # Fetches a slice (=partition) containing all relevant jobs for the current user
  # TODO: Implement using postgis
  def self.slice(user = nil, rad, lat, lng)
    # `user` could be used for logging or special slicing (categories etc.) ...
    if rad.nil?
      rad = 25000
    end
    if lat.nil? || lng.nil? || lat.abs > 90.0 || lng.abs > 180.0
      lat = 48.1374300
      lng = 11.5754900
    end
    # TODO: Add functionality that dynamically adapts rad according to the density of jobs in the area (to better consider differences between very densely populated urban areas and rural areas)
    res = SpatialJobValue.geo_query(lat, lng, rad, 500)

    if res.nil? || res.empty?
      res = Job.all.limit(100)
    end
    return res
  end

end
