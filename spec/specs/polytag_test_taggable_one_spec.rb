require 'spec_helper'

describe "Create a tag without a tag group" do
  let!(:time) { Time.now.to_s }
  let(:test_taggable) { TestTaggableOne.create!(name: "test_#{time}") }

  it "Should create a model of TestTaggable with test_timestamp" do
    test_taggable.name.should == "test_#{time}"
    test_taggable.should be_a(TestTaggableOne)
  end

  it "Should not have a tag group" do
    test_taggable.tag_group.should be_nil
  end

  context "Add a tag" do
    before(:each) do
      test_taggable.add_tag!(:pie)
    end

    it "Should have a tag on the TestTaggable model" do
      tags = test_taggable.tags(true)
      tags.size.should == 1
      tags.first.name.should == 'pie'
    end

    it "Should delete the tag on the TestTaggable model" do
      test_taggable.remove_tag!(:pie)
      test_taggable.tags(true).should be_empty
    end

    it "Should add an another tag and have two" do
      test_taggable.add_tag!(:pizza)
      tags = test_taggable.tags(true)
      tags.size.should == 2
      tags.map(&:name).should == ['pie', 'pizza']
    end

    it "Should add an another tag and delete the original" do
      test_taggable.add_tag!(:pizza)
      test_taggable.remove_tag!(:pie)
      tags = test_taggable.tags(true)
      tags.size.should == 1
      tags.first.name.should == 'pizza'
    end
  end
end
