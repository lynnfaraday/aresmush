module AresMUSH
  module Custom
    class SpellLearnCmd
      #spell/learn <spell>
      include CommandHandler
      attr_accessor :spell, :spell_list, :school, :spell_level

      def parse_args
       self.spell = titlecase_arg(cmd.args)
       self.spell_level = Global.read_config("spells", self.spell, "level")
       self.school = Global.read_config("spells", self.spell, "school")
      end

      def check_errors
        return t('custom.not_spell') if !Custom.is_spell?(self.spell)
        return t('custom.need_previous_level') if Custom.previous_level_spell?(enactor, self.spell) == false

        major_school = enactor.major_school
        minor_school = enactor.minor_school
        if [enactor.major_school, enactor.minor_school].include? self.school
          return nil
        else
          return t('custom.wrong_school')
        end
        return nil
      end

      def handle
        client.emit self.school
        spell_learned = Custom.find_spell_learned(enactor, self.spell)
        if spell_learned
          #Gives time in days, if less than 24 hours left, it's learnable
          time_left = (Custom.time_to_next_learn_spell(spell_learned) / 86400)
          client.emit time_left
          if spell_learned.learning_complete
            client.emit_failure t('custom.already_know_spell', :spell => self.spell)
          elsif time_left > 0
            client.emit_failure t('custom.cant_learn_yet', :spell => self.spell, :days => time_left)
          else
            client.emit_success t('custom.additional_learning', :spell => self.spell)
            xp_needed = spell_learned.xp_needed.to_i - 1
            spell_learned.update(xp_needed: xp_needed)
            if xp_needed < 1
              spell_learned.update(learning_complete: true)
              client.emit_success t('custom.complete_learning', :spell => self.spell)
              message = t('custom.xp_learned_spell', :name => enactor.name, :spell => self.spell, :level => self.spell_level, :school => self.school)
              category = Jobs.system_category
              Jobs.create_job(category, t('custom.xp_learned_spell_title', :name => enactor.name, :spell => self.spell), message, Game.master.system_character)
            end
          end
        else
          xp_needed = Custom.spell_xp_needed(self.spell)
          SpellsLearned.create(name: self.spell, last_learned: Time.now, level: self.spell_level, school: self.school, character: enactor, xp_needed: xp_needed, learning_complete: false)
          client.emit_success t('custom.start_learning', :spell => self.spell)
        end

      end


      #     ability.learn
      #     if (ability.learning_complete)
      #       ability.update(xp: 0)
      #       FS3Skills.set_ability(client, char, name, ability.rating + 1)
            # message = t('fs3skills.xp_raised_job', :name => char.name, :ability => name, :rating => ability.rating + 1)
            # category = Jobs.system_category
            # Jobs.create_job(category, t('fs3skills.xp_job_title', :name => char.name), message, Game.master.system_character)
      #     else
      #       client.emit_success t('fs3skills.xp_spent', :name => name)
      #     end
      #
      #     if (FS3Skills.skill_requires_training(ability))
      #       client.emit_ooc t('fs3skills.skill_requires_training', :name => name)
      #     end
      #   end
      # end


    end
  end
end
