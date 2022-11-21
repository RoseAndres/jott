require "glimmer-dsl-libui"

require "./lib/file_manager"

class EditTab
  include Glimmer::LibUI::CustomControl

  attr_reader :last_modified
  attr_accessor :file_contents

  FM = FileManager.instance

  option :autosave_period, default: 10

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

  def open_note(workbook_name, note_name)
    self.file_contents = FM.get_note_contents(workbook_name, note_name)
  end

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
    # TODO: write note contents to file
  end
end
