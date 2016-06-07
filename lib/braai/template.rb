class Braai::Template
  extend Braai::Matchers
  include Braai::Matchers

  attr_accessor :template

  def initialize(template, matchers = {})
    @matchers = self.class.matchers.merge(matchers)
    @template = template
    @fallback = self.class.fallback
  end

  def render(attributes = {}, apply_matchers = {})
    context = Braai::Context.new(@template, self, attributes, apply_matchers)
    context.render
  end

end
