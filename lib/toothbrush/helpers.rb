RSpec::Matchers.define :have_table do |selector, *header_content|
  match do |actual|
    if header_content.count == 2
      header, content = header_content
    else
      header, content = nil, header_content[0]
    end
    @errors = []

    check_selector = lambda do
      check(:no_selector) { actual.has_selector?(selector) }
    end

    check_header = lambda do
      return true unless header
      has_thead = lambda do
        actual.has_selector?("#{selector} thead")
      end

      check_header_content = lambda do |*header_selector|
        sub_selector = header_selector.empty? ? '' : header_selector[0]
        header_line = actual.all("#{selector} #{sub_selector} tr")[0].
          all("th, td").map.with_index {|td, index|
            td.has_content? header[index]
          }.all?
      end

      (has_thead[] && check_header_content.('thead')) ||
      (!has_thead[] && check_header_content[])
    end

    check_content = lambda do
      has_tbody = lambda do
        actual.has_selector?("#{selector} tbody")
      end

      check_body_content = lambda do |sub_selector_or_flag|
        if sub_selector_or_flag.is_a? Symbol
          sub_selector, exclude_first_line = '', sub_selector_or_flag == :exclude_first_line
        else
          sub_selector, exclude_first_line = sub_selector_or_flag, false
        end
        trs = actual.all("#{selector} #{sub_selector} tr").to_a
        trs.shift if exclude_first_line
        content.map.with_index {|row, row_index|
          tds = trs[row_index].all('td')
          row.map.with_index {|data, col_index|
            tds[col_index].has_content? data
          }.all?
        }.compact.all?
      end

      (has_tbody[] && check_body_content.('tbody')) ||
      (!has_tbody[] && check_body_content.(:exclude_first_line))
    end

    check_selector[] && check_header[] && check_content[]
  end

  def check(error)
    if yield
      true
    else
      @errors << error
      false
    end
  end
end