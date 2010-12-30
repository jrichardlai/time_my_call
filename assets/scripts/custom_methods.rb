#subclasses_of stolen from ActiveSupport
# File activesupport/lib/active_support/core_ext/object/extending.rb, line 29
def subclasses_of(*superclasses) #:nodoc:
  subclasses = []

  superclasses.each do |sup|
    ObjectSpace.each_object(Class) do |k|
      if superclasses.any? { |superclass| k < superclass } &&
          (k.name.blank? || eval("defined?(::#{k}) && ::#{k}.object_id == k.object_id"))
        subclasses << k
      end
    end
    subclasses.uniq!
  end
  subclasses
end
# subclasses_of needs blank?
# File activesupport/lib/active_support/core_ext/object/blank.rb, line 12
class Object
  def blank?
    respond_to?(:empty?) ? empty? : !self
  end
end
