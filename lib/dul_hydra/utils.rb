module DulHydra::Utils
  def self.ds_internal_uri(obj, dsID)
    "#{obj.internal_uri}/datastreams/#{dsID}?asOfDateTime=#{ds_as_of_date_time(obj.datastreams[dsID])}" 
  end

  def self.ds_as_of_date_time(ds)
    ds.dsCreateDate.strftime("%Y-%m-%dT%H:%M:%S.%LZ")
  end
end
