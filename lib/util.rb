require "glimmer-dsl-libui"

def main_window
  Glimmer::LibUI::ControlProxy.main_window_proxy
end

def all_controls
  Glimmer::LibUI::ControlProxy.control_proxies
end
