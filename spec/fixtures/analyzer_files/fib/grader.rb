# Grading code for Ruby submissions.
require 'json'

# Anonymous class, so it's hard to find.
require 'minitest/unit'
runner_class = Class.new MiniTest::Unit do
  @runner = self.new
  
  def self.runner
    @runner
  end
  
  def _run(*args)
    key = File.read('key.b64').strip
    File.delete 'key.b64'
    begin
      super
    ensure
      if test_count && test_count > 0
        score = (test_count - failures - errors) / test_count.to_f
      else
        score = 0
      end
      grades = {'Problem 1' => score}
      STDERR.write "\n#{key}\n#{grades.to_json}\n"
    end
  end
end

# Make it harder to find the runner and extract the key.
Object.send :remove_const, :ObjectSpace
Object.send :remove_const, :TOPLEVEL_BINDING

# Make it harder to mess with the unit test code.
runner_class.plugins.freeze
runner_class.freeze
MiniTest::Unit.freeze
MiniTest.freeze

Dir['./*_test.rb'].each { |test_case| load test_case }
runner_class.new.run
