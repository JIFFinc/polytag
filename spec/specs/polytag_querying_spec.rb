require 'spec_helper'

describe "Create a a model with tags and query for them" do

  # Create some random models with tags
  let(:sample_classes) do
    (0..5).to_a.map do |t|
      klass = TestTaggableThree.create!(name: "test_#{Time.now}")
      klass.tag_group(name: 'Apple')
      klass.add_tag!(*('A'..'E').shuffle.sample((2..3).sample))
      klass
    end
  end

  # Create the model I will be testing regularly
  let!(:time) { Time.now.to_s }
  let(:test_taggable) do
    TestTaggableThree.create!(name: "test_#{time}")
  end

  it "Should have a tag group attached" do
    test_taggable.name.should == "test_#{time}"
    test_taggable.should be_a(TestTaggableThree)
    test_taggable.tag_group.should be_a(Polytag::TagGroup)
  end

  context "Query for the tags in question on the default tag_group " do
    before(:each) do
      test_taggable.add_tag!('A')
    end

    it "Test searching for our `test_taggable` model with the A tag" do
      TestTaggableThree.has_tag('A').should include(test_taggable)
      TestTaggableThree.has_tag('B').should_not include(test_taggable)
    end

    it "Should not find our `test_taggable` model in the `Apple` tag_group" do
      TestTaggableThree.in_tag_group(name: 'Apple').should_not include(test_taggable)
    end

    it "Should not find our `test_taggable` model in the `Apple` tag_group even if it shares a tag name" do
      TestTaggableThree.in_tag_group(name: 'Apple').has_tag('A').should_not include(test_taggable)
    end

    it "Should find our `test_taggable` model when we specify the right tag group and tag" do
      TestTaggableThree.in_tag_group(owner: test_taggable.tag_group.owner).has_tag('A').should include(test_taggable)
    end

     it "Should find our `test_taggable` model when we specify the right tag group" do
      TestTaggableThree.in_tag_group(owner: test_taggable.tag_group.owner).should include(test_taggable)
    end
  end
end
