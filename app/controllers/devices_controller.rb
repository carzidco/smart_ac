class DevicesController < ApplicationController

  get '/devices' do
    if logged_in?
      @devices = Device.all
      erb :'devices/devices'
    else
      redirect_if_not_logged_in
    end
  end

  get '/devices/:id' do
    if logged_in?
      @device = Device.find(params[:id])
      erb :'devices/show_device'
    else
      redirect_if_not_logged_in
    end
  end

end
