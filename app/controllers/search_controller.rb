# -*- encoding: utf-8 -*-
class SearchController < ApplicationController

  include SearchHelper

  def info
    @wiki = {}
    @youtube = {}
    @amazon = []

    return if params[:search_keys].blank? || params[:search_keys][:name].blank?
    search_at_wikipedia
    search_at_youtube
    search_at_amazon

    # respond_to do |format|
       # format.js
       # # format.html
    # end
  end

  private

  def search_at_wikipedia
    search_word = params[:search_keys][:name]
    keys = search_word.gsub(" ","+").gsub("　","+")
    page = Wikipedia.find(keys)
    @wiki[:title] = page.title
    has_many_choices = false
    page.categories.each {|val| has_many_choices = true unless val.index("曖昧") == nil } unless page.categories.blank?

    content = WikiCloth::Parser.new(data: page.content)
    @wiki[:content] = Sanitize.clean(content.to_html).gsub(/\n/, "").gsub(/\" \^/, "").gsub(/\"/, "")
    if @wiki[:content].blank?
      @wiki[:content] = "該当する情報は見つかりませんでした…"
      @wiki[:content] += " 下記のリンクより詳細をご確認ください。" unless page.content.blank?
    else
      if has_many_choices
        @wiki[:content] = "複数項目が該当しました。下記のリンクより詳細をご確認ください。"
      else
        @wiki[:content] = "<h3>#{@wiki[:title]}について:</h3>" + @wiki[:content][0..150].gsub(/[。]/, "。<br />") + "..."
      end
    end

    if page.content.blank?
      @wiki[:link] = "検索ワード:" + search_word
    else
      @wiki[:link] = "詳細はこちら:<a target='_blank' href=http://ja.wikipedia.org/wiki/#{search_word}>#{@wiki[:title]}</a>"
    end
  end

  def search_at_youtube
    @keywords = params[:search_keys][:name]
    @keywords = @keywords.gsub(" ","+").gsub("　","+")
    @youtube =  Youtube.video_info(@keywords)
  end

  def search_at_amazon
    require 'amazon/ecs'
    @amazon = []
    @keywords = params[:search_keys][:name]
    @keywords = @keywords.gsub(" ","+").gsub("　","+")

    res = Amazon::Ecs.item_search(@keywords, :search_index => 'All', country: 'jp')

    @item = {}
    res.items.each do |item|
      @amazon << { title: item.get("ItemAttributes/Title"), url: item.get("DetailPageURL"), category: item.get("ItemAttributes/ProductGroup") }
    end
  end

end
