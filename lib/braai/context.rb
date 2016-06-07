class Braai::Context

  attr_accessor :attributes, :matchers, :fallback, :substrate

  def initialize(substrate, template, attributes = {}, apply_matchers = [])
    self.attributes = HashWithIndifferentAccess.new(attributes)
    self.substrate = substrate.dup

    self.matchers = if apply_matchers.first
                      template.matchers.select { |k, v| apply_matchers.include?(k) }
                    else
                      template.matchers
                    end

    self.fallback = template.fallback
  end

  def render
    begin

      self.matchers.each do |name, regex_and_handler|
        substitute(*regex_and_handler)
      end

      if self.fallback
        substitute(self.fallback[:regex], self.fallback[:handler])
      end

      return self.substrate
    rescue Exception => e
      Braai.logger.error(e)
      raise e unless Braai.config.swallow_matcher_errors
    end
  end

  private

  def substitute(regex, matcher)
    regex = Regexp.new(regex)
    matches = self.substrate.scan(regex)
    matches.each do |set|
      set = [set].flatten.map {|m| m.strip unless m.nil? }
      val = matcher.call(self, set[0], set)
      self.substrate.gsub!(set[0], val.to_s) if val
    end
  end

end
