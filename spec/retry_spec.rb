require 'rspec/repeat'

describe 'retry' do
  include RSpec::Repeat
  describe 'normal case' do
    around do |example|
      repeat example, 100.times
    end

    it 'works' do
      expect(rand(10)).to eq 0
    end
  end

  describe 'clearing let' do
    around do |example|
      repeat example, 100.times
    end

    let(:number) { rand(10) }

    it 'works' do
      expect(number).to eq 0
    end
  end

  describe 'exceptions list' do
    FooError = Class.new(StandardError)

    around do |example|
      repeat example, 100.times, exceptions: [FooError]
    end

    it 'works' do
      raise FooError if rand(10) != 0
    end
  end

  describe 'block' do
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
end
