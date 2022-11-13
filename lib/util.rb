require "glimmer-dsl-libui"

def main_window
  Glimmer::LibUI::ControlProxy.main_window_proxy
end

def all_controls
  Glimmer::LibUI::ControlProxy.control_proxies
end

def require_all(path)
  Dir.glob(File.expand_path("#{path}/*.rb", __FILE__)).each do |file|
    require file
  end
end
