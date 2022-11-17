require "glimmer-dsl-libui"

# Confirmation modal/window
class ConfirmWindow
  include Glimmer::LibUI::CustomControl

  option :action_description
  option :confirm_with
  option :cancel_with
  option :on_confirm

  body {
    window("Confirm") {
      vertical_box {
        vertical_box {
          stretchy true

          vertical_spacer
          label(message_text) {}
          vertical_spacer
        }
        horizontal_box {
          button(cancel_text) {
            on_clicked do
              self.destroy
            end
          }
          horizontal_spacer
          button(confirm_text) {
            on_clicked do
              on_confirm.call
              self.destroy
            end
          }
        }
      }
    }
  }

  private

  def confirm_text
    @confirm_text ||= confirm_with || "Confirm"
  end

  def cancel_text
    @cancel_text ||= confirm_with || "Cancel"
  end

  def message_text
    @message_text ||= "Are you sure you want to #{action_description}?" || "Are you sure?"
  end
end
