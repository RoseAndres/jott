require "glimmer-dsl-libui"

class SettingsTab
  include Glimmer::LibUI::CustomControl

  option :advanced_settings_enabled, default: false
  option :autosave_period, default: 10
  option :workbook_path, default: "path/to/workbook/dir"

  body {
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
end
