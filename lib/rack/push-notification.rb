require 'rack'
require 'rack/contrib'

require 'sinatra/base'
require 'sinatra/param'

require 'sequel'

Sequel.extension(:pg_array, :migration)

module Rack
  class PushNotification < Sinatra::Base
    VERSION = '0.1.0'

    use Rack::PostBodyContentTypeParser
    helpers Sinatra::Param

    disable :raise_errors, :show_exceptions

    before do
      content_type :json
    end

    put '/devices/:token/?' do
      param :languages, Array
      param :tags, Array

      @record = Device.find(token: params[:token]) || Device.new
      @record.set(params)

      code = @record.new? ? 201 : 200

      if @record.save
        status code
        @record.to_json
      else
        status 406
        {errors: @record.errors}.to_json
      end
    end

    delete '/devices/:token/?' do
      @record = Device.find(token: params[:token]) or halt 404

      if @record.destroy
        status 200
      else
        status 406
        {errors: record.errors}.to_json
      end
    end
  end
end

require 'rack/push-notification/device'
require 'rack/push-notification/admin'
