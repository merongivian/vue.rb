class SimpleMessage < Vue
  data :message, 'Hello from vue opal'

  created do
    puts "simple message created with message: #{message}"
  end
end

class DateTitle < Vue
  data :message, "You loaded this on #{Date.today}"
end

class Hidden < Vue
  data :seen, true
end

class TodoList < Vue
  data :todos, [ {text: 'learn opal'}, {text: 'Learn Vue'}, {text: 'Just Build something'} ]
end

class ReverseMessage < Vue
  data :message, "Reverse this message"

  def reverse_message
    self.message = message.reverse
  end
end

class TwoWayBinding < Vue
  data :message, 'hola'
end

class Item < VueComponent
  props :todo
  template '<li>{{ todo.text }}</li>'
  tag_name 'todo-item'
end

class GroceryList < Vue
  data :grocery_list, [ {id: 0, text: 'Vegetables'}, {id: 1, text: 'Cheese'}, {id: 2, text: 'whatever else humans are supposed to eat'} ]
end

class ComputedReverse < Vue
  data :message, 'this is the original message'

  def change_message
    self.message = 'this is another message'
  end

  computed

  def reversed_message_computed
    message.reverse
  end
end

# install the opal bowser gem in order to make this work
class Questions < Vue
  data :question, ''
  data :answer, 'I cannot give you an answer until you ask a question!'

  watch :question do |new_question, old_question|
    puts "old question was #{old_question}"
    puts "new question is #{new_question}"
    get_answer
  end

  def get_answer
    if !question.end_with?('?')
      self.answer = 'Questions usually contain a question mark. ;-)'
    else
      self.answer = 'Thinking...'
      Bowser::HTTP.fetch('https://yesno.wtf/api')
                  .then(&:json) # JSONify the response
                  .then { |response| self.answer = response[:answer] }
                  .catch { |exception| self.answer = exception.message }
    end
  end
end

class ClickCounter < VueComponent
  data :count, 0
  template '#increment-template'
  tag_name 'click-counter'

  def increment_count
    self.count += 1
  end
end

class CounterEl < Vue
end

SimpleMessage.new('#app')
DateTitle.new('#app-2')
Hidden.new('#app-3')
TodoList.new('#app-4')
ReverseMessage.new('#app-5')
TwoWayBinding.new('#app-6')

Item.activate
GroceryList.new('#app-7')
ComputedReverse.new('#appi')
Questions.new('#watch-example')

ClickCounter.activate

CounterEl.new('#counter')
