# -*- encoding : utf-8 -*-

module TopTests

  #####################
  ### Class methods ###
  #####################

  def self.included(klass)
    klass.setup :start_timer
    klass.teardown :stop_timer
    klass.extend(ClassMethods)
    at_exit { at_exit { klass.print_top_tests } }
  end

  ########################
  ### Instance methods ###
  ########################

  def start_timer
    @timer_started_at = Time.now
  end

  def stop_timer
    name = self.class.to_s + '#' + @__name__
    self.class.tests_durations << [name, Time.now - @timer_started_at]
  end

  #####################
  ### Class methods ###
  #####################

  module ClassMethods
    def tests_durations
      @@tests_durations ||= []
    end

    def top_tests
      tests_durations.sort { |a, b| b.last <=> a.last }
    end

    def print_top_tests
      puts "\nTop tests:"
      puts top_tests.shift(10).map { |t| "#{format("%7.3f", t.last)} #{t.first}" }.join("\n")
      puts
    end
  end

end

