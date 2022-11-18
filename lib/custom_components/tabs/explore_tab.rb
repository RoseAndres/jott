require "glimmer-dsl-libui"
require "opt_struct"

require "./lib/custom_components/confirm_window"
require "./lib/custom_components/horizontal_spacer"
require "./lib/custom_components/vertical_spacer"

require "./lib/file_manager"

require "./lib/ext/string"

class ExploreTab
  include Glimmer::LibUI::CustomControl

  attr_accessor :workbook_entry_text, :note_entry_text, :note_rows

  FM = FileManager.instance

  DEFAULT_BUTTON_TEXT = "Create new workbook"
  DEFAULT_RT_FILTER = Glimmer::LibUI::CustomControl::RefinedTable::FILTER_DEFAULT

  BOOKS_AND_NOTES = {
    first: %w(apples bananas),
    second: %w(grapes cherries oranges),
    third: %w(blueberries)
  }

  TableRow = OptStruct.new do
    required :name
    options :child_rows, delete: "X", open: false

    init { options[:child_rows] = [] }

    def toggle_open
      options[:open] = !options[:open]
    end
  end

  body {
    tab_item("Explore") {
      horizontal_box {
        @workbook_panel = vertical_box {
          stretchy true

          vertical_box {
            @workbook_table = refined_table(
              model_array: workbook_rows,
              table_columns: {
                "Name" => {
                  button: {
                    on_clicked: -> (row_index) do
                      select_workbook_row(row_index)
                    end
                  }
                },
                "Open" => :checkbox,
                "Delete" => {
                  button: {
                    on_clicked: -> (row_index) do
                      confirm_window(
                        action_description: "delete workbook \"#{get_workbook(row_index).name}\"",
                        on_confirm: -> {
                          delete_workbook(row_index)
                        }
                      ).show
                    end
                  }
                },
              },
              table_editable: false,
              filter: -> (row_hash, query) do
                DEFAULT_RT_FILTER.call(row_hash, query).tap do |result|
                  unless result
                    @selected_workbook_row&.toggle_open
                    @selected_workbook_row = nil
                    update_note_rows
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
              model_array: note_rows,
              table_columns: {
                "Name" => {
                  button: {
                    on_clicked: -> (row_index) do
                      select_note_row(@notes_table.refined_model_array[row_index])
                    end
                  }
                },
                "Open" => :checkbox,
                "Delete" => {
                  button: {
                    on_clicked: -> (row_index) do
                      confirm_window(
                        action_description: "delete note \"#{get_note(row_index).name}\"",
                        on_confirm: -> {
                          delete_note(row_index)
                        }
                      ).show
                    end
                  }
                },
              },
              table_editable: false,
              filter: -> (row_hash, query) do
                DEFAULT_RT_FILTER.call(row_hash, query).tap do |result|
                  unless result
                    @selected_note_row.toggle_open
                    @select_note_row = nil
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

  def get_workbook(index)
    @workbook_table.refined_model_array[index]
  end

  def get_note(index)
    @notes_table.refined_model_array[index]
  end

  def delete_workbook(index)
    workbook_row = @workbook_table.refined_model_array.delete_at(index)
    if @selected_workbook_row == workbook_row
      @selected_workbook_row = nil
    end

    workbook_rows.delete(workbook_row)
    @workbook_panel.hide
    @workbook_panel.show

    update_note_rows
  end

  def delete_note(index)
    note_row = @notes_table.refined_model_array.delete_at(index)
    if @select_note_row == note_row
      @select_note_row = nil
    end

    note_rows.delete(note_row)
  end

  def create_new_workbook(name)
    FM.create_new_workbook(name)

    workbook_rows << TableRow.new(name: name)
  end

  def create_new_note(name)
    FM.create_new_note(@selected_workbook_row.name, name)

    @selected_workbook_row.child_rows << name
    update_note_rows
  end

  def select_workbook_row(index)
    workbook_row = @workbook_table.refined_model_array[index]

    @selected_workbook_row&.toggle_open

    if @selected_workbook_row != workbook_row
      workbook_row.open = true
      @selected_workbook_row = workbook_row
    end

    update_note_rows
  end

  def select_note_row(note_row)
    @select_note_row&.toggle_open

    if @select_note_row != note_row
      note_row.open = true
      @selected_note_row = note_row
    end
  end

  def update_note_rows
    note_rows.clear.add_all(
      @selected_workbook_row&.child_rows&.map do |note_name|
        TableRow.new(name: note_name)
      end
    )
  end

  def workbook_rows
    @workbook_rows ||= load_workbooks
  end

  def note_rows
    @note_rows ||= [].tap do |arr|
      class << arr
        def add_all(collection)
          collection&.each do |e|
            self << e
          end
        end
      end
    end
  end

  def load_workbooks
    [].tap do |arr|
      workbook_names = FM.get_all_workbooks.map { |p| File.basename(p) }

      workbook_names.each do |wb_name|
        arr << TableRow.new(name: wb_name).tap do |wb|
          note_names = FM.get_all_notes_for_workbook(wb_name).map { |p| File.basename(p, ".*") }
          binding.pry

          note_names.each do |note_name|
            wb.child_rows << note_name
          end
        end
      end
    end
  end
end
