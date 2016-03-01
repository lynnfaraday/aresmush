module AresMUSH
  module Pose_Order
    class PoseOrderCmd
      include Plugin
      include PluginRequiresLogin
      include PluginWithoutSwitches	
      
      def want_command?(client, cmd)
        cmd.root_is?("order") && cmd.switch.nil?
      end
      
      def handle
        time = Time.now.to_i
	error = t('order.no_order')
	title = t('order.order_title')
	# Check to see if po is nil.
	if Pose_Order.po.nil?
	  client.emit BorderedDisplay.text(error,title)
	# Check to see if the room pose order is nil	
	elsif Pose_Order.po[client.room.id].nil?
	  client.emit BorderedDisplay.text(error,title)
	else        
	  list = Pose_Order.po[client.room.id].sort_by { |k,v| v[:time] }.reverse
          order = list.map { |k,v| "#{k} (#{time_to_color(time - v[:time])})" }
	  client.emit BorderedDisplay.list(order,title)
        end
      end

      def time_to_color(time)
        if time < 300
            return t('order.hg', :time => time_display(time))
        elsif time < 900
            return t('order.g', :time => time_display(time))
        elsif time < 1200
            return t('order.hy', :time => time_display(time))
        elsif time < 1500
            return t('order.y', :time => time_display(time))
        elsif time < 2700
            return t('order.hr', :time => time_display(time))
        else 
            return t('order.r', :time => time_display(time))
	end 
      end
      
      def time_display(time)
        return TimeFormatter.format(time)
      end
      
    end
  end
end

