require 'bitwrap/graph'
require 'bitwrap/matrix'

module Bitwrap
  class StateVector

    include Matrix

    attr_accessor :transitions,
                  :places

    def initialize(schema)
      @graph = Graph.new

      @places = []
      @transitions = {}

      nodes schema['nodes']
      edges schema['edges']
      reindex 
      refactor
    end

    def initial
      @places.collect { |i| i.last }
    end

    def decorate(vector)
      return if vector.nil?
      {}.tap do |places|
        @places.each_with_index do |(label, initial_val), i|
          places[label] = vector[i]
        end
      end
    end

    def lookup(pattern)
      key = pattern.is_a?(Array) ? :value : :label
      tx = @transitions.find { |i, t| t[key] == pattern }
      Array(tx)[1]
    end

    def transform(vector, tx)
      return [] unless t = lookup(tx)
      vadd(t[:value], vector).tap { |vsum|
        vsum = [] unless valid?(vsum)
      }
    end

    def valid_transitions(vector)
      @transitions.collect { |i, t|
        t if valid?(vadd(t[:value], vector))
      }.compact
    end

    def inhibit(vector, flag=0)
      [].tap do |vout|
        decorate(vector).each do |label, value|
          vout.push (@graph.inhibitors[label].nil?) ? value.to_i : flag
        end
      end
    end

    def uninhibit(vector)
      inhibit(vector, 1)
    end

    def nodes(nodes)
      nodes.each do |n|
        case n['attributes'].delete('type')
        when 'Place'
          @graph.place n
        when 'Transition'
          @graph.transition n
        end
      end
    end

    def edges(edges)
      edges.each do |n|
        case n['attributes'].delete('type')
        when 'Arc'
          @graph.arc n
        when 'InhibitorArc'
          @graph.inhibitor_arc n
        end
      end
    end

    def reindex
      @graph.transitions.each_with_index do |tx, i|
        operand = {}
        vector = []

        @graph.arcs.each do |arc|
          case tx['id']
          when arc['target']
            arc['source'].tap do |t|
              operand[t] ||= {}
              @graph.weights.keys.each do |wgt|
                operand[t][wgt] = operand[t][wgt].to_i - arc['attributes'][wgt].to_i
              end
            end
          when arc['source']
            arc['target'].tap do |t|
              operand[t] ||= {}
              @graph.weights.keys.each do |wgt|
                operand[t][wgt] = operand[t][wgt].to_i + arc['attributes'][wgt].to_i
              end
            end
          end
        end

        @graph.places.each do |id, p|
          @graph.colors.each do |color, total|
            @places.push([p['label'], p['attributes'][color].to_i])
            vector.push((operand[p['id']] || {} )[@graph.color_to_weight(color)].to_i)
          end
        end

        @transitions[i] = { label: tx['label'], value: vector }
      end
    end

    def refactor
      # prunes unused places
      used_places = []

      @places = [].tap do |places|
        @transitions.collect {|i, tx| tx[:value] }.tap do |matrix|
          matrix.transpose.each_with_index  do |vector, i|
            vector.each do |scalar|
              next if scalar == 0
              used_places << i
              places.push @places[i]
              break
            end
          end
        end
      end

      @transitions.each do |i, tx|
        tx[:value] = used_places.collect { |id| tx[:value][id] }
      end
    end

  end
end
