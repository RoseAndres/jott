require "glimmer-dsl-libui"

require "pry"
require "pry-byebug"
require "pry-doc"

require "./lib/custom_components/tabs/edit_tab"
require "./lib/custom_components/tabs/explore_tab"
require "./lib/custom_components/tabs/settings_tab"

require "./lib/ext/controls"

require "./lib/util"

class App
  include Glimmer

  def initialize
    create_gui
  end

  def launch
    @main_window.show
  end

  private

  def create_gui
    @main_window ||=
      window("Jott") {
        content_size 600, 400
        resizable false

        tab {
          edit_tab(
            autosave_period: 10,
            file_contents: "some default text"
          )
          explore_tab(config: {}, state: {})
          settings_tab
        }
      }
  end
end
