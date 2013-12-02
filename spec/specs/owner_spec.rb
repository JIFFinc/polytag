require 'spec_helper'

describe "Owner ::" do
  let!(:time) { Time.now.to_i }
  let(:owner) { Owner.create(name: "test_#{time}") }

  before(:each) do
    owner.tag_group.add_tag(:pizza)
    owner.tag_group.add_tag(:apple, "Fruit")
  end

  it "Should create a model of Owner" do
    owner.name.should eq("test_#{time}")
    owner.should be_a(Owner)
  end

  context "Tag Groups ::" do
    it "Should find the \"default\" group" do
      tag_group = owner.tag_groups.default
      tag_group.should be_a(::Polytag::Group)
      tag_group.owner.should eq(owner)
      tag_group.name.should eq("default")
    end

    it "Should find the \"Fruit\" tag group" do
      tag_group = owner.tag_groups.get("Fruit")
      tag_group.should be_a(::Polytag::Group)
      tag_group.owner.should eq(owner)
      tag_group.name.should eq("Fruit")
    end

    it "Should allow a tag group with the same name on other owners" do
      other_owner = Owner.create

      # Create a tag (which also creates a tag group)
      other_owner.tag_group.add_tag(:sub)

      tag_group = owner.tag_groups.default
      tag_group.should be_a(::Polytag::Group)

      other_tag_group = other_owner.tag_groups.default
      other_tag_group.should be_a(::Polytag::Group)

      tag_group.should_not eq(other_tag_group)

      tag_group.owner.should eq(owner)
      tag_group.name.should eq("default")
      tag_group.tags.map(&:name).should eq(['pizza'])

      other_tag_group.owner.should eq(other_owner)
      other_tag_group.name.should eq("default")
      other_tag_group.tags.map(&:name).should eq(['sub'])
    end
  end

  context "Owned Tags ::" do
    it "Should find the tag in the \"default\" group" do
      tag_group = owner.tag_groups.default
      tag_group.should be_a(::Polytag::Group)
      tag_group.owner.should eq(owner)
      tag_group.tags.map(&:name).should eq(['pizza'])
    end

    it "Should find the tag in the \"Fruit\" group" do
      tag_group = owner.tag_groups.get("Fruit")
      tag_group.should be_a(::Polytag::Group)
      tag_group.owner.should eq(owner)
      tag_group.tags.map(&:name).should eq(['apple'])
    end

    # Adding this spec because it was a problem in testing
    it "Should allow tags with the same name in other groups" do
      owner.tag_group.add_tag(:apple)

      tag_group = owner.tag_groups.get("Fruit")
      tag_group.should be_a(::Polytag::Group)
      tag_group.owner.should eq(owner)
      tag_group.tags.map(&:name).should eq(['apple'])
    end
  end

  context "Finder Methods ::" do
    it "Should find the owner by Tag Group" do
      @owners = Owner.has_tag_group('default')
    end

    it "Should find the owner by Tag without Tag Group (even if the tag is in a group)" do
      @owners = Owner.has_tag('apple')
    end

    it "Should find the owner by Tag with Tag Group" do
      @owners = Owner.has_tag('apple', 'Fruit')
    end

    after(:each) do
      @owners.should include(owner)
      @owners.first.tag_group.exist?('Fruit').should be_true
      @owners.first.tag_group.exist?('default').should be_true
      @owners.first.tag_group.owns_tag?('pizza').should be_true
      @owners.first.tag_group.owns_tag?('apple').should be_false
      @owners.first.tag_group.owns_tag?('apple', 'Fruit').should be_true
    end
  end
end
