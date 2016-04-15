class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern = pattern
    @http_method = http_method
    @controller_class = controller_class
    @action_name = action_name
  end

  def matches?(req)
    (@http_method.to_s.upcase == req.request_method) && (@pattern =~ req.path)
  end

  def run(req, res)
    params = {}
    match_data = pattern.match(req.path)
    match_data.names.each { |name| params[name] = match_data[name] }
    @controller_class.new(req, res, params).invoke_action(@action_name)
  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  def add_route(pattern, method, controller_class, action_name)
    @routes << Route.new(pattern, method, controller_class, action_name)
  end

  def draw(&proc)
    self.instance_eval(&proc)
  end

  [:get, :post, :put, :delete].each do |http_method|
    define_method(http_method) do |pattern, controller_class, action_name|
      self.add_route(pattern, http_method, controller_class, action_name)
    end
  end

  def match(req)
    route = (@routes.select { |route| route.matches?(req) })
    route.empty? ? nil : route
  end

  def run(req, res)
    route = match(req)
    route.nil? ? res.status = 404 : route.run(req, res)
  end
end
