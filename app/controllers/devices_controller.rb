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
      user_not_authenticated
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
      @sensor = Sensor.create(
        temperature: params["temperature"], 
        air_humidity_percentage: params["air_humidity_percentage"].to_f, 
        carbon_monoxide_level: params["carbon_monoxide_level"].to_f,
        device_health_status: params["device_health_status"],
        created_at: Time.now,
        device_id: params["device_id"],
        safe: params["carbon_monoxide_level"].to_f > 9 || device_health_status_to_check.include?(params["device_health_status"])  ? false : true
      )
      redirect to "/devices"
    end
  end

  # Create sensors for a device API
  post '/api/devices/send_sensors_info/:serial_number' do
    serial_number = params["serial_number"]
    body_params = JSON.parse request.body.read

    # Validation for a single sensor
    if (!body_params.is_a?(Array) && is_sensor_invalid?(body_params))
      result = {
        :message => "Pleae don't leave blank content"
      }
      return json(result)
    else
      check_user_logged_in(body_params)
      @device = Device.find_by!(serial_number: serial_number)

      # If the payload comes as a bulk of sensors
      if body_params.is_a?(Array) 
        body_params.each { |sensor| create_sensor(sensor, @device.id) }
      else
        create_sensor(body_params, @device.id)
      end

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
    sensors = Sensor.where("carbon_monoxide_level > ? or device_health_status in ('needs_service','needs_new_filter','gas_leak')", 9).where("safe = ?", false)
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

  def check_user_logged_in(params)
    unless logged_in?
      if params["creds"].blank?
        result = {
          :message => "You need to provide the field `creds` in order to create a sensor, using the following format Serial+Secret separated by the plus/+ sign, e.g 12345678+abcdef"
        }
        status 500
        return json(result)
      else
        creds = params["creds"]
        @user = User.find_by(username: creds)
        if @user && @user.authenticate(creds)
          session[:user_id] = @user.id
        else
          result = {
            :message => "The creds provided don't belong to any user in the system"
          }
          status 500
          return json(result)
        end
      end
    end
  end

  def user_not_authenticated
    result = {
      error: "We can't find you, Please try again"
    }
    status 500
    return json(result)
  end

  def is_sensor_invalid?(sensor_info)
      return sensor_info["temperature"].blank? ||
      sensor_info["air_humidity_percentage"].blank? ||
      sensor_info["carbon_monoxide_level"].blank? ||
      sensor_info["device_health_status"].blank? ||
      sensor_info["created_at"].blank?
  end

  def create_sensor(sensor_info, device_id)
    @sensor = Sensor.create(
      temperature: sensor_info["temperature"],
      air_humidity_percentage: sensor_info["air_humidity_percentage"],
      carbon_monoxide_level: sensor_info["carbon_monoxide_level"],
      device_health_status: sensor_info["device_health_status"],
      created_at: sensor_info["created_at"],
      safe: sensor_info["carbon_monoxide_level"] > 9 || device_health_status_to_check.include?(params["device_health_status"]) ? false : true,
      device_id: device_id
    )
  end

  def device_health_status_to_check
    ['needs_service','needs_new_filter','gas_leak']
  end

end
