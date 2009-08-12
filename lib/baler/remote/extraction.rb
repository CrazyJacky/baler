module Baler
  module Remote
    class Extraction
      attr_accessor :attribute, :use_context, :block
      attr_reader :path
      
      DEFAULT_BLOCK = Proc.new{|elements| elements.inner_html}

      def initialize(path = nil, attribute = nil, block = nil, use_context = true)
        self.path = path || ''
        @attribute = attribute
        @block = block || DEFAULT_BLOCK
        @use_context = use_context
      end
      
      def path=(path)
        @path = path.squeeze(' ').strip
      end

      alias use_context? use_context
      
      def value(document, instance, index = nil)
        elements = elements(document, index)
        value = block_value(elements, instance)

        if value.is_a? Parser::Element::Array
          value = value.length <= 1 ? value.first : value.to_array
        end
        
        if value.is_a? Parser::Element::Abstract
          value = value.inner_html
        end

        value
      end

      protected
        def block_value(elements, instance)
          unless elements.empty?
            case @block.arity
            when 1: @block.call(elements)
            when 2: @block.call(elements, instance)
            else    nil
            end
          end
        end

        def elements(document, index = nil)
          use_context? ?
            document.relative_elements_for(@path, index) :
            document.absolute_elements_for(@path)
        end
    end
  end
end
