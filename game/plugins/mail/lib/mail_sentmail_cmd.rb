module AresMUSH
  module Mail
    class MailSentMailCmd
      include CommandHandler
      include CommandRequiresLogin
      include CommandRequiresArgs
      
      attr_accessor :option
      
      def initialize(client, cmd, enactor)
        self.required_args = ['option']
        self.help_topic = 'mail'
        super
      end
      
      def crack!
        self.option = OnOffOption.new(cmd.args)
      end
      
      def check_option
        return self.option.validate
      end      
      
      def handle        
        enactor.copy_sent_mail = self.option.is_on?
        enactor.save
        if (self.option.is_on?)
          client.emit_ooc t('mail.sentmail_on')
        else
          client.emit_ooc t('mail.sentmail_off')
        end
      end
    end
  end
end
