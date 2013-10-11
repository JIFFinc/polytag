require 'spec_helper'

describe "Create a tag with a tag group with owner passed with type and id" do
  let!(:time) { Time.now.to_s }
  let(:test_taggable) do
    TestTaggableThree.create!(name: "test_#{time}")
  end

  it "Should have a tag group attached" do
    test_taggable.name.should == "test_#{time}"
    test_taggable.should be_a(TestTaggableThree)
    test_taggable.tag_group.should be_a(Polytag::TagGroup)
  end

  context "Add a tag " do
    before(:each) do
      test_taggable.add_tag!(:pie)
    end

    it "Should have a tag on the TestTaggableTwo model with the right tag group" do
      tags = test_taggable.tags(true)
      tags.size.should == 1
      tags.first.name.should == 'pie'
      tags.first.tag_group.should == test_taggable.tag_group
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

      tags.each do |tag|
        tag.tag_group.should == test_taggable.tag_group
      end
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
