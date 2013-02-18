# encoding: UTF-8
class VatsController < ApplicationController
  #before_filter :authorize, :except => :index

  def index
    @ic = params[:ic]
    if @ic
      redirect_to :action => :show, :id => @ic
    end
  end

  def list
    @alist = AresRegistration.all
  end

  def show
    @ic = params[:id]

    if ic_valid?
      @ares_reg = AresRegistration.find_by_ic(@ic)
      @ares_reg = AresRegistration.new({:ic => @ic}) unless @ares_reg
      @ares_reg.save()

      if @ares_reg.cz_payer?
        @adis_reg = AdisRegistration.find_by_dic(@ares_reg.dic)
        @adis_reg = AdisRegistration.new({:dic => @ares_reg.dic}) unless @adis_reg
        @adis_reg.save()
      end


    else
      flash[:notice] = "Zadané ič není validní"
      flash.keep
      redirect_to :action => :index
    end

  end

  def ic_valid?
    return false unless @ic
    ic_string = sprintf "%08s", @ic

    check = 0
    digits = ic_string.chars.to_a
    (0..6).each do |i|
      check = check + digits[i].to_i*(8-i)
    end

    check = check % 11
    last_digit = 11-check
    last_digit = 0 if check==1
    last_digit = 1 if check==0 || check==10

    last_digit.to_i == digits[7].to_i
  end
end
