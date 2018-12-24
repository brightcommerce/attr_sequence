# AttrSequence

AttrSequence is an ActiveRecord concern that generates scoped sequential numbers for models. This gem provides an `attr_sequence` macro that automatically assigns a unique, sequential number to each record. The sequential number is not a replacement for the database primary key, but rather adds another way to retrieve the object without exposing the primary key.

AttrSequence has been extracted from the Brightcommerce platform and is now used in multiple other software projects.

## Installation

To install add the line to your `Gemfile`:

``` ruby
gem 'attr_sequence'
```

And run `bundle install`.

The following configuration defaults are used by AttrSequence:

``` ruby
AttrSequence.configure do |config|
  config.column = :number
  config.start_at = 1
end
```

You can override them by generating an initializer using the following command:

``` bash
rails generate attr_sequence:initializer
```

This will generate an initializer file in your project's `config/initializers` called `attr_sequence.rb` directory.

## Usage

It's generally a bad practice to expose your primary keys to the world in your URLs. However, it is often appropriate to number objects in sequence (in the context of a parent object).

For example, given a Question model that has many Answers, it makes sense to number answers sequentially for each individual question. You can achieve this with AttrSequence:

``` ruby
class Question < ActiveRecord::Base
  has_many :answers
end

class Answer < ActiveRecord::Base
  include AttrSequence
  belongs_to :question
  attr_sequence scope: :question_id
end
```

To autoload AttrSequence for all models, add the following to an initializer:

``` ruby
require 'attr_sequence/active_record'
```

You then don't need to `include AttrSequence` in any model.

To add a sequential number to a model, first add an integer column called `:number` to the model (or you many name the column anything you like and override the default). For example:

``` bash
rails generate migration add_number_to_answers number:integer
rake db:migrate
```

Then, include the concern module and call the `attr_sequence` macro in your model class:

``` ruby
class Answer < ActiveRecord::Base
  include AttrSequence
  belongs_to :question
  attr_sequence scope: :question_id
end
```

The scope option can be any attribute, but will typically be the foreign key of an associated parent object. You can even scope by multiple columns for polymorphic relationships:

``` ruby
class Answer < ActiveRecord::Base
  include AttrSequence
  belongs_to :questionable, polymorphic: true
  attr_sequence scope: [:questionable_id, :questionable_type]
end
```

Multiple sequences can be defined by using the macro multiple times:

``` ruby
class Answer < ActiveRecord::Base
  include AttrSequence
  belongs_to :account
  belongs_to :question

  attr_sequence column: :question_answer_number, scope: :question_id
  attr_sequence column: :account_answer_number, scope: :account_id
end
```

## Schema and data integrity

*This gem is only concurrent-safe for PostgreSQL databases.* For other database systems, unexpected behavior may occur if you attempt to create records concurrently.

You can mitigate this somewhat by applying a unique index to your sequential number column (or a multicolumn unique index on sequential number and scope columns, if you are using scopes). This will ensure that you can never have duplicate sequential numbers within a scope, causing concurrent updates to instead raise a uniqueness error at the database-level.

It is also a good idea to apply a not-null constraint to your sequential number column as well if you never intend to skip it.

Here is an example migration for an `Answer` model that has a `:number` scoped to a `Question`:

``` ruby
# app/db/migrations/20180101000000_create_answers.rb
class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |table|
      table.references :question
      table.column :number, :integer, null: false
      table.index [:number, :question_id], unique: true
    end
  end
end
```

## Configuration

### Overriding the default sequential ID column

By default, AttrSequence uses the `number` column and assumes it already exists. If you wish to store the sequential number in different integer column, simply specify the column name with the `:column` option:

``` ruby
attr_sequence scope: :question_id, column: :my_sequential_id
```

### Starting the sequence at a specific number

By default, AttrSequence begins sequences with 1. To start at a different integer, simply set the `start_at` option:

``` ruby
attr_sequence start_at: 1000
```

You may also pass a lambda to the `start_at` option:

``` ruby
attr_sequence start_at: lambda { |r| r.computed_start_value }
```

### Indexing the sequential number column

For optimal performance, it's a good idea to index the sequential number column on sequenced models.

### Skipping sequential ID generation

If you'd like to skip generating a sequential number under certain conditions, you may pass a lambda to the `skip` option:

``` ruby
attr_sequence skip: lambda { |r| r.score == 0 }
```

## Example

Suppose you have a question model that has many answers. This example demonstrates how to use AttrSequence to enable access to the nested answer resource via its sequential number.

``` ruby
# app/models/question.rb
class Question < ActiveRecord::Base
  has_many :answers
end

# app/models/answer.rb
class Answer < ActiveRecord::Base
  include AttrSequence
  belongs_to :question
  attr_sequence scope: :question_id

  # Automatically use the sequential number in URLs
  def to_param
    self.number.to_s
  end
end

# config/routes.rb
resources :questions do
  resources :answers
end

# app/controllers/answers_controller.rb
class AnswersController < ApplicationController
  def show
    @question = Question.find(params[:question_id])
    @answer = @question.answers.find_by(number: params[:id])
  end
end
```

Now, answers are accessible via their sequential numbers:

```
http://example.com/questions/5/answers/1  # Good
```

instead of by their primary keys:

```
http://example.com/questions/5/answer/32454  # Bad
```

## Dependencies

AttrSequence gem has the following runtime dependencies:
- activerecord >= 5.1.4
- activesupport >= 5.1.4

## Compatibility

Tested with MRI 2.4.2 against Rails 5.2.2.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Credit

This gem was written and is maintained by [Jurgen Jocubeit](https://github.com/JurgenJocubeit), CEO and President Brightcommerce, Inc.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Copyright

Copyright 2018 Brightcommerce, Inc.
