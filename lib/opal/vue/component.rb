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
      new
    end
  end

  def initialize
    initializer = -> (vue) { super(js_object: vue) }

    options = vue_options.to_n

    # NOTE: this was taken exactly as the way was done here: https://github.com/arika/opal-vue-trial/blob/master/app/vue.rb.
    # This is the only way to bind methods and computed methods with VueComponent, so it
    # can access data. Im not really sure why this works
    %x{
      options['beforeCreate'] = function() {
        initializer(this);

        this.$options['methods'] = #{methods_as_procs(:public).to_n}
        this.$options['computed'] = #{methods_as_procs(:computed).to_n}
      };

      Vue.component(#{self.class._tag_name}, #{options});
    }
  end

  def vue_options
    super.merge(
      {
        props: self.class._props,
        template: self.class._template,
        methods: {},
        computed: {},
        data: -> { self.class._data.to_n }
      }
    )
  end
end
