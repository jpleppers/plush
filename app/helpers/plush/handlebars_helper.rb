module Plush::HandlebarsHelper
  def handlebars_template name, &block
    content_tag :script, id: name, type: 'text/x-handlebars-template' do
      capture(&block)
    end
  end

  def tstash content
    "{{{#{content}}}}"
  end

  def dstash content
    "{{#{content}}}"
  end

end
