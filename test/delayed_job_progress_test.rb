require_relative './test_helper'

class DelayedJobProgressTest < ActiveSupport::TestCase
  def test_module
    assert_kind_of Module, DelayedJobProgress
  end
end
