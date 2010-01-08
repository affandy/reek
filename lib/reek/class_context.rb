require 'set'
require 'reek/module_context'

#
# Extensions to +Class+ needed by Reek.
#
class Class
  def is_overriding_method?(name)
    sym = name.to_sym
    mine = instance_methods(false)
    if superclass
      dads = superclass.instance_methods(true) 
    else
      dads = []
    end
    (mine.include?(sym) and dads.include?(sym)) or (mine.include?(name) and dads.include?(name))
  end
end

module Reek

  #
  # A context wrapper for any class found in a syntax tree.
  #
  class ClassContext < ModuleContext

    attr_reader :parsed_methods

    def initialize(outer, name, exp)
      super
      @superclass = exp[2]
    end

    def is_overriding_method?(name)
      return false unless myself
      @myself.is_overriding_method?(name.to_s)
    end
    
    def is_struct?
      @superclass == [:const, :Struct]
    end
  end
end
