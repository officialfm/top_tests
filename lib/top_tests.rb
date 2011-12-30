# -*- encoding : utf-8 -*-

module TopTests

  #####################
  ### Class methods ###
  #####################

  def self.included(klass)
    klass.setup :start_timer
    klass.teardown :stop_timer
    klass.extend(ClassMethods)
    at_exit { at_exit { klass.at_exit_callback } }
  end

  ########################
  ### Instance methods ###
  ########################

  def start_timer
    @timer_started_at = Time.now
  end

  def stop_timer
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
      @@max_duration
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
      puts "\nTop tests:"
      puts format_tests(top_tests.shift(10))
      puts
    end

    def check_tests_duration
      if !slow_tests.empty?
        puts "\nTEST?FAIL! #{slow_tests.count} test(s) are taking longer than #{max_duration} seconds:"
        puts format_tests(slow_tests)
        puts
        exit 1
      end
    end

    def at_exit_callback
      check_tests_duration
      print_top_tests
    end
  end

end
