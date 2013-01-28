module DulHydra::Utils

  def self.ds_as_of_date_time(ds)
    ds.dsCreateDate.strftime("%Y-%m-%dT%H:%M:%S.%LZ")
  end

end
