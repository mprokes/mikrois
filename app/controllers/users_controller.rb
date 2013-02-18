# encoding: UTF-8
class UsersController < ApplicationController
  def new
    @user = User.new
  end
  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "Registrace byla úspěšná"
    else
      flash[:notice] = "Údaje jsou neplatné"
    end
    render "new"
  end


end
