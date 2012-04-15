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
end
