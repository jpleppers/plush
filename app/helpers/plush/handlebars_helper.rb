module Plush::HandlebarsHelper

  # Script tag for handlebars wrapper
  def handlebars_template name, &block
    content_tag :script, id: name, type: 'text/x-handlebars-template' do
      capture(&block)
    end
  end

  # Triple stash wrapper
  def tstash content
    "{{{#{content}}}}"
  end

  # Double stash wrapper
  def dstash content
    "{{#{content}}}"
  end

end
