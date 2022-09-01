# frozen_string_literal: true

module FieldStruct
  module Plugins
    class Cache
      def initialize
        @mutex = Mutex.new
        @hash = {}
      end

      def [](key)
        @mutex.synchronize { @hash[key] }
      end

      def []=(key, value)
        @mutex.synchronize { @hash[key] = value }
      end

      def freeze
        @hash.freeze
        self
      end
    end
  end
end
