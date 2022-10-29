require "glimmer-dsl-libui"

require "./lib/custom_components/tabs/edit_tab"
require "./lib/custom_components/tabs/explore_tab"
require "./lib/custom_components/tabs/settings_tab"

class App
  include Glimmer


  attr_accessor :editing
  attr_accessor :advanced_settings_enabled, :autosave_period, :workbook_path

  def initialize
    create_gui
  end

  def launch
    # TODO move this logic into a side-effect of loading a new file, or autoloading
    # TODO the last file edited before closing the app
    # save contents if user isn't in the process of changing
    # Glimmer::LibUI::timer(autosave_period, repeat: has_content?) do
    #   save_contents unless editing? || no_content?
    # end

    @main_window.show
  end

  private

  def create_gui
    @main_window ||=
      window("Jätt", 400, 400) {
        tab {
          edit_tab(
            autosave_period: 10,
            file_contents: "some default text"
          )
          explore_tab
          settings_tab
        }
      }
  end

  def editing?
    editing
  end

  def advanced_settings_disabled?
    !advanced_settings_enabled?
  end

  def advanced_settings_enabled?
    advanced_settings_enabled
  end

  def has_content?
    !no_content?
  end

  def no_content?
    current_content.nil?
  end

  # TODO put actual saving logic here eventually
  def save_contents
    # save logic
  end
end
