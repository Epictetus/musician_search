# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Youtube do
  context "youtubeで「サッカー」を検索したとき" do
    it "結果が返される" do
      Youtube.video_info("サッカー").should_not == nil
    end
    it "タイトルとURLが返される" do
      list = Youtube.video_info("サッカー")
      list[0][:title].blank?.should_not == true
      list[0][:url].blank?.should_not == true
    end
  end
end

