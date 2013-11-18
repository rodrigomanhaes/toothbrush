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
       }.to raise_error(RSpec::Expectations::ExpectationNotMetError,
"""expected to include table
+------------+-------+--------------+------------+----------------+---------+
|    Club    | World | Libertadores | Brasileiro | Copa do Brasil | Carioca |
+------------+-------+--------------+------------+----------------+---------+
| Flamengo   | 1     | 1            | 6          | 2              | 32      |
| Vasco      | 1     | 1            | 4          | 1              | 22      |
| Fluminense | 0     | 0            | 3          | 1              | 30      |
| Botafogo   | 0     | 0            | 1          | 0              | 19      |
+------------+-------+--------------+------------+----------------+---------+
but found
+------------+-------+--------------+------------+----------------+---------+
|    Club    | World | Libertadores | Brasileiro | Copa do Brasil | Carioca |
+------------+-------+--------------+------------+----------------+---------+
| Flamengo   | 1     | 1            | 6          | 2              | 32      |
| Vasco      | 0     | 1            | 4          | 1              | 22      |
| Fluminense | 0     | 0            | 3          | 1              | 30      |
| Botafogo   | 0     | 0            | 1          | 0              | 19      |
+------------+-------+--------------+------------+----------------+---------+
""")
    end

    describe 'supports tables without <thead> and <tbody>' do
      it 'passing' do
        page.should include_table '#without-thead-tbody',
          %w( 1 2),
          [%w(3 4),
           %w(5 6)]
     end

     it 'failing' do
        expect {
          page.should include_table '#without-thead-tbody',
            %w( 1 2),
            [%w(3 4),
             %w(5 7)]
         }.to raise_error(RSpec::Expectations::ExpectationNotMetError,
"""expected to include table
+---+---+
| 1 | 2 |
+---+---+
| 3 | 4 |
| 5 | 7 |
+---+---+
but found
+---+---+
| 1 | 2 |
+---+---+
| 3 | 4 |
| 5 | 6 |
+---+---+
""")
     end
    end

    describe 'supports tables without header' do
      it 'passing' do
        page.should include_table '#without-th',
          [%w(1 2),
           %w(3 4),
           %w(5 6)]
      end

      it 'failing' do
        expect {
          page.should include_table '#without-th',
            [%w(1 2),
             %w(3 4),
             %w(6 6)]
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError,
"""expected to include table
+---+---+
| 1 | 2 |
| 3 | 4 |
| 6 | 6 |
+---+---+
but found
+---+---+
| 1 | 2 |
| 3 | 4 |
| 5 | 6 |
+---+---+
""")
      end
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
