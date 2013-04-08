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

    flag = 1
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

      if url
	    address=nil
		telephone=nil
		telephone_1=nil
		telephone_2=nil
		fax_1=nil
		fax_2=nil
		fax=nil
		email=nil
		website=nil
	    url=to_absolute(base_url, url)
        page = Nokogiri::HTML(open(url))
  	    content = page.search("#_content_")
	    content.search("//table//table//tr").each do |tr|
		  case tr.search("td[1]").text
	      when "辦 事 處 地 址"
		    address = tr.search("td[3]").text.strip
		  when "辦 事 處 電 話"
		    telephone = tr.search("td[3]").text.strip.delete(' ')
			telephone_1 = telephone.partition("/")[0].strip
			telephone_2 = (telephone.partition("/")[2].strip==""? nil : telephone.partition("/")[2].strip)
		  when "辦 事 處 傳 真"
		    fax = tr.search("td[3]").text.strip.delete(' ')
			fax_1 = fax.partition("/")[0].strip
			fax_2 = (fax.partition("/")[2].strip==""? nil :
			fax.partition("/")[2].strip)
		  when "電　　　　郵"
		    email = tr.search("td[3]").text.strip
		  when "網　　　　頁"
		    website = tr.search("td[3]").text.strip
	      end
	    end
	  end

      if image && name && url && region
      {
        name: name,
        image: to_absolute(base_url, image),
	    url: url,
        region: region,
		address: address,
		telephone_1: telephone_1,
		telephone_2: telephone_2,
		fax_1: fax_1,
		fax_2: fax_2,
		email: email,
		website: website
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
