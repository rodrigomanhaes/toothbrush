module Toothbrush
  module Helpers
    def ensure_table(table_selector, header_or_content, content = nil)
      if content.nil?
        return _ensure_table(table_selector, header_or_content)
      else
        header = header_or_content
      end

      content.each_with_index do |row, row_index|
        row.each_with_index do |cell, cell_index|
          begin
            lines = all("#{table_selector} tbody tr")[row_index]
            if lines
              if !lines.all('td')[cell_index].has_content?(cell)
                raise RSpec::Expectations::ExpectationNotMetError.new(
                  'expected column %s, row %s to have content "%s"' % [
                    cell_index+1, row_index+1, cell])
              end
            else
              raise Capybara::ElementNotFound
            end
          rescue Capybara::ElementNotFound
            lines = all("#{table_selector} tr")[row_index+1]
            if lines
              lines.all('td')[cell_index].should have_content(cell)
            else
              raise Capybara::ElementNotFound
            end
          end
        end
      end
    end

    private

    def _ensure_table(selector, content)
      content.each_with_index do |row, row_index|
        row.each_with_index do |cell_data, cell_index|
          lines = all("#{selector} tr")[row_index]
          if lines
            lines.all('td')[cell_index].should have_content cell_data
          else
            raise Capybara::ElementNotFound
          end
        end
      end
    end
  end
end
