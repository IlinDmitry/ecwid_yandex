require "ecwid_yandex/version"
require 'csv'
require 'nokogiri'


module EcwidYandex
  extend self

  class FileForReading
    def initialize(name, ext)
      @file = "#{Dir.pwd}/public/#{name}.#{ext}"
    end
  end

  class CSVData < FileForReading

    def read_csv
      csv_text = File.read(@file)
      csv = CSV.parse(csv_text, headers: true, col_sep: ';')
      csv.each do |row|
        p row.to_hash['sku']
      end
    end
  end

  class XMLdata < FileForReading

  end

  def start
    csv = CSVData.new('order', 'csv')
    csv.read_csv

    xml = XMLdata.new('yandex','xml')

  end
  # csv.read_csv
end
