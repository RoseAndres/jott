require "glimmer-dsl-libui"

class JottApp
  include Glimmer

  attr_accessor :current_content
  attr_accessor :editing

  def initialize
    current_content = ""
    create_gui
  end

  def launch
    # TODO move this logic into a side-effect of loading a new file, or autoloading
    # TODO the last file edited before closing the app
    # save contents if user isn't in the process of changing
    Glimmer::LibUI::timer(15, repeat: has_content?) do
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

          }
        }
      }
  end

  def editing?
    editing
  end

  def has_content?
    !no_content?
  end

  def no_content?
    current_content.nil?
  end

  # TODO put actual saving logic here eventually
  def save_contents
    puts "saving current content"
    puts current_content
  end
end
