require 'spec_helper'

describe "Create a tag without a category" do
  let!(:time) { Time.now.to_s }
  let(:test_taggable) { TestTaggable.create(name: "test_#{time}") }

  it "Should create a model of TestTaggable with test_timestamp" do
    test_taggable.should be_a(TestTaggable)
    test_taggable.name.should == "test_#{time}"
  end
end
