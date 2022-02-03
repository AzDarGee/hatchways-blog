# Setup Steps

1. Navigate to the root of the Ruby on Rails Blog and in a terminal execute `rails server`.
2. Go to the end-point `http://localhost:3000/api/posts?tag=tech,health&sortBy=likes&direction=asc`.
3. To Test:
   1. `rails test -b test/controllers/api_controller_test.rb`

**Extras**
* Concurrent api calls added to speed up requests
* Caching
