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
            within("#{table_selector} tbody tr:nth-child(#{row_index+1}) td:nth-child(#{cell_index+1})") do
              page.should have_content(cell)
            end
          rescue Capybara::ElementNotFound
            within("#{table_selector} tr:nth-child(#{row_index+2}) td:nth-child(#{cell_index+1})") do
              page.should have_content(cell)
            end
          end
        end
      end
    end

    private

    def _ensure_table(selector, content)
      content.each_with_index do |row, row_index|
        row.each_with_index do |cell_data, cell_index|
          within("#{selector} tr:nth-child(#{row_index + 1}) td:nth-child(#{cell_index + 1})") do
            page.should have_content cell_data
          end
        end
      end
    end
  end
end
