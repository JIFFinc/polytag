require 'spec_helper'

describe "Taggable Without Owner ::" do
  let!(:time) { Time.now.to_i }
  let(:taggable) { Taggable.create(name: "test_#{time}") }

  before(:each) do
    taggable.tag.new(:apple)
  end

  it "Should create a model of Taggable" do
    taggable.name.should eq("test_#{time}")
    taggable.should be_a(Taggable)
  end

  context "Add a tag ::" do
    it "Should have a tag" do
      tags = taggable.tags(true)

      tags.size.should eq(1)
      tags.first.name.should eq('apple')
    end

    it "Should be able to find tag via has_tag?" do
      taggable.tag.has_tag?(:apple).should be_true
    end

    it "Should delete the tag" do
      taggable.tag.del(:apple)
      taggable.tags(true).should be_empty
    end

    it "Should add an another tag" do
      taggable.tag.new(:peach)
      tags = taggable.tags(true)

      tags.size.should eq(2)
      tags.map(&:name).should eq(['apple', 'peach'])
    end

    it "Should add an another tag and delete the original" do
      taggable.tag.new(:peach)
      taggable.tag.del(:apple)
      tags = taggable.tags(true)

      tags.size.should eq(1)
      tags.first.name.should eq('peach')
    end
  end

  it "Should find model by tag" do
    taggables = Taggable.has_tag(:apple)
    taggables.size.should eq(1)
    taggables.should include(taggable)
    tags = taggables.first.tags
    tags.size.should eq(1)
    tags.first.name.should eq('apple')
  end
end
