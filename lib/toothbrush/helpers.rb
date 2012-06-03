module Toothbrush
  module Helpers
    def ensure_table(table_selector, header_or_content, content = nil)
      if content.nil?
        return _ensure_table(table_selector, header_or_content)
      else
        header = header_or_content
      end

      columns = {}
      header.each do |title|
        n = 1
        while true do
          begin
            within("#{table_selector} thead tr th:nth-child(#{n})") do
              columns[title] = n if page.has_content?(title)
              n += 1
            end
          rescue Capybara::ElementNotFound
            begin
              within("#{table_selector} tr th:nth-child(#{n})") do
                columns[title] = n if page.has_content?(title)
                n += 1
              end
            rescue Capybara::ElementNotFound
              break
            end
          end
        end
      end

      columns.keys.should =~ header

      content.each_with_index do |celulas, index|
        celulas.each_with_index do |value, td_index|
          begin
            within("#{table_selector} tbody tr:nth-child(#{index+1}) td:nth-child(#{columns[header[td_index]]})") do
              page.should have_content(value)
            end
          rescue Capybara::ElementNotFound
            within("#{table_selector} tr:nth-child(#{index+2}) td:nth-child(#{columns[header[td_index]]})") do
              page.should have_content(value)
            end
          end
        end
      end
    end

    private

    def _ensure_table(selector, content)
      column_count = content[0].count
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
