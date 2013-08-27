require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Toothbrush" do
  before(:each) { visit '/dummy' }

  it 'talks to the dummy app' do
    page.should have_content "Hey, ho, let's go!"
  end

  describe 'ensures table content' do
    it 'correct table' do
      page.should have_table '#football-clubs-from-rio-de-janeiro-and-their-honors',
        [   'Club',    'World', 'Libertadores', 'Brasileiro', 'Copa do Brasil', 'Carioca'],
        [%w( Flamengo     1            1              6              2              32   ),
         %w( Vasco        0            1              4              1              22   ),
         %w( Fluminense   0            0              3              1              30   ),
         %w( Botafogo     0            0              1              0              19   )]
    end

    it 'vasco is not a world club champion' do
      expect {
        page.should have_table '#football-clubs-from-rio-de-janeiro-and-their-honors',
          [   'Club',    'World', 'Libertadores', 'Brasileiro', 'Copa do Brasil', 'Carioca'],
          [%w( Flamengo     1            1              6              2              32   ),
           %w( Vasco        1            1              4              1              22   ),
           %w( Fluminense   0            0              3              1              30   ),
           %w( Botafogo     0            0              1              0              19   )]
       }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
    end

    it 'supports tables without <thead> and <tbody>' do
      page.should have_table '#without-thead-tbody',
        %w( 1 2),
        [%w(3 4),
         %w(5 6)]
    end

    it 'supports tables without <th>' do
      page.should have_table '#without-th',
        [%w(1 2),
         %w(3 4),
         %w(5 6)]
    end
=begin
    it 'supports tables with different <th> and <td> number' do
      page.should have_table '#different-th-td-number',
        ['Name', 'City'],
        [
          ['Americano', 'Campos', 'Destroy'],
          ['Goytacaz', 'Campos', "You can't destroy this"]
        ]
    end
=end
  end
end
