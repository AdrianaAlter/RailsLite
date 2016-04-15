require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require 'active_support/inflector'
require 'byebug'

class ControllerBase
  attr_reader :req, :res, :params

  def initialize(req, res, params = {})
    @req = req
    @res = res
    @params = @req.params.merge(params)
    @already_built_response = false
  end

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

  def render(template_name)
    template_file = File.read(File.join("views", "#{self.class.to_s.underscore}", "#{template_name}.html.erb"))
    content = ERB.new(template_file).result(binding)
    render_content(content, "text/html")
  end

  def session
    @session ||= Session.new(@req)
  end

  def invoke_action(name)
    self.send(name)
    self.render(name) unless already_built_response?
  end
end
