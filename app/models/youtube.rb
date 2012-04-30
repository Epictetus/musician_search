# -*- encoding: utf-8 -*-
class Youtube < ActiveResource::Base
  self.site = "http://gdata.youtube.com"
  class Format
    include ActiveResource::Formats::JsonFormat
    def decode(json)
      super(json.gsub("$","_"))
    end
  end

  self.format = Format.new
  def self.videos(search_word)
    self.find(:one, from: "/feeds/api/videos", params: { q: search_word , :"max-results" => 10, alt: "json"} )
  end

  def self.video_info(search_word)
    videos = videos(search_word)
    list = []
    videos.feed.entry.each do |ent|
      v_info = {}
      v_info[:url] = ent.attributes["media_group"].attributes["media_content"][0].attributes["url"]
      v_info[:title] = ent.attributes["media_group"].attributes["media_title"].attributes["_t"]
      list << v_info
    end
    return list
  end
end
