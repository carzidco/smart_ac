#TODO: 
# Using something like GraphQL could solve the duplication about api and web endpoints
# Another nice solution could be create a base class that infer the request origin and get the result based on it
# Finally a cleaner way could be create a js interface like a ServiceBase.js file and hit the api via axios or fetch an standardized it using only API call for everything

class DevicesController < ApplicationController

  # List all Devices
  get '/devices' do
    if logged_in?
      @devices = Device.all
      erb :'devices/devices'
    else
      redirect_if_not_logged_in
    end
  end

  # List all Devices
  get '/api/devices' do
    if logged_in?
      devices = Device.all
      return json(devices)
    else
      redirect_if_not_logged_in
    end
  end

  # Get Device by Id
  get '/devices/:id' do
    if logged_in?
      @device = Device.find(params[:id])
      erb :'devices/show_device'
    else
      redirect_if_not_logged_in
    end
  end

  # Get Device by Id API
  get '/api/devices/:id' do
    if logged_in?
      device = Device.find(params[:id])
      return json(device)
    else
      redirect_if_not_logged_in
    end
  end

  # Create sensors for a device
  post '/devices/send_sensors_info/:serial_number' do
    if params[:description].empty? || params[:amount].empty? || params[:date].empty? || params[:category_name].empty?
      flash[:message] = "Please don't leave blank content"
      redirect to "/devices/new"
    else
      @user = current_user
      @category = @user.categories.find_or_create_by(name:params[:category_name])
      @category.user_id = @user.id
      @expense = Expense.create(description:params[:description], amount:params[:amount], date:params[:date], category_id:@category.id, user_id:@user.id)
      redirect to "/devices/#{@expense.id}"
    end
  end

  get '/devices/sensor/new' do
    if logged_in?
      @devices = Device.all
      erb :'/devices/create_sensor'
    else
      redirect_if_not_logged_in
    end
  end

  # Create a sensor for a device
  post '/devices/sensor' do
    if params[:temperature].empty? || params[:air_humidity_percentage].empty? || params[:carbon_monoxide_level].empty? || params[:device_health_status].empty?
      flash[:message] = "Please don't leave blank content"
      redirect to "/devices/sensor/new"
    else
      @expense = Sensor.create(
        temperature: params["temperature"], 
        air_humidity_percentage: params["air_humidity_percentage"].to_f, 
        carbon_monoxide_level: params["carbon_monoxide_level"].to_f,
        device_health_status: params["device_health_status"],
        created_at: Time.now,
        device_id: params["device_id"],
        safe: params["carbon_monoxide_level"].to_f > 9 ? false : true
      )
      redirect to "/devices"
    end
  end

  # Create sensors for a device API
  post '/api/devices/send_sensors_info/:serial_number' do
    serial_number = params["serial_number"]
    body_params = JSON.parse request.body.read
    if ( body_params["temperature"].blank? ||
      body_params["air_humidity_percentage"].blank? ||
      body_params["carbon_monoxide_level"].blank? ||
      body_params["device_health_status"].blank? ||
      body_params["created_at"].blank?
    )
    result = {
      :message => "Pleae don't leave blank content"
    }
    return json(result)
    else
      @user = current_user
      @device = Device.find_by!(serial_number: serial_number)
      @sensor = Sensor.create(
        temperature: body_params["temperature"],
        air_humidity_percentage: body_params["air_humidity_percentage"],
        carbon_monoxide_level: body_params["carbon_monoxide_level"],
        device_health_status: body_params["device_health_status"],
        created_at: body_params["created_at"],
        safe: body_params["carbon_monoxide_level"] > 9 ? false : true,
        device_id: @device.id
      )
      status 201
      result = {
        :message => "Sensors were recorded"
      }
      return json(result)
    end
  end

  # Getting Sensors by Device
  get '/devices/:serial_number/sensors' do
    if logged_in?
      @device = Device.find_by(serial_number: params["serial_number"])
      @sensors = @device.sensors
      erb :'devices/device_sensors'
    else
      redirect_if_not_logged_in
    end
  end

  # Getting Sensors by Device API
  get '/api/devices/:serial_number/sensors' do
    serial_number = params["serial_number"]
    sensors = Device.find_by(serial_number: serial_number).sensors
    return json(sensors)
  end

  get '/devices/sensors/alerts' do
    sensors = Sensor.where('carbon_monoxide_level > ?', 9).where('safe = ?', false)
    return json(sensors)
  end

  post '/devices/sensors/:id/set_safe' do
    sensor = Sensor.find(params[:id])
    sensor.safe = true
    sensor.save
    return json(sensor)
  end

  get '/sensors' do
    if logged_in?
      @sensors = Sensor.all
      erb :'devices/list_sensors'
    else
      redirect_if_not_logged_in
    end
  end
end
