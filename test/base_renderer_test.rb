require File.join(File.dirname(__FILE__), "test_helper")

class BaseRendererTest < Vanilla::TestCase
  context "in general" do
    setup do
      create_snip(:name => "test", :content => "content content", :part => "part content")
    end

    should "render the contents part of the snip as it is" do
      assert_response_body "content content", "/test"
    end
  
    should "render the specified part of the snip" do
      assert_response_body "part content", "/test/part"
    end
  
    should "include the contents of a referenced snip" do
      create_snip(:name => "snip_with_inclusions", :content => "loading {test}")
      assert_response_body "loading content content", "/snip_with_inclusions"
    end
  
    should "perform snip inclusion when rendering a part" do
      create_snip(:name => "snip_with_inclusions", :content => "other content", :part => "loading {test}")
      assert_response_body "loading content content", "/snip_with_inclusions/part"
    end
  
    should "include other snips using their renderers" do
      create_snip(:name => "including_snip", :content => "lets include {another_snip}")
      create_snip(:name => "another_snip", :content => "blah", :render_as => "Bold")
      assert_equal "lets include <b>blah</b>", response_body_for("/including_snip").gsub(/\s+/, ' ')
    end
  end
  
  context "when trying to include a missing snip" do
    should "return a string describing the missing snip" do
      create_snip(:name => 'blah', :content => 'include a {missing_snip}')
      assert_response_body "include a [snip 'missing_snip' cannot be found]", "/blah"
    end
  end
end