class Deviceable

  module InstanceMethods

    def devices_sort_by_date
      self.devices.sort_by {|device| device[:date_created]}.reverse
    end

  end

end
