require 'test_helper'

class RoutesTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

   def setup
    @business = businesses(:canchita)
  end

  test "route test" do
    assert_generates @business.slug, { :controller => "businesses", :action => "show", :id => "la-canchita" }
    assert_generates "/help", :controller => "static_pages", :action => "help"
  end

  
end
