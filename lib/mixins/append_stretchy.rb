require 'glimmer-dsl-libui'

module Mixins
  module AppendStretchy
    extend self

    def post_initialize_child(child)
      child.stretchy = @nest_stretchy if child.stretchy.nil?
      @nest_stretchy = true

      ::LibUI.box_append(
        @libui,
        child.libui,
        Glimmer::LibUI.boolean_to_integer(
          child.stretchy,
          allow_nil: false
        )
      )
      children << child
    end

    def create_child_control(keyword, args, add_stretchy: true, &block)
      @nest_stretchy = add_stretchy
      Glimmer::LibUI::ControlProxy.create(keyword, self, args, &block)
    end
  end
end


