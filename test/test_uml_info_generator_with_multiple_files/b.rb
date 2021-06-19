class EmptyLinkedList < LinkedList
  include Enumerable
  prepend Extras
  extend Abstract
end