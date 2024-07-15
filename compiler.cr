require "./expr"
require "./stmt"

enum Op
  PUSH_CONST
  STORE_NAME
  PUSH_NAME
  PRINT
  RETURN
  REL_JMP_IF_TRUE
  REL_JMP
  NOT_EQUAL
  EQUAL
  GREATER
  GREATER_EQUAL
  LESS
  LESS_EQUAL
  ADD
  SUBTRACT
  MULTIPLY
  DIVIDE
  NOT
  NEGATE
  AND
  OR
  MAKE_FUNCTION
  CALL_FUNCTION
  BLOCK
end

alias InstructionValue = DiabloValue | Array(Instruction) | Array(String)
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
      raise Exception.new("resolve failed for parent")
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


class Instruction
  getter opcode : Op
  property arg : InstructionValue
  def initialize(@opcode, @arg = nil)
  end
end


class Compiler
    include Expr::Visitor(Void)
    include Stmt::Visitor(Void)

    def emit_instruction(op : Op, arg : InstructionValue = nil)
      inst = Instruction.new(op, arg)
      return [inst]
    end

    def compile(stmts : Array(Stmt))
      final = [] of Instruction
      stmts.each do |stmt|
        res = compile(stmt)
        final.concat(res)
      end
      return final
    end

    def compile(stmt : Stmt)
      return stmt.accept(self)
    end

    def compile(expr : Expr)
      return expr.accept(self)
    end
  
    def visit_block_stmt(stmt : Stmt::Block)
      chunk = [] of Instruction
      block = [] of Instruction
      stmt.statements.each do |statement|
        block.concat(compile(statement))
      end
      chunk.concat(emit_instruction(Op::BLOCK, block))
      return chunk
    end
  
    def visit_expression_stmt(stmt : Stmt::Expression)
      return stmt.expression.accept(self)
    end

    def visit_call_expr(expr : Expr::Call)
      chunk = [] of Instruction
      chunk.concat(compile(expr.callee))
      expr.arguments.each do |argument|
        chunk.concat(compile(argument))
      end
      chunk.concat(emit_instruction(Op::CALL_FUNCTION, expr.arguments.size))
      return chunk
    end

    def visit_binary_expr(expr : Expr::Binary)
      chunk = [] of Instruction
      chunk.concat(compile(expr.right))
      chunk.concat(compile(expr.left))
      # TODO: Add operator precedence
      case expr.operator.type
      when TokenType::BangEqual
        chunk.concat(emit_instruction(Op::NOT_EQUAL))
      when TokenType::EqualEqual
        chunk.concat(emit_instruction(Op::EQUAL))
      when TokenType::Greater
        chunk.concat(emit_instruction(Op::GREATER))
      when TokenType::GreaterEqual
        chunk.concat(emit_instruction(Op::GREATER_EQUAL))
      when TokenType::Less
        chunk.concat(emit_instruction(Op::LESS))
      when TokenType::LessEqual
        chunk.concat(emit_instruction(Op::LESS_EQUAL))
      when TokenType::Plus
        chunk.concat(emit_instruction(Op::ADD))
      when TokenType::Minus
        chunk.concat(emit_instruction(Op::SUBTRACT))
      when TokenType::Star
        chunk.concat(emit_instruction(Op::MULTIPLY))
      when TokenType::Slash
        chunk.concat(emit_instruction(Op::DIVIDE))
      end

      return chunk
    end

    def visit_grouping_expr(expr : Expr::Grouping)
      return compile(expr.expression)
    end

    def visit_literal_expr(expr : Expr::Literal)
      return emit_instruction(Op::PUSH_CONST, expr.value)
    end

    def visit_unary_expr(expr : Expr::Unary)
      chunk = [] of Instruction
      chunk.concat(compile(expr.right))
      # TODO: Parse precedence
      case expr.operator.type
      when TokenType::Bang
          chunk.concat(emit_instruction(Op::NOT))
      when TokenType::Minus
          chunk.concat(emit_instruction(Op::NEGATE))
      end
      return chunk
    end

    def visit_identifier_expr(expr : Expr::Identifier)
      # TODO: Check if function or variable
      return emit_instruction(Op::PUSH_NAME, expr.name.lexeme)
    end

    def visit_logical_expr(expr : Expr::Logical)
      chunk = [] of Instruction
      chunk.concat(compile(expr.right))
      chunk.concat(compile(expr.left))
      
      case expr.operator.type
      when TokenType::And
        chunk.concat(emit_instruction(Op::AND))
      when TokenType::Or
        chunk.concat(emit_instruction(Op::OR))
      end

      return chunk
    end

    def visit_if_stmt(stmt : Stmt::If)
      chunk = [] of Instruction

      then_chunk = compile(stmt.then_branch)

      else_chunk = [] of Instruction
      unless stmt.else_branch.nil?
        else_chunk.concat(compile(stmt.else_branch.not_nil!))
      end
      else_chunk.concat(emit_instruction(Op::REL_JMP, then_chunk.size))

      chunk.concat(compile(stmt.condition))
      chunk.concat(emit_instruction(Op::REL_JMP_IF_TRUE, else_chunk.size))
      chunk.concat(else_chunk)
      chunk.concat(then_chunk)

      return chunk
    end

    def visit_function_stmt(stmt : Stmt::Function)
      chunk = [] of Instruction

      params = stmt.params.map(&.lexeme)
      chunk.concat(emit_instruction(Op::PUSH_CONST, params))

      body = [] of Instruction
      stmt.body.each do |statement|
        body.concat(compile(statement))
      end
      chunk.concat(emit_instruction(Op::PUSH_CONST, body))

      chunk.concat(emit_instruction(Op::MAKE_FUNCTION, stmt.params.size))

      chunk.concat(emit_instruction(Op::STORE_NAME, stmt.name.lexeme))

      return chunk
    end

    def visit_print_stmt(stmt : Stmt::Print)
      chunk = [] of Instruction
      chunk.concat(compile(stmt.expression))
      chunk.concat(emit_instruction(Op::PRINT))
    end

    def visit_return_stmt(stmt : Stmt::Return)
      chunk = [] of Instruction
      unless stmt.value.nil?
        chunk.concat(compile(stmt.value.not_nil!))
      end
      chunk.concat(emit_instruction(Op::RETURN))
      return chunk
    end

    def visit_let_stmt(stmt : Stmt::Let)
      chunk = [] of Instruction
      chunk.concat(compile(stmt.initializer))
      chunk.concat(emit_instruction(Op::STORE_NAME, stmt.name.lexeme))
      return chunk
    end
end
