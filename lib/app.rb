require "glimmer-dsl-libui"

require "pry"
require "pry-byebug"
require "pry-doc"

require "./lib/custom_components/tabs/edit_tab"
require "./lib/custom_components/tabs/explore_tab"
require "./lib/custom_components/tabs/settings_tab"

require "./lib/util"

require_all("./lib/ext")

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
        resizable true

        tab {
          @edit_tab = edit_tab
          explore_tab(edit_tab: @edit_tab)
          settings_tab
        }
      }
  end
end
