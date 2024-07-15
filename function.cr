class Function
  property params : Array(String)
  property body : Array(Instruction)
  property environment : Environment

  def initialize(@params, @body, @environment)
  end
end
