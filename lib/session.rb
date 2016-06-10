require 'json'

class Session

  def initialize(req)
    cookie_value = req.cookies["_softserver_app"]
    @cookie_value = cookie_value ?  JSON.parse(cookie_value) : {}
  end

  def [](key)
    @cookie_value[key]
  end

  def []=(key, val)
    @cookie_value[key] = val
  end

  def store_session(res)
    res.set_cookie("_softserver_app", { :path => "/", :value => @cookie_value.to_json })
  end

end
