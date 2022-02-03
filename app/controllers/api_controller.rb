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
    require 'thread'

    sorted_array = []
    sequential_duration = 0
    concurrent_duration = 0

    bm_result = Benchmark.measure do
      @posts = []
      @posts_con = []
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
        tag_count = tags.split(",").count
        @posts = @posts.flatten
        @posts_con = @posts_con.flatten

        # If only 1 tag is inputted
        if tag_count == 1
          api_endpoint = URI("https://api.hatchways.io/assessment/blog/posts?tag=#{tags}")
          results = JSON.parse(Net::HTTP.get(api_endpoint))["posts"]
          @posts.push(results)
        else
          def now
            Process.clock_gettime(Process::CLOCK_MONOTONIC)
          end
          start_sequential = now
          # If multiple tags are inputted, make a sequential request
          tags.split(",").each do |tag|
            api_endpoint = URI("https://api.hatchways.io/assessment/blog/posts?tag=#{tag}")
            results = JSON.parse(Net::HTTP.get(api_endpoint))["posts"]
            @posts.push(results)
          end
          finish_sequential = now
          sequential_duration = (finish_sequential - start_sequential).round(12)

          start_concurrent = now
          # If multiple tags are inputted, make a concurrent request
          tags.split(",").each do |tag|
            Thread.new do
              api_endpoint = URI("https://api.hatchways.io/assessment/blog/posts?tag=#{tag}")
              results = JSON.parse(Net::HTTP.get(api_endpoint))["posts"]
              @posts_con.push(results)
            end
          end
          finish_concurrent = now
          concurrent_duration = (finish_concurrent - start_concurrent).round(12)

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
      "sequential_requests_s": sequential_duration,
      "concurrent_requests_s": concurrent_duration,
      "posts_count": sorted_array.count,
      "posts": sorted_array
    }

    respond_to do |format|
      if @error_msg.empty?
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
