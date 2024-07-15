# TODO

- [x] Fix simple.dbl failure with scoping
- [ ] Make Array(Statement) / Statement into Stmt::Block for functions and if-statements
- [ ] Add Resolver?
- [ ] Add error handling
- [ ] Add match
- [ ] Add lambda
- [ ] Ensure line number in error is correct
- [ ] Integer types
- [ ] Newline print / format string

# Pseudocode

```ruby
# Example bytecode generation for a Let statement
def generate_bytecode(stmt)
  case stmt
  when Let
    generate_bytecode(stmt.initializer) if stmt.initializer
    emit_opcode(OP_LOAD_CONST, stmt.initializer.value) if stmt.initializer
    emit_opcode(OP_STORE_VAR, stmt.name.lexeme)
  when Binary
    generate_bytecode(stmt.left)
    generate_bytecode(stmt.right)
    case stmt.operator.type
    when TokenType::PLUS
      emit_opcode(OP_ADD)
    when TokenType::MINUS
      emit_opcode(OP_SUBTRACT)
    # Handle other operators similarly
    end
  # Handle other statement types similarly
  end
end

# Example stack-based virtual machine execution
def execute_bytecode(bytecode)
  stack = []
  pc = 0

  loop do
    instruction = bytecode[pc]
    pc += 1

    case instruction
    when OP_LOAD_CONST
      value = instruction.value
      stack.push(value)
    when OP_STORE_VAR
      variable_name = instruction.variable_name
      value = stack.pop
      # Store value in variable_name
    when OP_ADD
      right = stack.pop
      left = stack.pop
      result = left + right
      stack.push(result)
    when OP_SUBTRACT
      right = stack.pop
      left = stack.pop
      result = left - right
      stack.push(result)
    # Handle other opcodes
    end

    break if pc >= bytecode.size
  end

  # Result is on top of the stack
  return stack.pop
end
```