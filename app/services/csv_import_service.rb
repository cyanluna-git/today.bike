require "csv"

class CsvImportService
  CUSTOMER_COLUMNS = %w[name phone email memo].freeze
  BICYCLE_COLUMNS = %w[customer_phone brand model_label year bike_type frame_number color].freeze

  attr_reader :file, :import_type

  def initialize(file, import_type)
    @file = file
    @import_type = import_type.to_s
  end

  def call
    result = { created: 0, skipped: 0, errors: [] }

    content = read_file_content
    return result.merge(errors: ["ファイルを読み込めませんでした。"]) if content.nil?

    csv = CSV.parse(content, headers: true, skip_blanks: true)

    case import_type
    when "customers"
      import_customers(csv, result)
    when "bicycles"
      import_bicycles(csv, result)
    else
      result[:errors] << "Unknown import type: #{import_type}"
    end

    result
  end

  private

  def read_file_content
    raw = if file.respond_to?(:read)
      file.read
    elsif file.respond_to?(:path)
      File.read(file.path)
    else
      file.to_s
    end

    # Handle BOM and encoding
    encode_to_utf8(raw)
  rescue => e
    nil
  end

  def encode_to_utf8(raw)
    # Remove UTF-8 BOM if present
    raw = raw.b
    raw = raw.sub("\xEF\xBB\xBF".b, "".b)

    # Try UTF-8 first
    content = raw.dup.force_encoding("UTF-8")
    return content if content.valid_encoding?

    # Try Shift_JIS
    begin
      return raw.dup.force_encoding("Shift_JIS").encode("UTF-8")
    rescue Encoding::UndefinedConversionError, Encoding::InvalidByteSequenceError
      # fall through
    end

    # Try CP949 (Korean)
    begin
      return raw.dup.force_encoding("CP949").encode("UTF-8")
    rescue Encoding::UndefinedConversionError, Encoding::InvalidByteSequenceError
      # fall through
    end

    # Force UTF-8 replacing invalid chars
    raw.dup.force_encoding("UTF-8").encode("UTF-8", invalid: :replace, undef: :replace, replace: "?")
  end

  def import_customers(csv, result)
    csv.each_with_index do |row, index|
      row_number = index + 2 # 1-indexed header + 1-indexed data
      name = row["name"]&.strip
      phone = row["phone"]&.strip

      if name.blank? || phone.blank?
        result[:errors] << "Row #{row_number}: name and phone are required"
        next
      end

      # Duplicate check by phone
      if Customer.exists?(phone: phone)
        result[:skipped] += 1
        next
      end

      customer = Customer.new(
        name: name,
        phone: phone,
        email: row["email"]&.strip.presence,
        memo: row["memo"]&.strip.presence
      )

      if customer.save
        result[:created] += 1
      else
        result[:errors] << "Row #{row_number}: #{customer.errors.full_messages.join(', ')}"
      end
    end
  end

  def import_bicycles(csv, result)
    csv.each_with_index do |row, index|
      row_number = index + 2
      customer_phone = row["customer_phone"]&.strip
      brand = row["brand"]&.strip
      model_label = row["model_label"]&.strip

      if customer_phone.blank? || brand.blank? || model_label.blank?
        result[:errors] << "Row #{row_number}: customer_phone, brand, and model_label are required"
        next
      end

      customer = Customer.find_by(phone: customer_phone)
      unless customer
        result[:errors] << "Row #{row_number}: customer with phone #{customer_phone} not found"
        next
      end

      bike_type = row["bike_type"]&.strip.presence || "road"
      unless Bicycle.bike_types.key?(bike_type)
        result[:errors] << "Row #{row_number}: invalid bike_type '#{bike_type}'"
        next
      end

      bicycle = Bicycle.new(
        customer: customer,
        brand: brand,
        model_label: model_label,
        year: row["year"]&.strip.presence&.to_i,
        bike_type: bike_type,
        frame_number: row["frame_number"]&.strip.presence,
        color: row["color"]&.strip.presence
      )

      if bicycle.save
        result[:created] += 1
      else
        result[:errors] << "Row #{row_number}: #{bicycle.errors.full_messages.join(', ')}"
      end
    end
  end
end
