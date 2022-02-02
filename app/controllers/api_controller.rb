class ApiController < ApplicationController
  def ping
    respond_to do |format|
      format.json  { render :json => { "success": true, "response_status_code": 200 } }
    end
  end
  def posts
    require 'net/http'

    sortBy = ['id', 'reads', 'likes', 'popularity']
    direction = ['asc', 'desc']

    if params['tag']
      tags = params['tag'].strip
    end

    if params['sortby']
      if sortBy.include?(params['sortby'])
        sortBy = params['sortby']
      else
        # Default value is 'id'
        sortBy = sortBy[0]
      end

    else
      sortBy = sortBy[0]
    end

    if params['direction']
      if direction.include?(params['direction'])
        direction = params['direction']
      else
        # Default is 'asc'
        direction = direction[0]
      end
    else
      direction = direction[0]
    end

    api_endpoint = URI("https://api.hatchways.io/assessment/blog/posts?tag=#{tags}&sortby=#{sortBy}&direction=#{direction}")

    @posts = Net::HTTP.get(api_endpoint)

    puts api_endpoint
    puts @posts

    respond_to do |format|
      format.json  { render :json => @posts }
    end
  end
end
