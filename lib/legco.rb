# encoding: utf-8
require 'nokogiri'
require 'open-uri'

module Legco
  module_function
  LEGCO_BIO_URL = "http://www.legco.gov.hk/general/chinese/members/yr12-16/biographies.htm"
  def members
    doc = Nokogiri::HTML(open(LEGCO_BIO_URL))
    doc.search("#_content_ ul table tr td").collect do |node|
      image = node.search("img/@src").first.text rescue nil
      member_node = node.search("strong a").first
      region = node.search("span.size2").text.strip[/\(([^\+\*]+)[\+\*]?\)/, 1] rescue nil

      if member_node
        url = member_node.attribute("href").text
        name = member_node.text.strip[/^(.+)議員.*/, 1] rescue nil
      end
      
      if image && name && url && region
        {
          name: name,
          image: to_absolute(LEGCO_BIO_URL, image),
          url: to_absolute(LEGCO_BIO_URL, url),
          region: region
        }
      else
        nil
      end
    end.compact
  end
  
  def to_absolute(root, href)
     URI.parse(root).merge(URI.parse(href)).to_s
  end
end