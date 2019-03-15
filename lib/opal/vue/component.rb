class VueComponent < Vue
  class << self
    def inherited(sub_class)
      super

      sub_class.class_eval do
        @_props = []
        @_template = ''
        @_tag_name = ''

        class << self
          attr_reader :_props, :_template, :_tag_name

          def props(*the_props)
            @_props += the_props
          end

          def template(the_template)
            @_template = the_template
          end

          def tag_name(the_tag_name)
            @_tag_name = the_tag_name
          end
        end
      end
    end

    def activate
      new(data_as_function: true)
    end
  end

  def js_initialize
    `Vue.component(#{self.class._tag_name}, #{vue_options.to_n})`
  end

  def vue_options
    super.merge(
      {
        props: self.class._props,
        template: self.class._template
      }
    )
  end
end
