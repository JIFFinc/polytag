require 'spec_helper'

describe "Create a tag without a category" do
  let!(:time) { Time.now.to_s }
  let(:test_taggable) { TestTaggable.create!(name: "test_#{time}") }

  it "Should create a model of TestTaggable with test_timestamp" do
    test_taggable.should be_a(TestTaggable)
    test_taggable.name.should == "test_#{time}"
  end

  it "Should have a tag category of nil" do
    test_taggable.class.polytag_category.should be_nil
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

describe "Create a tag with a category" do
  let!(:time) { Time.now.to_s }
  let(:test_taggable) do
    TestTaggable.polytag_category :apple
    TestTaggable.create!(name: "test_#{time}")
  end

  it "Should have `apple` set as the category on the TestTaggable class" do
    test_taggable.class.polytag_category.should == :apple
  end

  context "Add a tag" do
    before(:each) do
      test_taggable.class.polytag_category.should == :apple
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
