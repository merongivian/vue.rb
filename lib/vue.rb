if RUBY_ENGINE == 'opal'
  require 'native'
  require 'vue/instance'
  require 'vue/component'
else
  require 'opal'

  Opal.append_path File.expand_path('../', __FILE__).untaint
end
