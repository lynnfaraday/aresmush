module AresMUSH
  module Roles
    class RoleAddCmd
      include CommandHandler
      include CommandRequiresLogin
      include CommandRequiresArgs
      
      attr_accessor :name
      attr_accessor :role
      
      def initialize(client, cmd, enactor)
        self.required_args = ['name', 'role']
        self.help_topic = 'role'
        super
      end
      
      def crack!
        cmd.crack_args!(CommonCracks.arg1_equals_arg2)
        self.name = trim_input(cmd.args.arg1)
        self.role = trim_input(cmd.args.arg2)
      end

      def check_can_assign_role
        return t('dispatcher.not_allowed') if !Roles.can_assign_role?(enactor)
        return t('roles.role_restricted', :name => Game.master.master_admin.name) if (Roles.is_restricted?(self.role) && !enactor.is_master_admin?)
        return nil
      end
      
      def check_role_exists
        return t('roles.role_does_not_exist') if !Roles.valid_role?(self.role)
        return nil
      end
      
      def handle        
        ClassTargetFinder.with_a_character(self.name, client) do |char|
          if (!char.has_role?(self.role))     
            Global.logger.info "#{enactor_name} added role #{self.role} to #{self.name}."     
            char.roles << self.role.downcase
            char.save!
          end
          client.emit_success t('roles.role_assigned', :name => self.name, :role => self.role)
          Global.dispatcher.queue_event RolesChangedEvent.new(char)
        end
      end
    end
  end
end
