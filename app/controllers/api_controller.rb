class ApiController < ApplicationController

  def ping
    respond_to do |format|
      format.json  { render :json => { "success": true, "response_status_code": 200 } }
    end
  end

  def posts
    require 'net/http'
    require 'json'
    require 'benchmark'

    sorted_array = []

    bm_result = Benchmark.measure do
      @posts = []
      @error_msg = []


      sortBy = ['id', 'reads', 'likes', 'popularity']
      direction = ['asc', 'desc']

      if params['sortBy']
        if sortBy.include?(params['sortBy'])
          sortBy = params['sortBy']
        else
          # Default value is 'id'
          sortBy = sortBy[0]
          @error_msg << "SortBy parameter is invalid"
        end
      else
        sortBy = sortBy[0]
        @error_msg << "SortBy parameter is required"
      end

      if params['direction']
        if direction.include?(params['direction'])
          direction = params['direction']
        else
          # Default is 'asc'
          direction = direction[0]
          @error_msg << "Direction parameter is invalid"
        end
      else
        @error_msg << "Direction parameter is required"
        direction = direction[0]
      end

      if params['tag']
        tags = params['tag'].strip

        tags.split(",").each do |tag|
          @posts = @posts.flatten
          api_endpoint = URI("https://api.hatchways.io/assessment/blog/posts?tag=#{tag}")
          results = JSON.parse(Net::HTTP.get(api_endpoint))["posts"]
          @posts.push(results)
        end

        # Flatten all posts
        @posts = @posts.flatten

        # Only unique objects in @posts
        @posts = @posts.uniq { |p| p["id"] }
      else
        @error_msg << "Tag parameter is required"
      end

      # Sort the array
      if direction == 'asc'
        case sortBy
        when "reads"
          sorted_array = @posts.sort_by{ |e| e['reads'].to_i }
        when "likes"
          sorted_array = @posts.sort_by{ |e| e['likes'].to_i }
        when "popularity"
          sorted_array = @posts.sort_by{ |e| e['popularity'].to_i }
        when "id"
          sorted_array = @posts.sort_by{ |e| e['id'].to_i }
        else
          sorted_array = @posts.sort_by{ |e| e['id'].to_i }
        end

      elsif direction == 'desc'
        case sortBy
        when "reads"
          sorted_array = @posts.sort_by{ |e| e['reads'].to_i }.reverse
        when "likes"
          sorted_array = @posts.sort_by{ |e| e['likes'].to_i }.reverse
        when "popularity"
          sorted_array = @posts.sort_by{ |e| e['popularity'].to_i }.reverse
        when "id"
          sorted_array = @posts.sort_by{ |e| e['id'].to_i }.reverse
        else
          sorted_array = @posts.sort_by{ |e| e['id'].to_i }.reverse
        end

      else
        @error_msg << "Could not sort the array - (asc or desc)"
      end

    end

    @posts = {
      "realtime_benchmark_s": bm_result.real.round(12),
      "posts_count": sorted_array.count,
      "posts": sorted_array
    }

    respond_to do |format|
      if not params['tag'].nil?
        format.json  { render :json => @posts }
      else
        format.json {
          render :json => {
            "error": @error_msg,
            "response_status_code": 400
          }
        }
      end
    end

  end
end
