# -*- encoding : utf-8 -*-

module TopTests

  #####################
  ### Class methods ###
  #####################

  def self.included(klass)
    klass.extend(ClassMethods)
    MiniTest::Unit.after_tests { klass.after_all_tests }
  end

  ########################
  ### Instance methods ###
  ########################

  def before_setup
    @timer_started_at = Time.now
  end

  def after_teardown
    if @timer_started_at  # Unset when a setup hook fails before top test.
      name = self.class.to_s + '#' + @__name__
      self.class.tests_durations << [name, Time.now - @timer_started_at]
    end
  end

  #####################
  ### Class methods ###
  #####################

  module ClassMethods
    def tests_durations
      @@tests_durations ||= []
    end

    def max_duration=(seconds)
      @@max_duration = seconds
    end

    def max_duration
      @@max_duration ||= nil
    end

    def top_tests
      tests_durations.sort { |a, b| b.last <=> a.last }
    end

    def slow_tests
      max_duration ? top_tests.find_all { |t| t.last > max_duration } : []
    end

    def format_tests(tests)
      tests.map { |t| "  #{format("%7.3f", t.last)} #{t.first}" }.join("\n")
    end

    def print_top_tests
      puts "\nTop 10 slowest tests:"
      puts format_tests(top_tests.shift(10))
      puts
    end

    def check_tests_duration
      if !slow_tests.empty?
        if slow_tests.size == 1
          puts "\nTEST?FAIL! 1 test is taking longer than #{max_duration} seconds:"
        else
          puts "\nTEST?FAIL! #{slow_tests.count} tests are taking longer than #{max_duration} seconds:"
        end
        puts format_tests(slow_tests)
        puts
        exit 1
      end
    end

    def after_all_tests
      check_tests_duration
      print_top_tests
    end
  end

end
