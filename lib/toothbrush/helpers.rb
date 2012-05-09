module Toothbrush
  module Helpers
    def ensure_table(table_selector, header, content)
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
            break
          end
        end
      end

      columns.keys.should =~ header

      content.each_with_index do |celulas, index|
        celulas.each_with_index do |value, td_index|
          within("#{table_selector} tbody tr:nth-child(#{index+1}) td:nth-child(#{columns[header[td_index]]})") do
            page.should have_content(value)
          end
        end
      end
    end
  end
end
