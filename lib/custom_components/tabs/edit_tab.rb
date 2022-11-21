require "glimmer-dsl-libui"

require "./lib/file_manager"

class EditTab
  include Glimmer::LibUI::CustomControl

  attr_reader :last_modified, :editing
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
              unless editing?
                @editing = true

                Glimmer::LibUI::timer(autosave_period, repeat: false) do
                  update_note
                  @editing = false
                end
              end
            }
          ]
        }
      }
    }
  }

  def open_note(workbook_name, note_name)
    @workbook = workbook_name
    @note = note_name

    self.file_contents = FM.get_note_contents(workbook_name, note_name)
  end

  def update_note
    FM.write_to_note(@workbook, @note, self.file_contents) if should_update_note?
  end

  private

  def should_update_note?
    !@workbook.nil? && !@note.nil?
  end

  def editing
    @editing ||= false
  end

  def editing?
    editing
  end
end
