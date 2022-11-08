require "glimmer-dsl-libui"

# vertical spacer.
# MUST BE INSIDE ANOTHER BOX
class VerticalSpacer
  include Glimmer::LibUI::CustomControl

  body {
    vertical_box {
      stretchy true
    }
  }
end
