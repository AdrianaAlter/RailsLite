# Softserver

Softserver is a web application framework written in Ruby and inspired by Rails functionality.  It provides users with a streamlined MVC structure within which their apps can process HTTP requests and render ERB templates; users can easily create their own lightweight servers (hence the name!) via Rack middleware, and can implement routers and cookies.  

Other Softserver features include:

--Controller methods:
  #initialize
  #redirect_to
  #render_content(content, content_type)
  #render(template_name)
  #session
  #invoke_action
  
--Controller safeguards against double renders/redirects
  
--Regex-based route matching, including router methods corresponding to HTTP's "GET," "POST," "PATCH", and "DELETE" methods

--ERB template construction and evaluation (using binding)


In future, Softserver will also incorporate its own lightweight version of ActiveRecord!
