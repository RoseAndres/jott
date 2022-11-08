require "glimmer-dsl-libui"

# horizontal spacer.
# MUST BE INSIDE ANOTHER BOX
class HorizontalSpacer
  include Glimmer::LibUI::CustomControl

  body {
    horizontal_box {
      stretchy true
    }
  }
end
