require 'json'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    cookie_value = req.cookies["_rails_lite_app"]
    @cookie_value = cookie_value ?  JSON.parse(cookie_value) : {}
  end

  def [](key)
    @cookie_value[key]
  end

  def []=(key, val)
    @cookie_value[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    res.set_cookie("_rails_lite_app", { :path => "/", :value => @cookie_value.to_json })
  end
end
