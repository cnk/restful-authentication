require File.dirname(__FILE__) + '/../test_helper'

class <%= server_class_name %>Test < ActiveSupport::TestCase
  fixtures :<%= server_plural_name %>

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
