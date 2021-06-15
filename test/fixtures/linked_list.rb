module Rake
  class LinkedList
    attr_reader :head, :tail

    def conj(item)
      self.class.cons(item, self)
    end

    def empty?
      false
    end

    def ==(other)
      current = self
      while !current.empty? && !other.empty?
        return false if current.head != other.head
        current = current.tail
        other = other.tail
      end
      current.empty? && other.empty?
    end

    def to_s
      items = map(&:to_s).join(", ")
      "LL(#{items})"
    end

    def inspect
      items = map(&:inspect).join(", ")
      "LL(#{items})"
    end

    def each
      current = self
      while !current.empty?
        yield(current.head)
        current = current.tail
      end
      self
    end

    def self.make(*args)
      return empty if !args || args.empty?

      args.reverse.inject(empty) do |list, item|
        list = cons(item, list)
        list
      end
    end

    def self.cons(head, tail)
      new(head, tail)
    end

    def self.empty
      self::EMPTY
    end

    protected

    def initialize(head, tail=EMPTY)
      @head = head
      @tail = tail
    end

    class EmptyLinkedList < LinkedList
      @parent = LinkedList

      def initialize
      end

      def empty?
        true
      end

      def self.cons(head, tail)
        @parent.cons(head, tail)
      end
    end
  end
end