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
    # categories = page.categories[0]
    has_many_choices = false
    page.categories.each {|val| has_many_choices = true unless val.index("曖昧") == nil }

    content = WikiCloth::Parser.new(data: page.content)
    @wiki_content = Sanitize.clean(content.to_html).gsub(/\n/, "").gsub(/\" \^/, "").gsub(/\"/, "")
    if @wiki_content.blank?
      @wiki_content = "Sorry, not found content."
      @wiki_content += " Please check the following link." unless page.content.blank?
    else
      if has_many_choices
        @wiki_content = "Returned many result. Please check the following link."
      else
        @wiki_content = "introduction:<br />" + @wiki_content[0..150].gsub(/[。]/, "。<br />") + "..."
      end
    end

    if page.content.blank?
      @wiki_link = "searched word:" + search_word
    else
      @wiki_link = "detail:<a href=http://ja.wikipedia.org/wiki/#{search_word}>#{@title}</a>"
    end

    render template: "search/index"
  end
end
