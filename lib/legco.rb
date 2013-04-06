# encoding: utf-8

require 'mechanize'
require 'nokogiri'
require 'open-uri'

module Legco
  module_function

  def members
    a = Mechanize.new
    a.get('http://www.legco.gov.hk/general/chinese/members/index.html') do |page|
      a.click(page.link_with(:text => %r{議員履歷}))
    end

    doc = a.page
    base_url = doc.uri.to_s
    doc.search(".bio-member-info").collect do |node|
      image = node.search("img/@src").text rescue nil
      member_node = node.search("strong a").first
      region =node.search(".size2").text.strip[1..-3] rescue nil

      if member_node
        url = member_node.attribute("href").text
        name = member_node.text.strip[/^(.+)議員.*/, 1] rescue nil
      end
      
      if image && name && url && region
        {

          name: name,
          image: to_absolute(base_url, image),
          url: to_absolute(base_url, url),
          region: region
        }
      else
      	nil
      end

    end.compact
  end
  
  def to_absolute(root, href)
  	URI.join(root, href).to_s
  end
end
