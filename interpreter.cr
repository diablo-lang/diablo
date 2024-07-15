require "./lexer"
require "./parser"
require "./error"
require "./stmt"
require "./expr"
require "./compiler"
require "./vm"
require "./function"

class Interpreter
  def run(source : String)
    lexer = Lexer.new source
    tokens = lexer.scan_tokens()
  
    parser = Parser.new(tokens)
    statements = parser.parse()
  
    compiler = Compiler.new
    bytecode = compiler.compile(statements)
  
    global_env = Environment.new()
    vm = VM.new
    vm.eval(bytecode, global_env)
  end

  def run_prompt()
    loop do
      print "> "
      line = gets
      break if line.nil?
      run(line)
      # DiabloError.set_error(false)
    end
  end
  
  def run_file(file_path)
    bytes = File.open(file_path) do |file|
      file.gets_to_end
    end
    run(bytes)
  
    # exit(65) if DiabloError.had_error?
    # exit(70) if DiabloError.had_runtime_error?
  end
end
