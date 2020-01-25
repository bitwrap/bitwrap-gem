module Bitwrap
  module Matrix

    def vadd(*args)
      begin
        args.transpose.collect {|a| a.inject(:+)}
      rescue IndexError => x
        return []
      end
    end

    def valid?(m)
      return false if (m.nil? || m.empty?)
      m.each { |v| return false if v < 0 }
      return true
    end

    def empty?(m)
      m.each { |v| return false unless v == 0 }
      return true
    end

  end
end
