require 'rspec/expectations'
require 'text-table'

RSpec::Matchers.define :include_table do |selector, *header_content|
  match do |actual|
    if header_content.count == 2
      header_or_content = header_content[0]
      if header_or_content[0].is_a? Array
        expected_content, expected_foot = header_content
      else
        expected_header, expected_content = header_content
      end
    elsif header_content.count == 3
      expected_header, expected_content, expected_foot = header_content.map(&:clone)
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

    has_tfoot = lambda do
      actual.has_selector?("#{selector} tfoot")
    end

    has_header = lambda do
      has_thead[] || actual.has_selector?("#{selector} tr th")
    end

    expected_has_header = lambda do
      expected_header && !expected_header.empty?
    end

    html_foot = lambda { actual.all("#{selector} tfoot tr td").map(&:text) }

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

      body.push(html_foot[]) if has_tfoot[]

      body.to_table(first_row_is_head: has_header[],
        last_row_is_foot: has_tfoot[]).to_s
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

    check_foot = lambda do
      return true unless expected_foot
      return false if expected_foot && !has_tfoot[]
      if !column_equivalence.empty?
        columns = column_equivalence.sort_by {|k, v| k }.map {|(k, v)| v }
        foot_values = html_foot[]
        foot_to_compare = columns.map {|index| foot_values[index] }
      else
        foot_to_compare = html_foot[]
      end
      foot_to_compare == expected_foot
    end

    result = check_selector[] && check_header[] && check_content[] && check_foot[]
    if !result
      if !check_selector[]
        @message = "expected to have selector '#{selector}'"
      else
        expected_table = expected_content.clone
        if expected_header
          expected_header << '' while expected_header.size < expected_table.first.size
          expected_table.unshift(expected_header)
        end

        expected_table.push(expected_foot) if expected_foot

        @message = "expected to include table\n%sbut found\n%s" %
          [expected_table.to_table(
            first_row_is_head: expected_has_header[],
            last_row_is_foot: !!expected_foot),
          html_table_to_array[]]
      end
    end
    result
  end

  class << self
    alias :failure_message :failure_message_for_should
  end unless respond_to? :failure_message

  failure_message do |actual|
    @message
  end
end
