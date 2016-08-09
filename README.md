# Softserver

Softserver is a web application framework written using Ruby metaprogramming and inspired by Rails functionality.  It provides users with a streamlined MVC structure within which their apps can process HTTP requests and render ERB templates; users can easily create their own lightweight servers (hence the name!) via Rack middleware, and can implement routers and cookies.  

More specifically, Softserver's features include:

##Server

Softserver uses Rack middleware to start a webserver and pass apps to it:

<pre><code>
app = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  ControllerBase.new(req, res).go
  res.finish
end

Rack::Server.start(
  app: app,
  Port: 3000
)
</code></pre>

##Controller

The controller handles requests, and uses binding to implement ERB template construction and evaluation:

<pre><code>
```ruby
def render(template_name)
  template_file = File.read(File.join("views", "#{self.class.to_s.underscore}", "#{template_name}.html.erb"))
  content = ERB.new(template_file).result(binding)
  render_content(content, "text/html")
end
```
</code></pre>

It also safeguards against double renders/redirects:

<pre><code>  
```ruby
  def already_built_response?
    @already_built_response == true
  end

  def redirect_to(url)
    if already_built_response?
      raise "Double render"
    else
      @res["Location"] = url
      @res.status = 302
      @already_built_response = true
      session.store_session(@res)
    end
  end

  def render_content(content, content_type)
    if already_built_response?
      raise "Double render"
    else
      @res.write(content)
      @res['Content-Type'] = content_type
      @already_built_response = true
      session.store_session(@res)
    end
  end
```
</code></pre>


##Router:

Softserver implements Regex-based route matching, including router methods corresponding to HTTP's "GET," "POST," "PATCH", and "DELETE" methods:

<pre><code>
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
</code></pre>

##Sessions

Softserver's HTTP responses include cookies to persist client information--including keeping track of the number of requests--serialized in JSON.

<pre><code>
def initialize(req)
  cookie_value = req.cookies["softserver_app"]
  @cookie_value = cookie_value ?  JSON.parse(cookie_value) : {}
end
</pre></code>
