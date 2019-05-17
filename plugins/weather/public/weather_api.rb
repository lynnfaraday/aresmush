module AresMUSH
  module Weather
    def self.is_enabled?
      !Global.plugin_manager.is_disabled?("weather")
    end

    def self.weather_for_area(area_name)
      Weather.load_weather_if_needed

      # Get the weather for the current area if there is one.
      if (Weather.current_weather.has_key?(area_name))
        weather = Weather.current_weather[area_name]
      else
        area = Area.find_one_by_name(area_name)
        if (area && area.parent)
          return Weather.weather_for_area(area.parent.name)
        end
        weather = Weather.current_weather["Default"]
      end

      # This handles the 'no weather' case, returning nil.
      return nil if !weather || weather.empty?
      climate = Weather.climate_for_area(area_name)
      season = ICTime.season(area_name)
      time_of_day = ICTime.time_of_day(area_name)
      temperature = weather[:temperature]
      condition = weather[:condition]

      # Use the weather name in the translation file - like weather.snow
      weather_desc = Global.read_config("weather", "descriptions_#{climate}", "#{temperature}_#{time_of_day}_#{condition}")
  end
end
