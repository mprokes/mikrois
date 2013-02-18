# encoding: UTF-8
class AuditsController < ApplicationController

  def news
    @news_list = Audit.limit(30).reorder('').order("created_at DESC")
  end

end
