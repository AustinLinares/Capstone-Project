# frozen_string_literal: true

require "httparty"

class SubscribersController < ApplicationController
  # GET /subscribers or /subscribers.json
  def index
    @subscribers = Subscriber.all
    @preferences = Preference.all
  end

  # GET /subscribers/new
  def new
    @preferences = Preference.all
    @subscriber = Subscriber.new
  end

  # POST /subscribers or /subscribers.json
  def create
    @preferences = Preference.all
    @subscriber = Subscriber.new(email: subscriber_params["email"])

    @preferences.each do |preference|
      @subscriber.preferences << preference if subscriber_params[preference.name].eql?("1")
    end

    if @subscriber.save
      ConfirmationMailer.subscription(@subscriber).deliver_now
      flash[:notice] = I18n.t("activerecord.success.messages.created")
      redirect_to new_subscriber_path(I18n.locale), status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_subscriber
    @subscriber = Subscriber.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def subscriber_params
    params.require(:subscriber).permit(:email, :women, :men, :children)
  end
end
