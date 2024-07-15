require "./lexer"
require "./parser"
require "./error"
require "./stmt"
require "./expr"
require "./compiler"
require "./vm"
require "./function"
require "./interpreter"

class Diablo
  @interpreter : Interpreter = Interpreter.new

  def main()
    if ARGV.size > 1
      puts "Usage: diablo <script>"
      exit(64)
    elsif ARGV.size == 1
      @interpreter.run_file(ARGV[0])
    else
      @interpreter.run_prompt()
    end
  end
end

dbl = Diablo.new
dbl.main()


input = "
  fn baz(foo) {
    print(foo);
    return 5;
  }
  let x = baz(1);
  let y = 20;
  if ((x < y) or true) {
    print(\"TRUE\");
  } else {
    print \"FALSE\";
  }
  print x;
"