# Vue.rb

Lets you write Vue.js code in Ruby!!!

```ruby
class ReverseMessage < Vue
  data :message, "Reverse this message"

  def reverse_message
    self.message = message.reverse
  end
end

ReverseMessage.new('#app')
```

```html
<div id="app">
  <p>{{ message }}</p>
  <button v-on:click="reverse_message">Reverse Message</button>
</div>
```

## Installation (Ruby on Rails)

Install `vue.js` through yarn
```
$ yarn add vue
```
Add the following gems in your Gemfile

```ruby
  gem 'opal-rails'
  gem 'vue.rb', git: 'https://github.com/merongivian/vue.rb'
```

and run `bundle exec install`

Require both Javascript and Ruby files in `application.js.rb`
```ruby
# Javascript to Ruby compiler
require 'opal'

# require javascript before ruby code
require 'vue/dist/vue.js'
require 'vue.rb'
```

## Adding Vue code

Make sure your vue code loads after the page is loaded
```ruby
# config/initializers/assets.rb

Rails.application.config.assets.precompile += %w(my_vue_code.js.rb) # should be in app/assets/javascripts
```
```html
<!-- application.html.erb -->

<!DOCTYPE html>
<html>
  <head>...</head>

  <body>
    <%= yield %>
  </body>

  <%= javascript_include_tag 'my_vue_code' %>
</html>
```

## More examples

check the [examples section](https://github.com/merongivian/vue.rb/tree/master/examples)

## Credits

This code is mostly a copy of [arika's example](https://github.com/arika/opal-vue-trial). I just merely refactor
it a bit and put it into a gem :blush:

## Contributing

This is not a complete implementation of the API, so if something is missing please do help with PR's
