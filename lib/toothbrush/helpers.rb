require 'rspec/expectations'
require 'text-table'

RSpec::Matchers.define :include_table do |selector, *header_content|
  match do |actual|
    if header_content.count == 2
      expected_header, expected_content = header_content.map(&:clone)
    else
      expected_header, expected_content = nil, header_content[0].clone
    end

    check_selector = lambda do
      actual.has_selector?(selector)
    end

    has_thead = lambda do
      actual.has_selector?("#{selector} thead")
    end

    has_tbody = lambda do
      actual.has_selector?("#{selector} tbody")
    end

    has_header = lambda do
      has_thead[] || actual.has_selector?("#{selector} tr th")
    end

    expected_has_header = lambda do
      expected_header && !expected_header.empty?
    end

    html_table_to_array = lambda do
      if has_thead[]
        header = actual.all("#{selector} thead tr th").map(&:text)
        header = actual.all("#{selector} thead tr td").map(&:text) if header.empty?
      elsif has_header[]
        header = actual.first("#{selector} tr").all('th').map(&:text)
        header = actual.first("#{selector} tr").all('td').map(&:text) if header.empty?
      end
      body_rows = if has_tbody[]
        actual.all("#{selector} tbody tr")
      elsif has_header[]
        actual.all("#{selector} tr")[1..-1]
      else
        actual.all("#{selector} tr")
      end
      body = body_rows.map {|tr| tr.all('td').map(&:text) }
      if header && !header.empty?
        body_size = body.first ? body.first.size : 0
        header << '' while header.size < body_size
        body.unshift(header)
      end
      body.to_table(first_row_is_head: has_header[]).to_s
    end

    column_equivalence = {}

    check_header = lambda do
      return true unless expected_header

      check_header_content = lambda do |*header_selector|
        columns = {}
        sub_selector = header_selector.empty? ? '' : header_selector[0]
        first_row = actual.all("#{selector} #{sub_selector} tr")[0]
        if first_row
          first_row.
            all("th, td").
            each_with_index {|td, index| columns[td.text] = index }
          expected_header.each_with_index do |title, index|
            column_equivalence[index] = columns[title] if columns.has_key? title
          end
          expected_header.all? {|title| columns.has_key? title }
        else
          expected_header.empty?
        end
      end

      (has_thead[] && check_header_content.('thead')) ||
      (!has_thead[] && check_header_content[])
    end

    check_content = lambda do
      check_body_content = lambda do |sub_selector_or_flag|
        if sub_selector_or_flag.is_a? Symbol
          sub_selector, exclude_first_line = '', sub_selector_or_flag == :exclude_first_line
        else
          sub_selector, exclude_first_line = sub_selector_or_flag, false
        end
        trs = actual.all("#{selector} #{sub_selector} tr").to_a
        trs.shift if exclude_first_line
        expected_content.map.with_index {|row, row_index|
          tds = trs[row_index].all('td')
          row.map.with_index {|data, col_index|
            tds[column_equivalence[col_index] || col_index].has_content? data
          }.all?
        }.compact.all?
      end

      if has_tbody[]
        check_body_content.('tbody')
      elsif has_header[]
        check_body_content.(:exclude_first_line)
      else
        check_body_content.('')
      end
    end

    result = check_selector[] && check_header[] && check_content[]
    if !result
      if !check_selector[]
        @message = "expected to have selector '#{selector}'"
      else
        expected_table = expected_content.clone
        if expected_header
          expected_header << '' while expected_header.size < expected_table.first.size
          expected_table.unshift(expected_header)
        end
        @message = "expected to include table\n%sbut found\n%s" %
          [expected_table.to_table(first_row_is_head: expected_has_header[]),
          html_table_to_array[]]
      end
    end
    result
  end

  failure_message_for_should do |actual|
    @message
  end
end
