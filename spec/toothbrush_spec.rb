require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Toothbrush" do
  before(:each) { visit '/dummy' }

  it 'talks to the dummy app' do
    page.should have_content "Hey, ho, let's go!"
  end

  describe 'ensures table content' do
    it 'correct table' do
      page.should include_table '#football-clubs-from-rio-de-janeiro-and-their-honors',
        [   'Club',    'World', 'Libertadores', 'Brasileiro', 'Copa do Brasil', 'Carioca'],
        [%w( Flamengo     1            1              6              2              32   ),
         %w( Vasco        0            1              4              1              22   ),
         %w( Fluminense   0            0              3              1              30   ),
         %w( Botafogo     0            0              1              0              19   )]
    end

    it 'vasco is not a world club champion' do
      expect {
        page.should include_table '#football-clubs-from-rio-de-janeiro-and-their-honors',
          [   'Club',    'World', 'Libertadores', 'Brasileiro', 'Copa do Brasil', 'Carioca'],
          [%w( Flamengo     1            1              6              2              32   ),
           %w( Vasco        1            1              4              1              22   ),
           %w( Fluminense   0            0              3              1              30   ),
           %w( Botafogo     0            0              1              0              19   )]
       }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
    end

    it 'supports tables without <thead> and <tbody>' do
      page.should include_table '#without-thead-tbody',
        %w( 1 2),
        [%w(3 4),
         %w(5 6)]
    end

    it 'supports tables without header' do
      page.should include_table '#without-th',
        [%w(1 2),
         %w(3 4),
         %w(5 6)]
    end

    it 'supports tables with different <th> and <td> number' do
      page.should include_table '#different-th-td-number',
        ['Name', 'City'],
        [
          ['Americano', 'Campos', 'Destroy'],
          ['Goytacaz', 'Campos', "You can't destroy this"]
        ]
    end

    it 'supports partial table' do
      page.should include_table '#football-clubs-from-rio-de-janeiro-and-their-honors',
          %w(    Club     World ),
          [%w( Flamengo     1   ),
           %w( Vasco        0   ),
           %w( Fluminense   0   ),
           %w( Botafogo     0   )]
    end

    it 'does not care about column ordering' do
      page.should include_table '#football-clubs-from-rio-de-janeiro-and-their-honors',
          %w(  World    Club    ),
          [%w(   1    Flamengo  ),
           %w(   0     Vasco    ),
           %w(   0   Fluminense ),
           %w(   0    Botafogo  )]
    end
  end
end
