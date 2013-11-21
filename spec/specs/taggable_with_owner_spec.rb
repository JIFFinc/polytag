require 'spec_helper'

describe "Taggable With Owner ::" do
  let!(:time) { Time.now.to_i }
  let(:owner) { Owner.create }
  let(:taggable) { Taggable.create(name: "test_#{time}") }

  before(:each) do
    taggable.tag.add(:apple, tag_group_owner: owner)
  end

  it "Should create a model of Taggable" do
    taggable.name.should eq("test_#{time}")
    taggable.should be_a(Taggable)
  end

  context "Add a tag ::" do
    it "Should find the tag with the right owner and group" do
      tags = taggable.tags(true)

      tags.size.should eq(1)
      tags.first.name.should eq('apple')
      tags.first.tag_group.name.should eq('default')
      tags.first.tag_group.owner.should eq(owner)
    end

    it "Should find the tag via has_tag?" do
      taggable.tag.has_tag?(:apple, tag_group_owner: owner).should be_true
    end

    context "Add another tag ::" do
      before(:each) do
        taggable.tag.add(:peach)
      end

      it "Should not conflict with model only tags" do
        taggable.tag.add(:apple)
        tags = taggable.tags(true)

        # Peach, Apple, Apple (where one of the apples is in a tag group)
        tags.size.should be(3)
        tags.map(&:name).should eq(['apple', 'peach', 'apple'])
      end

      it "Should find only one due to a owner constraint" do
        tags = taggable.tags(true)
        tags.size.should eq(2) # Should see both

        # Get only the tags attached to the owner
        tags = tags.tag_group(tag_group_owner: owner)
        tags.size.should eq(1) # Now the constainst is applied we should see less.
        tags.map(&:name).should eq(['apple'])
        tags.first.tag_group.owner.should eq(owner)
        tags.first.tag_group.should eq(owner.tag_groups.default)
      end

      it "and find both tags" do
        tags = taggable.tags(true)
        tags.size.should eq(2)
        tags.map(&:name).should eq(['apple', 'peach'])
      end

      it "and it Should not delete the original without an owner constraint" do
        taggable.tag.del(:apple)

        tags = taggable.tags(true)
        tags.size.should eq(2)
        tags.map(&:name).should eq(['apple', 'peach'])
      end

      it "and it Should delete the original with an owner constraint" do
        taggable.tag.del(:apple, tag_group_owner: owner)

        tags = taggable.tags(true)
        tags.size.should eq(1)
        tags.map(&:name).should eq(['peach'])
      end
    end
  end

  it "Should find model by tag" do
    taggables = Taggable.has_tag(:apple, tag_group_owner: owner)
    taggables.size.should eq(1)
    taggables.should include(taggable)
    tags = taggables.first.tags
    tags.size.should eq(1)
    tags.first.name.should eq('apple')
  end

  context "Many2Many2Many Connection Hopping ::" do
    it "Should find Owner by Tag" do
      tag = taggable.tag.get(:apple, tag_group: :default)
      tag.should be_a(Polytag::Connection)
      tag.name.should eq('apple')
      tag.tag_group.name.should eq('default')
      tag.owner.should eq(owner)
    end

    it "Should find Tag by Owner" do
      tag = owner.owned_tags.get(:apple).first
      tag.should be_a(Polytag::Connection)
      tag.name.should eq('apple')
      tag.tag_group.name.should eq('default')
      tag.owner.should eq(owner)
    end

    it "Should find Tag by Owner wiht a Group" do
      taggable.tag.add(:orange, tag_group: "Fruit", tag_group_owner: owner)

      tags = owner.owned_tags.get(:orange, tag_group: "Fruit")
      tags.size.should eq(1)

      tag = tags.first
      tag.should be_a(Polytag::Connection)
      tag.name.should eq('orange')
      tag.tag_group.name.should eq('Fruit')
      tag.owner.should eq(owner)
    end
  end
end
