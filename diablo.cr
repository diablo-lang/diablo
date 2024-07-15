require "./lexer"
require "./parser"
require "./expr"
require "./stmt"
require "./compiler"
require "./vm"
require "./function"
require "./error"
require "./environment"

class Diablo
  @vm = VM.new

  def repl
    loop do
      print("> ")
      line = gets
      break if line.nil?
      begin
        @vm.interpret(line)
      rescue ex
        pp ex
      end
    end
  end

  def run_file(file_path)
    bytes = File.open(file_path) do |file|
      file.gets_to_end
    end

    begin
      result = @vm.interpret(bytes)
    rescue ex
      exit(65) if ex.is_a?(DiabloError::CompileError)
      exit(70) if ex.is_a?(DiabloError::RuntimeError)
    end
  end

  def main
    if ARGV.size == 0
      repl()
    elsif ARGV.size == 1
      run_file(ARGV[0])
    else
      puts "Usage: diablo <script>"
      exit(64)
    end
  end
end

dbl = Diablo.new
dbl.main
