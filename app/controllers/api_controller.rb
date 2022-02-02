class ApiController < ApplicationController

  def ping
    respond_to do |format|
      format.json  { render :json => { "success": true, "response_status_code": 200 } }
    end
  end

  def posts
    require 'net/http'
    require 'json'

    @posts = []

    sortBy = ['id', 'reads', 'likes', 'popularity']
    direction = ['asc', 'desc']

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

    if params['tag']
      tags = params['tag'].strip

      tags.split(",").each do |tag|
        @posts = @posts.flatten
        api_endpoint = URI("https://api.hatchways.io/assessment/blog/posts?tag=#{tag}&sortby=#{sortBy}&direction=#{direction}")
        results = JSON.parse(Net::HTTP.get(api_endpoint))["posts"]
        @posts.push(results)
      end
    end

    @posts = {
      "posts_count": @posts.count,
      "posts": @posts
    }

    respond_to do |format|
      format.json  { render :json => @posts }
    end

  end
end
