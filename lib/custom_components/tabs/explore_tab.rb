require "fileutils"
require "glimmer-dsl-libui"

require "./lib/custom_components/vertical_spacer"
require "./lib/ext/string"

class ExploreTab
  include Glimmer::LibUI::CustomControl

  attr_accessor :workbook_entry_text, :create_button_enabled

  DEFAULT_BUTTON_TEXT = "Create new workbook"

  option :config
  option :state

  body {
    tab_item("Explore") {
      vertical_box {
        vertical_box {
          stretchy false

          horizontal_box {
            entry {
              stretchy true

              text <=> [self, :workbook_entry_text,
                after_write: -> {
                  update_button
                }
              ]
            }
            @create_button = button(DEFAULT_BUTTON_TEXT) {
              stretchy true

              enabled false

              on_clicked do |button|
                add_workbook(@workbook_entry_text)
                self.workbook_entry_text = ""
                update_button
              end
            }
          }
        }

        @workbook_labels = vertical_box {
          stretchy true

          label("first") {
            stretchy false
          }
          horizontal_separator {
            stretchy false
          }

          vertical_spacer
        }
      }
    }
  }

  def update_button
    text_present = @workbook_entry_text.present?
    @create_button.text =
      if text_present
        "#{DEFAULT_BUTTON_TEXT} \"#{@workbook_entry_text}\""
      else
        DEFAULT_BUTTON_TEXT
      end
    @create_button.enabled = @workbook_entry_text.present?
  end

  def workbooks
    @workbooks ||= load_workbooks
  end

  def add_workbook(workbook_name)
    @workbook_labels.children.last.destroy

    label = @workbook_labels.create_child_control(:label, workbook_name, add_stretchy: false)
    separator = @workbook_labels.create_child_control(:horizontal_separator, nil, add_stretchy: false)

    @workbook_labels.content { vertical_spacer }
  end

  def load_workbooks
    ["First"]
  end
end
