# -*- encoding: utf-8 -*-

require 'minitest/autorun'
require 'top_tests'

class FailingTest < MiniTest::Unit::TestCase

  include TopTests

  def test_bad
    assert(false)
  end

end
