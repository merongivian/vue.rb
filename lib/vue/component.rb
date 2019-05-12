class VueComponent < Vue
  class << self
    def inherited(sub_class)
      super

      sub_class.class_eval do
        @_root_class = ::VueComponent
        @_template = ''
        @_tag_name = ''

        class << self
          attr_reader :_template, :_tag_name

          def template(the_template)
            @_template = the_template
          end

          def tag_name(the_tag_name)
            @_tag_name = the_tag_name
          end

          def _vue_options
            super.merge(
              {
                template: _template,
                data: -> { _data.to_n }
              }
            )
          end
        end
      end
    end

    def activate
      initializer = -> (vue) { new(vue) }

      options = _vue_options.to_n

      # NOTE: this was taken exactly as the way was done here: https://github.com/arika/opal-vue-trial/blob/master/app/vue.rb.
      # This is the only way to bind methods and computed methods with VueComponent, so it
      # can access data. Im not really sure why this works
      %x{
        options['beforeCreate'] = function() {
          initializer(this);
        };

        Vue.component(#{_tag_name}, #{options});
      }
    end
  end

  def initialize(vue)
    super(js_object: vue).tap do
      %x{
        vue.$options['methods'] = #{methods_as_procs(:public).to_n};
        vue.$options['computed'] = #{methods_as_procs(:computed).to_n};
      }
    end
  end
end
