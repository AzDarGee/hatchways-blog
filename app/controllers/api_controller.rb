class ApiController < ApplicationController
  def ping
    respond_to do |format|
      format.json  { render :json => { "success": true, "response_status_code": 200 } }
    end
  end
  def posts

    @posts = 

    respond_to do |format|
      format.json  { render :json => @posts }
    end
  end
end
