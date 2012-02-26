# -*- encoding: utf-8 -*-
class SearchController < ApplicationController

  def index 
    @title = ""
    @wiki_content = ""
    @wiki_link = ""
    respond_to do |format|
      format.html # index.html.erb
      # format.json { render json: @posts }
    end
  end

  def get_wiki
    search_word = params[:search_keys][:name] 
    page = Wikipedia.find(search_word)
    @title = page.title
    has_many_choices = false
    page.categories.each {|val| has_many_choices = true unless val.index("曖昧") == nil } unless page.categories.blank?

    content = WikiCloth::Parser.new(data: page.content)
    @wiki_content = Sanitize.clean(content.to_html).gsub(/\n/, "").gsub(/\" \^/, "").gsub(/\"/, "")
    if @wiki_content.blank?
      @wiki_content = "該当する情報は見つかりませんでした…"
      @wiki_content += " 下記のリンクより詳細をご確認ください。" unless page.content.blank?
    else
      if has_many_choices
        @wiki_content = "複数項目が該当しました。下記のリンクより詳細をご確認ください。"
      else
        @wiki_content = "<h3>#{@title}について:</h3>" + @wiki_content[0..150].gsub(/[。]/, "。<br />") + "..."
      end
    end

    if page.content.blank?
      @wiki_link = "検索ワード:" + search_word
    else
      @wiki_link = "詳細はこちら:<a href=http://ja.wikipedia.org/wiki/#{search_word}>#{@title}</a>"
    end

    render template: "search/index"
  end
end
