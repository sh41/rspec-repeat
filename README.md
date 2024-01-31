# RSpec::Repeat

> Repeats an RSpec example until it succeeds

```rb
# spec_helper.rb

# Example: Repeat all tests in CI
if ENV['CI']
  require 'rspec/repeat'

  RSpec.configure do |config|
    config.include RSpec::Repeat
    config.around :each do |example|
      repeat example, 3.times, verbose: true
    end
  end
end
```
[![Status](https://travis-ci.org/rstacruz/rspec-repeat.svg?branch=master)](https://travis-ci.org/rstacruz/rspec-repeat "See test builds")

<br>

## Advanced usage

### Options

```
repeat example, 3.times, { options }
```

You can pass an `options` hash:

- __clear_let__ *(Boolean)* — if *false*, `let` declarations will not be cleared.
- __exceptions__ *(Array)* — if given, it will only retry exception classes from this list.
- __wait__ *(Numeric)* — seconds to wait between each retry.
- __verbose__ *(Boolean)* — if *true*, it will print messages upon failure.

### Attaching to tags

This will allow you to repeat any example multiple times by tagging it.

```rb
# rails_helper.rb or spec_helper.rb
require 'rspec/repeat'

RSpec.configure do |config|
  config.include RSpec::Repeat
  config.around :each, :stubborn do |example|
    repeat example, 3.times
  end
end
```

```rb
describe 'stubborn tests', :stubborn do
  # ...
end
```

### Attaching to features

This will make all `spec/features/` retry thrice. Perfect for Poltergeist/Selenium tests that intermittently fail for no reason.

```rb
# rails_helper.rb or spec_helper.rb
require 'rspec/repeat'

RSpec.configure do |config|
  config.include RSpec::Repeat
  config.around :each, type: :feature do |example|
    repeat example, 3.times
  end
end
```

In these cases, it'd be smart to restrict which exceptions to be retried.

```rb
repeat example, 3.times, verbose: true, exceptions: [
  Net::ReadTimeout,
  Selenium::WebDriver::Error::WebDriverError
]
```

### Repeating a specific test

You can also include RSpec::Repeat in just a single test block.

```rb
require 'rspec/repeat'

describe 'a stubborn test' do
  include RSpec::Repeat

  around do |example|
    repeat example, 10.times
  end

  it 'works, eventually' do
    expect(rand(2)).to eq 0
  end
end
```

### Running code before retries
If a block is passed to `repeat`, it will be executed after a failure and before resetting for the next run.
The block is passed 4 argu:

- `i` - the count of the current run through (0 indexed)
- `ex` - the [`RSpec::Core::Example::Procsy`](https://github.com/rspec/rspec-core/blob/1e661db5c5b431c0ee88a383e8e3767f02dccbfe/lib/rspec/core/example.rb#L331)
- `current_example` - the current [`RSpec::Core::Example`](https://github.com/rspec/rspec-core/blob/1e661db5c5b431c0ee88a383e8e3767f02dccbfe/lib/rspec/core/example.rb#L44)
- `ctx` - the current context/example group allowing access to let etc via [`RSpec::ExampleGroups`](https://github.com/rspec/rspec-core/blob/1e661db5c5b431c0ee88a383e8e3767f02dccbfe/lib/rspec/core/example_group.rb#L839)

For example, you can implement a wait between retries that grows with each failure:
```rb
around do |example|
    repeat example, 10 do |i, _ex, _current_example, _ctx|
      failure_count = (i + 1)
      next if failure_count >= 10
      warn "Example sleeping #{failure_count * 2} seconds"
      sleep(failure_count * 2)
    end
end
```

You can also access the context of the current test, but be careful changing state between tests!
```rb
require 'rspec/repeat'

describe 'change lets to eventually pass a test' do
  include RSpec::Repeat
  
  let(:value) { 99 }
  let(:failed_attempts) { 0 }

  around do |example|
    repeat example, 100.times, clear_let: false do |i, _ex, _example, ctx|
      ctx.send(:__memoized).instance_variable_get(:@memoized)[:value] = value - 1
      ctx.send(:__memoized).instance_variable_get(:@memoized)[:failed_attempts] = i + 1
    end
  end

  it 'works' do
    expect(value).to eq(0)
    expect(failed_attempts).to eq(99)
  end 
end
```
<br>

## Acknowledgement

Much of this code has been refactored out of [rspec-retry](https://github.com/NoRedInk/rspec-retry) by [@NoRedInk](https://github.com/NoRedInk).

<br>

## Thanks

**rspec-repeat** © 2015-2017, Rico Sta. Cruz. Released under the [MIT] License.<br>
Authored and maintained by Rico Sta. Cruz with help from contributors ([list][contributors]).

> [ricostacruz.com](http://ricostacruz.com) &nbsp;&middot;&nbsp;
> GitHub [@rstacruz](https://github.com/rstacruz) &nbsp;&middot;&nbsp;
> Twitter [@rstacruz](https://twitter.com/rstacruz)

[MIT]: http://mit-license.org/
[contributors]: http://github.com/rstacruz/rspec-repeat/contributors
