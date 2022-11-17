require "fileutils"
require "glimmer-dsl-libui"
require "opt_struct"

require "./lib/custom_components/horizontal_spacer"
require "./lib/custom_components/vertical_spacer"

require "./lib/ext/string"

class ExploreTab
  include Glimmer::LibUI::CustomControl

  attr_accessor :workbook_entry_text, :note_entry_text, :notes

  DEFAULT_BUTTON_TEXT = "Create new workbook"
  DEFAULT_RT_FILTER = Glimmer::LibUI::CustomControl::RefinedTable::FILTER_DEFAULT

  BOOKS_AND_NOTES = {
    first: %w(apples bananas),
    second: %w(grapes cherries oranges),
    third: %w(blueberries)
  }

  Workbook = OptStruct.new do
    required :name
    options :notes, delete: "X", open: false

    init { options[:notes] = [] }

    def toggle_open
      options[:open] = !options[:open]
    end
  end

  Note = OptStruct.new do
    required :name
  end

  body {
    tab_item("Explore") {
      horizontal_box {
        horizontal_spacer {}
        @workbook_panel = vertical_box {
          stretchy true

          vertical_box {
            @workbook_table = refined_table(
              model_array: workbooks,
              table_columns: {
                "Name" => {
                  button: {
                    on_clicked: -> (row_index) do
                      select_workbook(@workbook_table.refined_model_array[row_index])
                    end
                  }
                },
                "Open" => :checkbox,
                "Delete" => {
                  button: {
                    on_clicked: -> (row_index) do
                      puts workbooks.delete_at(row_index)
                    end
                  }
                },
              },
              table_editable: false,
              filter: -> (row_hash, query) do
                DEFAULT_RT_FILTER.call(row_hash, query).tap do |result|
                  unless result
                    @selected_workbook.toggle_open
                    @selected_workbook = nil
                  end
                end
              end
            )
          }
          vertical_box {
            stretchy false

            horizontal_box {
              entry {
                stretchy true

                text <=> [self, :workbook_entry_text,
                  after_write: -> {
                    @create_workbook_button.enabled = workbook_entry_text.present?
                  }
                ]
              }
              @create_workbook_button = button("New Workbook") {
                stretchy true

                enabled false

                on_clicked do |button|
                  create_new_workbook(workbook_entry_text)

                  self.workbook_entry_text = ""
                  button.enabled = false
                end
              }
            }
          }
        }
        @notes_panel = vertical_box {
          stretchy true

          vertical_box {
            @notes_table = refined_table(
              model_array: notes,
              table_columns: {
                "Name" => {
                  button: {
                    on_clicked: -> (row_index) do
                      # TODO fix this to work with index
                      @selected_note = @notes_table.refined_model_array[row_index]
                      puts @selected_note
                    end
                  }
                }
              },
              table_editable: false
            ) {
              stretchy false
            }
          }
          vertical_box {
            stretchy false

            horizontal_box {
              entry {
                stretchy true

                text <=> [self, :note_entry_text,
                  after_write: -> {
                    @create_note_button.enabled = note_entry_text.present?
                  }
                ]
              }
              @create_note_button = button("New Note") {
                stretchy true

                enabled false

                on_clicked do |button|
                  create_new_note(note_entry_text)

                  self.note_entry_text = ""
                  button.enabled = false
                end
              }
            }
          }
        }
      }
    }
  }

  private

  def create_new_workbook(name)
    workbooks << Workbook.new(name: name)
  end

  def create_new_note(name)
    @selected_workbook.notes << Note.new(name: name)
    update_notes_list
  end

  def select_workbook(workbook)
    @selected_workbook&.toggle_open

    if @selected_workbook != workbook
      workbook.open = true
      @selected_workbook = workbook
    end

    update_notes_list
  end

  def update_notes_list
    notes.clear
    notes.add_all(@selected_workbook.notes.dup)
  end

  def workbooks
    @workbooks ||= load_workbooks
  end

  def init_notes
    @notes = @selected_workbook.notes.dup

    class << notes
      def add_all(collection)
        collection.each do |e|
          self << e
        end
      end
    end
  end

  def load_workbooks
    # TODO: load from db
    [].tap do |arr|
      BOOKS_AND_NOTES.each do |wb_name, note_names|
        arr << Workbook.new(name: wb_name).tap do |wb|
          note_names.each { |name| wb.notes << Note.new(name: name) }
        end
      end
    end.tap do |arr|
      @selected_workbook = arr.first
      @selected_workbook.open = true

      init_notes
    end
  end
end
