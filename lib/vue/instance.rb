module Native
  module Helpers
    def native_prop_accessor(*names)
      native_prop_reader(*names)
      native_writer(*names)
    end

    def native_prop_reader(*names)
      names.each do |name|
        define_method name do
          # this is only needed when accessing it from component hooks,
          # which are instanciated inside the beforeCreate hook. It feels
          # very wrong of course, instantiating hooks inside another hook
          %x{
            var propValue;

            try {
              propValue = #@native[#{name}];
            }
            catch(error) {
              propValue = #@native.$options.propsData[#{name}];
            }
          }

          Native(`propValue`)
        end
      end
    end
  end
end

class Vue
  include Native

  class << self
    def inherited(sub_class)
      sub_class.class_eval do
        @_root_class = ::Vue
        @_data = {}
        @_components = []
        @_props = []
        @_created = -> {}
        @_mounted = -> {}
        @_destroyed = -> {}
        @_watchers = {}
        @_method_mode = :public
        @_methods = []
        @_computed = []

        class << self
          attr_reader :_props, :_created, :_mounted, :_destroyed, :_watchers, :_components

          def data(the_name, the_value)
            @_data.merge!({ the_name => the_value })

            _ignore_method_added { native_accessor(the_name) }
          end

          def components(*the_components)
            @_components = the_components
          end

          def props(*the_props)
            @_props += the_props

            _ignore_method_added do
              the_props.each(&method(:native_prop_accessor))
            end
          end

          def method_added(name)
            super

            return if @_data.keys.include?(name)

            if @_method_mode == :public
              @_methods << name
            elsif @_method_mode == :computed
              @_computed << name
            end
          end

          def _ignore_method_added
            save_method_mode = @_method_mode
            @_method_mode = :ignore
            yield
          ensure
            @_method_mode = save_method_mode
          end

          def computed
            @_method_mode = :computed
          end

          def private
            @_method_mode = :private
          end

          def created(&block)
            @_created = block
          end

          def mounted(&block)
            @_mounted = block
          end

          def destroyed(&block)
            @_destroyed = block
          end

          def watch(data_name, &block)
            raise "data #{data_name} is not defined" unless @_data.include?(data_name)

            @_watchers.merge!({ data_name => block })
          end

          def _methods
            _inject_ancestor(@_methods.dup) do |s, cls|
              s << cls._methods
            end
          end

          def _computed
            _inject_ancestor(@_computed.dup) do |s, cls|
              s << cls._computed
            end
          end

          def _data
            _inject_ancestor(@_data.dup) do |s, cls|
              s.merge(cls._data)
            end
          end

          # accumulates s in all ancestors until it gets to
          # the root_class, this is usefull when creating
          # instances or components that inherits from
          # sub-(instances/components). It also prevents from
          # adding methods added in the base vue classes
          def _inject_ancestor(initial)
            ancestors.inject(initial) do |s, cls|
              break s if cls == @_root_class
              next s if cls == self
              next s unless cls.is_a?(Class)

              yield(s, cls)
            end
          end

          def _vue_options
            {
              data: _data.to_n,
              props: _props
            }
          end
        end
      end
    end
  end

  def initialize(element = nil, js_object: nil)
    @native = js_object || `new Vue(#{vue_options.to_n})`

    element && mount(element)

    define_lifecycle_callbacks
    define_watchers
  end

  def mount(element)
    `#{@native}.$mount(element)`
  end

  def emit(*args)
    # using js apply because is the only way to pass array as arguments
    @native.JS['$emit'].JS.apply(@native, args.map(&:to_n))
  end

  def vue_options
    self.class._vue_options.merge(
      {
        methods: methods_as_procs(:public),
        computed: methods_as_procs(:computed),
        components: create_components.to_n
      }
    )
  end

  def define_lifecycle_callbacks
    @native.JS[:$created] = instance_eval(&self.class._created)
    @native.JS[:$mounted] = instance_eval(&self.class._mounted)
    @native.JS[:$destroyed] = instance_eval(&self.class._destroyed)
  end

  def define_watchers
    self.class._watchers.each_with_object({}) do |(data_name, watcher), watchers_hash|
      # had to bind it with instance_exec, but since watch expects a function
      # then its wrapped in a lambda
      `#@native.$watch(#{data_name}, #{ -> (*args) { instance_exec *args, &watcher } })`
    end
  end

  def methods_as_procs(methods_type = :public)
    methods_names = if methods_type == :public
      self.class._methods
    elsif methods_type == :computed
      self.class._computed
    end

    methods_names.each_with_object({}) do |method_name, methods_hash|
      methods_hash[method_name] = method(method_name).to_proc
    end
  end

  def create_components
    self.class._components.each_with_object({}) do |component_class, components_hash|
      components_hash[component_class._tag_name] = component_class.to_h
    end
  end
end
