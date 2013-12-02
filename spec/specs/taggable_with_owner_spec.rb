require 'spec_helper'

describe "Taggable With Owner ::" do
  let!(:time) { Time.now.to_i }
  let(:owner) { Owner.create(name: "test_#{time}") }
  let(:taggable) { Taggable.create(name: "test_#{time}") }

  before(:each) do
    taggable.tag.add(:apple, owner: owner)
  end

  it "Should create a model of Taggable" do
    taggable.name.should eq("test_#{time}")
    taggable.should be_a(Taggable)
  end

  it "Should create a model of Owner" do
    owner.name.should eq("test_#{time}")
    owner.should be_a(Owner)
  end

  context "Add a tag ::" do
    it "Should find the tag with the right owner and group" do
      tags = taggable.tags(true)

      tags.size.should eq(1)
      tags.first.name.should eq('apple')
      tags.first.group.name.should eq('default')
      tags.first.group.owner.should eq(owner)
    end

    it "Should find the tag via has_tag?" do
      taggable.tag.has_tag?(:apple, owner: owner).should be_true
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
        tags = tags.tag_group(owner: owner)
        tags.size.should eq(1) # Now the constainst is applied we should see less.
        tags.map(&:name).should eq(['apple'])
        tags.first.group.owner.should eq(owner)
        tags.first.group.should eq(owner.tag_groups.default)
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
        taggable.tag.del(:apple, owner: owner)

        tags = taggable.tags(true)
        tags.size.should eq(1)
        tags.map(&:name).should eq(['peach'])
      end
    end
  end

  it "Should find model by tag" do
    taggables = Taggable.has_tag(:apple, owner: owner)
    taggables.size.should eq(1)
    taggables.should include(taggable)
    tags = taggables.first.tags
    tags.size.should eq(1)
    tags.first.name.should eq('apple')
  end

  context "Many2Many2Many Connection Hopping ::" do
    it "Should find Owner by Tag" do
      tag = taggable.tag.get :apple,
        return: :connection,
        owner: :find

      tag.should be_a(Polytag::Connection)
      tag.name.should eq('apple')
      tag.group.name.should eq('default')
      tag.owner.should eq(owner)
    end

    it "Should find Tag by Owner" do
      tag = owner.owned_tags.get(:apple).first
      tag.should be_a(Polytag::Connection)
      tag.name.should eq('apple')
      tag.group.name.should eq('default')
      tag.owner.should eq(owner)
    end

    it "Should find Tag by Owner with a Group" do
      taggable.tag.add(:orange, group: "Fruit", owner: owner)

      tags = owner.owned_tags.get(:orange, group: "Fruit")
      tags.size.should eq(1)

      tag = tags.first
      tag.should be_a(Polytag::Connection)
      tag.name.should eq('orange')
      tag.group.name.should eq('Fruit')
      tag.owner.should eq(owner)
    end

    context "Taggable Hopping ::" do
      let(:owner2)    { Owner.create(name: "test_#{time}_2")}
      let(:taggable2) { Taggable.create(name: "test_#{time}_2") }
      let(:taggable3) { Taggable.create(name: "test_#{time}_3") }
      let(:taggable4) { Taggable.create(name: "test_#{time}_4") }
      let(:taggable5) { Taggable.create(name: "test_#{time}_5") }

      before(:each) do
        taggable2.tag.add(:apple, owner: owner)
        taggable3.tag.add(:apple, owner: owner2)
        taggable4.tag.add(:apple, owner: owner2)
        taggable4.tag.add(:apple)
        taggable5.tag.add(:apple)
      end

      it "Should find other Taggables with the same tag" do
        tags = taggable.tag.associated_models(:apple, owner: owner)
        tags.count.should eq(2)
        tags.map(&:tagged).should include(taggable2)
      end

      it "Should find other Taggables with the same tag with different tag group and owners" do
        tags = taggable.tag.associated_models(:apple, owner: owner)
        tags.count.should eq(2)
        tags.map(&:tagged).should include(taggable2)

        tags = taggable3.tag.associated_models(:apple, owner: owner2)
        tags.count.should eq(2)
        tags.map(&:tagged).should include(taggable4)
      end

      it "Should not find Taggables in tag groups." do
        tags = taggable4.tag.associated_models(:apple)
        tags.count.should eq(2)
        tags.map(&:tagged).should include(taggable5)
      end
    end
  end
end
