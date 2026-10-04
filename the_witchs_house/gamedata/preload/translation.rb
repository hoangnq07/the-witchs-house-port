# encoding: utf-8
# ==============================================================================
# The Witch's House (Majo no Ie) - Vietnamese Translation Mod for mkxp-z / ArkOS
# Adapted from 37TEAM / AowVN Vietnamese Localization
# ==============================================================================

# 1. Load pure Ruby dictionary (no JSON dependency)
dict_file = File.expand_path('twh_dict.rb', File.dirname(__FILE__)) rescue nil
if dict_file && File.exist?(dict_file)
  load dict_file
elsif File.exist?('preload/twh_dict.rb')
  load 'preload/twh_dict.rb'
end

# 2. Translation Engine
module WitchHouseTranslation
  def self.translate(text)
    return text if text.nil? || !text.is_a?(String) || text.empty?
    return text if text !~ /[a-zA-Z]/ # Skip if no latin characters (e.g. control codes only)

    # 1. Exact match
    return TEXTS[text] if defined?(TEXTS) && TEXTS && TEXTS.key?(text)

    # 2. Trimmed match
    stripped = text.strip
    if defined?(TEXTS) && TEXTS && TEXTS.key?(stripped)
      leading = text[/\A\s*/]
      trailing = text[/\s*\z/]
      return "#{leading}#{TEXTS[stripped]}#{trailing}"
    end

    # 3. Clean control codes (\c[n], \., \|, \!, \^, \>, \<, \s[n], \size[n], etc.)
    clean = stripped.gsub(/\\[a-zA-Z]+(\[[^\]]*\])?/, '').gsub(/\\[.\|!^><_]/, '').strip
    if defined?(TEXTS) && TEXTS && TEXTS.key?(clean)
      return TEXTS[clean]
    end

    # 4. Handle curly vs straight apostrophes
    if stripped.include?("’")
      norm = stripped.gsub("’", "'")
      return TEXTS[norm] if defined?(TEXTS) && TEXTS && TEXTS.key?(norm)
    elsif stripped.include?("'")
      norm = stripped.gsub("'", "’")
      return TEXTS[norm] if defined?(TEXTS) && TEXTS && TEXTS.key?(norm)
    end

    text
  end

  def self.translate_items(items)
    return unless items && defined?(ITEMS_NAME)
    items.each_with_index do |item, id|
      next unless item
      if ITEMS_NAME.key?(id)
        item.name = ITEMS_NAME[id]
      end
      if defined?(ITEMS_DESC) && ITEMS_DESC.key?(id)
        item.description = ITEMS_DESC[id]
      end
    end
  end

  def self.install_hooks
    return if @hooks_installed
    @hooks_installed = true

    # Suppress verbose warnings during patching
    old_verbose = $VERBOSE
    $VERBOSE = nil

    # 1. Stub Bitmap#save_png to prevent Zlib NameError crash on save
    if defined?(Bitmap)
      Bitmap.class_eval do
        def save_png(*args)
          true
        end
      end
    end

    # 2. Translate Vocab
    if defined?(Vocab)
      Vocab.module_eval do
        def self.new_game; "Bắt Đầu"; end
        def self.continue; "Tiếp Tục"; end
        def self.shutdown; "Thoát"; end
        def self.to_title; "Màn Hình Chính"; end
        def self.cancel; "Hủy"; end
        def self.item; "Vật Phẩm"; end
        def self.save; "Lưu Game"; end
        def self.game_end; "Thoát Game"; end
      end
      Vocab.const_set(:SaveMessage, "Chọn hồ sơ để lưu game.")
      Vocab.const_set(:LoadMessage, "Chọn hồ sơ để tải game.")
      Vocab.const_set(:File, "Hồ Sơ")
    end

    # 3. Hook Window_Command to automatically translate commands in any menu
    if defined?(Window_Command)
      Window_Command.class_eval do
        alias twh_orig_initialize initialize unless method_defined?(:twh_orig_initialize)
        def initialize(width, commands, column_max = 1, row_max = 0, spacing = 32)
          if commands.is_a?(Array)
            commands = commands.map { |c| WitchHouseTranslation.translate(c) }
          end
          twh_orig_initialize(width, commands, column_max, row_max, spacing)
        end
      end
    end

    # 4. Hook Window_Help to translate help messages
    if defined?(Window_Help)
      Window_Help.class_eval do
        alias twh_orig_set_text set_text unless method_defined?(:twh_orig_set_text)
        def set_text(text, align = 0)
          text = WitchHouseTranslation.translate(text) if text.is_a?(String)
          twh_orig_set_text(text, align)
        end
      end
    end
    if defined?(Window_HelpI)
      Window_HelpI.class_eval do
        alias twh_orig_set_text set_text unless method_defined?(:twh_orig_set_text)
        def set_text(text, align = 0)
          text = WitchHouseTranslation.translate(text) if text.is_a?(String)
          twh_orig_set_text(text, align)
        end
      end
    end

    # 5. Hook Window_SaveFile to translate map names on save screen
    if defined?(Window_SaveFile)
      Window_SaveFile.class_eval do
        alias twh_orig_map_name map_name if method_defined?(:map_name) && !method_defined?(:twh_orig_map_name)
        def map_name
          m = (@game_system && @game_system.save_data && @game_system.save_data[:map]) || ""
          WitchHouseTranslation.translate(m)
        end
      end
    end

    # 6. Translate items in database if already loaded
    if defined?($data_items) && $data_items
      translate_items($data_items)
    end

    # 7. Hook Window_Message to translate dialogue & choices and ensure UTF-8 slicing
    if defined?(Window_Message)
      Window_Message.class_eval do
        alias twh_orig_start_message start_message unless method_defined?(:twh_orig_start_message)
        def start_message
          if $game_message && $game_message.texts && !$game_message.texts.empty?
            # Ensure UTF-8 on incoming lines
            $game_message.texts.map! { |line| line.respond_to?(:force_encoding) ? line.force_encoding("UTF-8") : line }

            c_start = $game_message.choice_start || 99
            if c_start < $game_message.texts.size
              msg_lines = $game_message.texts[0...c_start]
              choice_lines = $game_message.texts[c_start..-1]

              if !msg_lines.empty?
                joined = msg_lines.join("\n")
                tr = WitchHouseTranslation.translate(joined)
                if tr != joined
                  msg_lines = tr.split("\n")
                else
                  msg_lines = msg_lines.map { |l| WitchHouseTranslation.translate(l) }
                end
              end

              choice_lines = choice_lines.map { |c| WitchHouseTranslation.translate(c) }

              $game_message.choice_start = msg_lines.size
              $game_message.texts = (msg_lines + choice_lines).map { |l| l.to_s.split("\n") }.flatten
            else
              joined = $game_message.texts.join("\n")
              tr = WitchHouseTranslation.translate(joined)
              if tr != joined
                $game_message.texts = tr.split("\n")
              else
                $game_message.texts = $game_message.texts.map { |l| WitchHouseTranslation.translate(l) }
              end
              $game_message.texts = $game_message.texts.map { |l| l.to_s.split("\n") }.flatten
            end
          end
          twh_orig_start_message
          @text.force_encoding("UTF-8") if @text.respond_to?(:force_encoding)
        end

        # Hook update_message to slice complete UTF-8 codepoints (prevents broken bytes turning into dots)
        alias twh_orig_update_message update_message unless method_defined?(:twh_orig_update_message)
        def update_message
          @wait_count = @type_wait || 0
          @text.force_encoding("UTF-8") if @text.respond_to?(:force_encoding)
          loop do
            c = @text.slice!(/./um) # /./um forces complete UTF-8 character slice!
            case update_message_type(c)
            when 1
              break
            when 2
              next
            end
            break unless @show_fast or @line_show_fast
          end
        end
      end
    end

    # 8. Hook Game_Interpreter setup_choices for choices translation
    if defined?(Game_Interpreter)
      Game_Interpreter.class_eval do
        alias twh_orig_setup_choices setup_choices unless method_defined?(:twh_orig_setup_choices)
        def setup_choices(params)
          if params && params[0].is_a?(Array)
            params[0] = params[0].map { |c| WitchHouseTranslation.translate(c) }
          end
          twh_orig_setup_choices(params)
        end
      end
    end

    # 8b. Hook Game_Choices and Window_Choice for Script 104 (●選択肢拡張)
    if defined?(Game_Choices)
      Game_Choices.class_eval do
        alias twh_orig_create_free_choices create_free_choices unless method_defined?(:twh_orig_create_free_choices)
        def create_free_choices(text)
          old_size = @choices.size
          twh_orig_create_free_choices(text)
          (old_size...@choices.size).each do |idx|
            @choices[idx] = WitchHouseTranslation.translate(@choices[idx])
          end
        end
      end
    end

    if defined?(Window_Choice)
      Window_Choice.class_eval do
        alias twh_orig_choise_width choise_width unless method_defined?(:twh_orig_choise_width)
        def choise_width
          if @choice && @choice.choices
            @choice.choices.map! { |c| WitchHouseTranslation.translate(c) }
          end
          twh_orig_choise_width
        end

        alias twh_orig_draw_item draw_item unless method_defined?(:twh_orig_draw_item)
        def draw_item(index)
          if @choice && @choice.choices
            @choice.choices.map! { |c| WitchHouseTranslation.translate(c) }
          end
          twh_orig_draw_item(index)
        end
      end
    end

    if defined?(Window_Pickup)
      Window_Pickup.class_eval do
        alias twh_orig_draw_item draw_item unless method_defined?(:twh_orig_draw_item)
        def draw_item(index, y)
          if @choice_window && @choice_window.choice && @choice_window.choice.choices
            @choice_window.choice.choices.map! { |c| WitchHouseTranslation.translate(c) }
          end
          twh_orig_draw_item(index, y)
        end
      end
    end


    # 9. Disable Resize.dll
    if defined?(Resize)
      Resize.module_eval do
        def self.init; end
        def self.toggle; end
        def self.get; 0; end
        def self.set(size); end
      end
    end
    if defined?(Config)
      Config.const_set(:RESIZE_ENABLE, false)
    end

    # 10. Ensure Vietnamese Font is active across all Window classes
    if defined?(Font)
      Font.default_name = ["VL PGothic", "VL Gothic"]
      Font.default_size = 20
    end
    if defined?(PARA_FONT_CUSTOM)
      PARA_FONT_CUSTOM.const_set(:FONT_NAME, ["VL PGothic", "VL Gothic"])
    end
    if defined?(Window_Base)
      Window_Base.class_eval do
        Font.default_name = ["VL PGothic", "VL Gothic"]
      end
    end

    # Restore verbose warnings
    $VERBOSE = old_verbose
  end
end

# 3. Hook Kernel.load_data to translate $data_items whenever loaded
module Kernel
  alias twh_orig_load_data load_data unless method_defined?(:twh_orig_load_data)
  def load_data(filename)
    data = twh_orig_load_data(filename)
    if filename.to_s =~ /Items/i && data.is_a?(Array)
      WitchHouseTranslation.translate_items(data)
    end
    data
  end
end

# 4. Hook Graphics.freeze and Graphics.update to install hooks when game starts
module Graphics
  class << self
    alias twh_orig_freeze freeze unless method_defined?(:twh_orig_freeze)
    def freeze(*args)
      WitchHouseTranslation.install_hooks
      twh_orig_freeze(*args)
    end

    alias twh_orig_update update unless method_defined?(:twh_orig_update)
    def update(*args)
      WitchHouseTranslation.install_hooks
      twh_orig_update(*args)
    end
  end
end

# 5. Set default font early
if defined?(Font)
  Font.default_name = ["VL PGothic", "VL Gothic"]
  Font.default_size = 20
end
