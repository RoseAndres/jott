require "glimmer-dsl-libui"

class ExploreTab
  include Glimmer::LibUI::CustomControl

  options :autosave_period

  body {
    tab_item("Explore") {

    }
  }
end
