module AresMUSH
  module Custom
    class SpellCastCmd
    #spell/cast <spell>
      include CommandHandler
      attr_accessor :name, :weapon_name, :spell, :spell_list, :weapon,  :weapon_type, :caster, :caster_combat
      def parse_args
       self.spell_list = Global.read_config("spells")
       if (cmd.args =~ /\//)
         #Forcing NPC or PC to cast
         args = cmd.parse_args(/(?<arg1>[^\/]+)\/(?<arg2>[^\+]+)/)
         combat = enactor.combat
         caster_name = titlecase_arg(args.arg1)
         #Returns char or NPC
         self.caster = FS3Combat.find_named_thing(caster_name, enactor)
         #Returns combatant
         self.caster_combat = combat.find_combatant(caster_name)
         self.spell = titlecase_arg(args.arg2)
       else
          args = cmd.parse_args(/(?<arg1>[^\+]+)\+?(?<arg2>.+)?/)
          #Returns char or NPC
          self.caster = enactor
          #Returns combatant
          self.caster_combat = enactor.combatant
          self.spell = titlecase_arg(args.arg1)

        end
      end

      def check_errors
        return t('custom.not_spell') if !self.spell_list.include?(self.spell)
        return t('custom.cant_force_cast') if (self.caster != enactor && !enactor.combatant)
        if caster_combat.is_npc?
          return nil
        else
          return t('custom.dont_know_spell') if Custom.knows_spell?(caster, self.spell) == false
        end
        require_target = Global.read_config("spells", self.spell, "require_target")
        return t('custom.needs_target') if require_target
        return nil
      end

      def handle
      #Reading Config Files

        weapon = Global.read_config("spells", self.spell, "weapon")
        weapon_specials = Global.read_config("spells", self.spell, "weapon_specials")
        armor = Global.read_config("spells", self.spell, "armor")
        armor_specials = Global.read_config("spells", self.spell, "armor_specials")
        is_stun = Global.read_config("spells", self.spell, "is_stun")
        roll = Global.read_config("spells", self.spell, "roll")
        heal_points = Global.read_config("spells", self.spell, "heal_points")
        is_revive = Global.read_config("spells", self.spell, "is_revive")
        lethal_mod = Global.read_config("spells", self.spell, "lethal_mod")
        attack_mod = Global.read_config("spells", self.spell, "attack_mod")
        defense_mod = Global.read_config("spells", self.spell, "defense_mod")
        spell_mod = Global.read_config("spells", self.spell, "spell_mod")
        stance = Global.read_config("spells", self.spell, "stance")
        school = Global.read_config("spells", self.spell, "school")


        if self.enactor.combatant
          if self.caster_combat.is_ko
            client.emit_failure t('custom.spell_ko')
          elsif Custom.already_cast(self.caster_combat) == true
            client.emit_failure t('custom.already_cast')
          else

            #Roll Spell in Combat
            if roll == true
              Custom.cast_roll_spell(self.caster_combat, self.spell)
            end

            #Equip Weapon
            if weapon
              Custom.cast_equip_weapon(enactor, self.caster_combat, self.spell)
            end

            #Equip Weapon Specials
            if weapon_specials
              Custom.cast_equip_weapon_specials(self.caster_combat, self.spell)
            end

            #Equip Armor
            if armor
              Custom.cast_equip_armor(self.caster_combat, self.spell)
            end

            #Equip Armor Specials
            if armor_specials
              Custom.cast_equip_armor_specials(self.caster_combat, self.spell)
            end

            #Stun
            if is_stun
              Custom.cast_stun_spell(enactor, self.caster_combat, self.spell)
            end

          end
        self.caster_combat.update(has_cast: true)
        elsif
          #Roll NonCombat
          if roll
            Custom.cast_noncombat_spell(self.caster, self.spell)
          else
            client.emit_failure t('custom.not_in_combat')
          end

        end


      end

    end
  end
end
