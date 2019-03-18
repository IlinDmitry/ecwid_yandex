require "ecwid_yandex/version"
require 'csv'
require 'nokogiri'
require 'pry'


module EcwidYandex
  extend self

  class FileForReading
    def initialize(name, ext)
      @file = "#{Dir.pwd}/public/#{name}.#{ext}"
    end
  end

  class CSVData < FileForReading

    def read_csv
      ar = []
      csv_text = File.read(@file)
      csv = CSV.parse(csv_text, headers: true, col_sep: ';')
      csv.each do |row|
        ar << [row.to_hash['sku'], row.to_hash['name']]
      end
      return ar
    end
  end

  class XMLdata < FileForReading

    def read_xml(new_name, array)
      xml_file = File.read(@file)
      xml = Nokogiri::XML(xml_file)
      xml2 = xml.dup
      xml2.xpath('//offer').each(&:remove)
      xml2.xpath('//offers').each do |elem|
        array.each do |ar|
          price = nil
          oldprice = nil
          elem_parent = nil
          delivery = nil
          elem_child = xml.xpath("//offers//offer[vendorCode='#{ar[0]}']")

          if elem_child.count == 0
            elem_child = xml.xpath("//offers//offer[name='#{ar[1]}']")
            elem_parent = elem.xpath("//offers//offer[name='#{ar[1]}']")
          end

          if elem_child.count == 0 && elem_parent.count == 1
            next
          elsif elem_child.count == 0 && elem_parent.count == 0
            binding.pry
            p ar[1]
          end

          elem_child.children.each do |child|
            case child.name
            when "price"
              price = child
            when "oldprice"
              oldprice = child
            when "delivery"
              delivery = child
            end
          end
          unless delivery.nil?
          delivery.content = "true"
          else
            elem_child[0].add_child("<delivery>true</delivery>")
          end
          unless oldprice.nil?
            if price.child.text.to_f > oldprice.child.text.to_f
              oldprice.remove
            end
          end
          begin
            elem_child[0].add_child("<country_of_origin>Китай</country_of_origin>")
          rescue => detail
            p ar
            p detail.backtrace.join("\n")
          end
          elem << elem_child
        end
      end
      File.write("#{Dir.pwd}/public/#{new_name}.xml", xml2.to_xml)

    end

  end

  def start
    csv = CSVData.new('order', 'csv')

    xml_file = XMLdata.new('yandex', 'xml')
    xml_file.read_xml('yandex2', csv.read_csv)

  end
  # csv.read_csv
end
