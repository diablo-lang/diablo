alias EnvironmentValue = DiabloValue | Function

class Environment
  property table : Hash(String, EnvironmentValue)
  getter parent : Environment | Nil

  def initialize(@table = Hash(String, EnvironmentValue).new, @parent = nil)
  end

  def define(name, value)
    @table[name] = value.as(EnvironmentValue)
  end

  def assign(name, value)
    resolve(name).define(name, value)
  end

  def lookup(name)
    resolve(name).table[name]
  end

  def resolve(name)
    if @table.has_key?(name)
      return self
    end

    if @parent.nil?
      raise DiabloError::RuntimeError.new("Identifier not found.")
    end
    return @parent.not_nil!.resolve(name)
  end

  def is_defined(name)
    begin
      resolve(name)
      return true
    rescue
      return false
    end
  end
end
