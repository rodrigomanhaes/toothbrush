require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Toothbrush" do
  it 'talks to the dummy app' do
    visit '/dummy'
    page.should have_content "Hey, ho, let's go!"
  end
end
