require "glimmer-dsl-libui"

class JottApp
  include Glimmer

  attr_accessor :current_content
  attr_accessor :editing
  attr_accessor :advanced_settings_enabled, :autosave_period, :workbook_path

  def initialize
    @current_content = ""
    @workbook_path = "/path/to/workbooks"
    @advanced_settings_enabled = false
    @autosave_period = 15
    create_gui
  end

  def launch
    # TODO move this logic into a side-effect of loading a new file, or autoloading
    # TODO the last file edited before closing the app
    # save contents if user isn't in the process of changing
    Glimmer::LibUI::timer(autosave_period, repeat: has_content?) do
      save_contents unless editing? || no_content?
    end

    @main_window.show
  end

  private

  def create_gui
    @main_window ||=
      window("Jätt", 400, 400) {
        tab {
          tab_item("Edit") {
            vertical_box {
              multiline_entry {
                text <=> [
                  self,
                  :current_content,
                  after_write: -> (_) {
                    editing = true
                    Glimmer::LibUI::timer(1, repeat: false) do
                      editing = false
                    end
                  }
                ]
              }
            }
          }
          tab_item("Explore") {

          }
          tab_item("Settings") {
            # TODO change to table to better align text with controls
            form {
              padded true

              entry {
                stretchy false

                label "Workbook Path"
                enabled <= [self, :advanced_settings_enabled]
                text <=> [self, :workbook_path]
              }

              spinbox(5, 60) {
                stretchy false

                label "Autosave Period (in seconds)"
                value <=> [self, :autosave_period]
              }

              checkbox {
                stretchy false

                label "Advanced Settings"
                text "Enabled"
                checked <=> [self, :advanced_settings_enabled]
              }
            }
          }
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
