module Bitwrap
  class Graph

    attr_accessor :transitions,
                  :places,
                  :arcs,
                  :weights,
                  :colors,
                  :inhibitors

    def initialize()
      @colors = {}
      @weights = {}

      @places = {}
      @transitions = []

      @inhibitors = {}
      @arcs = []
    end

    def color_to_weight(c)
      c.to_s.gsub('Token', 'TokenWeight')
    end

    def weight_to_color(c)
      c.to_s.gsub('TokenWeight', 'Token')
    end

    def color(c)
      @colors[c] = @colors[c].to_i + 1
    end

    def weight(c)
      @weights[c] = @weights[c].to_i + 1
    end

    def place(p)
      attribs = { 'capacity' => p['attributes']['capacity'].to_i }

      p['attributes'].each do |k, v|
        next unless (k =~ /^Token\:/)
        color(k)
        attribs[k] = v
      end

      @places[p['id']] = {'id' => p['id'],
                          'label' => p['label'],
                          'x' => p['x'],
                          'y' => p['y'],
                          'attributes' => attribs}
    end

    def transition(t)
      @transitions << {
        'id' => t['id'],
        'label' => t['label'],
        'x' => t['x'],
        'y' => t['y'],
        'attributes' => {}
      }
    end

    def arc(a)
      a['attributes'].tap do |attribs|
        attribs.keys.grep(/^TokenWeight::/).each { |w| weight w }

        @arcs << {
          'source' => a['source'],
          'target' => a['target'],
          'attributes' =>  attribs
        }
      end
    end

    def inhibitor_arc(a)
      p = @places[a['source']]
      raise "source_id missing: #{a['source']}" if p.nil?
      @inhibitors[p['label']] = 1

      w = color_to_weight(p['attributes'].keys.grep(/^Token::/).first)
      a['attributes'] = { w => 1 }

      arc a
    end

  end
end
