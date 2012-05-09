require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Toothbrush" do
  before(:each) { visit '/dummy' }

  it 'talks to the dummy app' do
    page.should have_content "Hey, ho, let's go!"
  end

  describe 'ensures table content' do
    it 'correct table' do
      ensure_table '#football-clubs-from-rio-de-janeiro-and-their-honors',
        [   'Club',    'World', 'Libertadores', 'Brasileiro', 'Copa do Brasil', 'Carioca'],
        [%w( Flamengo     1            1              6              2              32   ),
         %w( Vasco        0            1              4              1              22   ),
         %w( Fluminense   0            0              3              1              30   ),
         %w( Botafogo     0            0              1              0              19   )]
    end

    it 'vasco is not a world club champion' do
      expect {
        ensure_table '#football-clubs-from-rio-de-janeiro-and-their-honors',
          [   'Club',    'World', 'Libertadores', 'Brasileiro', 'Copa do Brasil', 'Carioca'],
          [%w( Flamengo     1            1              6              2              32   ),
           %w( Vasco        1            1              4              1              22   ),
           %w( Fluminense   0            0              3              1              30   ),
           %w( Botafogo     0            0              1              0              19   )]
       }.to raise_error(RSpec::Expectations::ExpectationNotMetError,
                        'expected #has_content?("1") to return true, got false')
    end
  end
end
