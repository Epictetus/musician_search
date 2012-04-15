# -*- encoding: utf-8 -*-
class SearchController < ApplicationController

  include SearchHelper

  def index

    @wiki = {}
    @youtube = {}
    # respond_to do |format|
      # format.html # index.html.erb
      # # format.json { render json: @posts }
    # end
  end

  def get_info
    @wiki = {}
    @youtube = {}

    return if params[:search_keys][:name].blank?
    search_at_wikipedia
    search_at_youtube

    # respond_to do |format|
       # format.js
       # # format.html
    # end
    # render

  end

  private

  def search_at_wikipedia
    search_word = params[:search_keys][:name]
    page = Wikipedia.find(search_word)
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
      @wiki[:link] = "詳細はこちら:<a href=http://ja.wikipedia.org/wiki/#{search_word}>#{@wiki[:title]}</a>"
    end

  end

  def search_at_youtube
    @youtube = {}

    search_word = params[:search_keys][:name]
    url = 'http://gdata.youtube.com/feeds/api/videos?vq='

    keywords = URI.encode(search_word)  # 検索キーワードを指定します
    options = '&orderby=published'

    uri = URI(url + keywords + options)

    doc = Nokogiri::XML(uri.read)
    # pp doc
    doc.search('entry').each do |entry|
      @youtube[:title] = entry.search('title').text
      @youtube[:contents] = entry.xpath('media:group/media:player').first['url']
    end
    # pp @youtube
  end
end
