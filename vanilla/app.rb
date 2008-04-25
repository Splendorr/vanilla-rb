require 'vanilla'
require 'vanilla/request'

module Vanilla
  class App
    
    attr_reader :request
    
    def initialize(request)
      @request = request
    end

    # Params should be the HTTP query parameters as a symbolized Hash, 
    # but can/should include:
    #   :snip => the name of the snip [REQUIRED]
    #   :part => the part of the snip to show [OPTIONAL]
    #   :format => the format to render [OPTIONAL]
    #   :method => GET/POST/DELETE/PUT [OPTIONAL]
    #
    def present
      puts "presenting: #{request.format}"
      case request.format
      when 'html', nil
        Renderers::Erb.new(self).render(Vanilla.snip('system'), :main_template)
      when 'raw'
        Renderers::Raw.new(self).render(request.snip, request.part || :content)
      when 'text'
        render(request.snip, request.part || :content)
      else
        "Unknown format '#{request.format}'"
      end
    end

    # render a snip using either the renderer given, or the renderer
    # specified by the snip's "render_as" property, or Render::Base
    # if nothing else is given.
    def render(snip, part=:content, args=[])
      rendering(snip) do |r|
        r.render(snip, part, args)
      end
    end

    # Render a snip using its given renderer, but do not perform any snip
    # inclusion. I.e., ignore {snip arg} blocks of text in the snip content.
    def render_without_including_snips(snip, part=:content, args=[])
      rendering(snip) do |r|
        r.render_without_including_snips(snip, part, args)
      end
    end

    # Returns the renderer class for a given snip
    def renderer_for(snip)
      return Renderers::Base unless snip.render_as
      Vanilla::Renderers.const_get(snip.render_as)
    end

    # Given the snip and parameters, yield the appropriate Vanilla::Render::Base subclass
    # instance
    def rendering(snip)
      renderer_instance = renderer_for(snip).new(self)
      yield renderer_instance
    rescue Exception => e
      "<pre>[Error rendering '#{snip.inspect}' - \"" + 
        e.message.gsub("<", "&lt;").gsub(">", "&gt;") + "\"]\n" + 
        e.backtrace.join("\n").gsub("<", "&lt;").gsub(">", "&gt;") + "</pre>"
    end
    
  end
end