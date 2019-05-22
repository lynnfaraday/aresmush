module AresMUSH
  module SuperConsole
    class SheetTemplate < ErbTemplateRenderer

      attr_accessor :char

      def initialize(char, client)
        @char = char
        super File.dirname(__FILE__) + "/sheet.erb"
      end
# --------------------------------------------
# General Sheet Items
      def game_name
        Global.read_config("game","name")
      end
# --------------------------------------------

# --------------------------------------------
# Sheet Info Section


      def approval_status
        Chargen.approval_status(@char)
      end
      def char_class
        @char.group("class") || "Unknown"
      end
      def profession
        @char.group("profession") || "Unknown"
      end
      def race
        @char.group("race") || "Unknown"
      end
      def age
        age = @char.age
        age == 0 ? "--" : age
      end
      def level
        @char.console_level
      end
      def oversoul_type
        type = @char.console_oversoul_type
        if type == nil
          "Unknown"
        else
          type
        end
      end
      def guild
        "Unknown"
      end
      def level_cleared
        "0"
      end
# --------------------------------------------
# --------------------------------------------
# Sheet Attribute Section

# --------------------------------------------
      def attrs
       list = []
        @char.console_attributes.sort_by(:name, :order => "ALPHA").each_with_index do |a, i|
          list << format_attr(a, i)
        end
        list
      end


      def format_attr(a, i)
        name = "%xh#{a.name}:%xn"
        linebreak = i % 3 == 1 ? "" : "%r"
        bigger = i % 3 == 1 ? 13 : 14
        rating_text = "#{a.rating_name}"
        rating = "#{a.rating}"
        "#{linebreak}#{left(name, bigger)} #{left(rating_text,12)}"
      end

    end
  end
end