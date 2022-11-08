require "glimmer-dsl-libui"

require "./lib/mixins/append_stretchy"

Glimmer::LibUI::ControlProxy::Box.module_eval { prepend ::Mixins::AppendStretchy }
