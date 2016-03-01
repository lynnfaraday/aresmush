module AresMUSH
  module Pose_Order
    class OrderClearCmd
      include Plugin
      include PluginRequiresLogin
      
      def want_command?(client, cmd)
        cmd.root_is?("order") && cmd.switch_is?("clear")
      end
      
      def handle
	char = client.char
	room = char.room	
	if Pose_Order.po.nil? || Pose_Order.po[room.id].nil?
	  client.emit_ooc t('order.no_order_to_clear', :room => char.room.name)
	else
	  # Clears the pose order for the room.
	  Pose_Order.po.delete(room.id)
	  # Emit to the room that the order has been cleared.
	  char.room.emit_ooc t('order.cleared', :name => char.name)
	end
      end
    end
  end
end

