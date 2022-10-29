require "glimmer-dsl-libui"

class EditTab
  include Glimmer::LibUI::CustomControl

  attr_reader :last_modified

  option :autosave_period, default: 10
  option :file_contents, default: "some text"

  body {
    tab_item("Edit") {
      vertical_box {
        multiline_entry {
          text <=> [
            self,
            :file_contents,
            after_write: -> {
              self.last_modified = Time.now.to_i
            }
          ]
        }
      }
    }
  }

  private

  def last_modified=(new_value)
    @last_modified = new_value
    # puts "modified at #{last_modified}"

    Glimmer::LibUI::timer(autosave_period, repeat: false) do
      # puts "#{@last_modified} - #{Time.now.to_i}"
      save_contents if Time.now.to_i - @last_modified >= autosave_period
    end
  end

  def save_contents
    # save logic
    # puts "save"
  end
end
