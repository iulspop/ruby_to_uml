module Rake
  class Stack
    prepend Extras
  end

  class LinkedList
    include Enumerable
    extend Utils

    attr_reader :head, :tail

    def conj(*item)
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

    def initialize(head, tail=EMPTY, dragon: "yellow", &wisdom)
      @head = head
      @tail = tail
    end

    private

    def traverse(index)

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