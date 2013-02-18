# encoding: UTF-8
class SessionsController < ApplicationController
  def create
    user = User.find_by_email(params[:email])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      Notifier.welcome(user).deliver
      redirect_to root_url, :notice => "Přihlášení bylo úspěšné"
    else
      flash.now.alert = "Chybný email nebo heslo"
      render "new"
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, :notice => "Byl jste úspěšně odhlášen!"
  end


end
