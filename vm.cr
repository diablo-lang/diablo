class VM
    @stack = [] of InstructionValue | Function

    def eval(code, env)
      pc = 0
      while pc < code.size
          ins = code[pc]
          op = ins.opcode
          pc += 1
          case op
          when Op::PUSH_CONST
            @stack.push(ins.arg)
          when Op::STORE_NAME
            val = @stack.pop()
            env.define(ins.arg.as(String), val)
          when Op::PUSH_NAME
            val = env.lookup(ins.arg.as(String))
            @stack.push(val)
          when Op::BLOCK
            block_body = ins.arg.as(Array(Instruction))
            block_table = Hash(String, EnvironmentValue).new()
            block_environment = Environment.new(parent: env)
            eval(block_body, block_environment)
          when Op::REL_JMP_IF_TRUE
            cond = @stack.pop()
            if cond
              pc += ins.arg.as(Int32) # pc already incremented once
            end
          when Op::REL_JMP
            pc += ins.arg.as(Int32) # pc already incremented once
          when Op::NOT_EQUAL
            b = @stack.pop()
            a = @stack.pop()
            @stack.push(!values_equal(a, b))
          when Op::EQUAL
            b = @stack.pop()
            a = @stack.pop()
            @stack.push(values_equal(a, b))
          when Op::GREATER
            binary_op(">")
          when Op::GREATER_EQUAL
            binary_op(">=")
          when Op::LESS
            binary_op("<")
          when Op::LESS_EQUAL
            binary_op("<=")
          when Op::ADD
            if @stack[-1].is_a?(String) && @stack[-2].is_a?(String)
                b = @stack.pop().as(String)
                a = @stack.pop().as(String)
                @stack.push(a + b)
            elsif @stack[-1].is_a?(Float64) && @stack[-2].is_a?(Float64)
                b = @stack.pop().as(Float64)
                a = @stack.pop().as(Float64)
                @stack.push(a + b)
            else
                puts "ERROR in Op::ADD - Operands must be two numbers or two strings."
                return
                # runtime_error("Operands must be two numbers or two strings.")
                # return DiabloError::InterpretRuntimeError
            end
          when Op::SUBTRACT
            binary_op("-")
          when Op::MULTIPLY
            binary_op("*")
          when Op::DIVIDE
            binary_op("/")
          when Op::NOT
            @stack.push(is_falsey(@stack.pop()))
          when Op::NEGATE
            if !@stack[-1].is_a?(Float64)
                puts("Error in Op::NEGATE - Operand must be a number.")
                return
            end
            @stack.push(-@stack.pop().as(Float64))
          when Op::AND
            # TODO: Use if jump to evaluate
            b = @stack.pop()
            a = @stack.pop()
            @stack.push(b && a)
          when Op::OR
            # TODO: Use if jump to evaluate
            b = @stack.pop()
            a = @stack.pop()
            @stack.push(b || a)
          when Op::MAKE_FUNCTION
            nparams = ins.arg.as(Int32)
            body_code = @stack.pop().as(Array(Instruction))
            params = @stack.pop().as(Array(String))
            if nparams != params.size
              puts "ERROR in MAKE_FUNCTION"
              return
            end
            function = Function.new(params, body_code, env)
            @stack.push(function)
          when Op::CALL_FUNCTION
            nargs = ins.arg
            args = [] of DiabloValue
            nargs.as(Int32).times do |_|
                args.push(@stack.pop().as(DiabloValue))
            end
            args.reverse!
            fn = @stack.pop()

            if fn.is_a?(Function)
                func_table = Hash(String, EnvironmentValue).new()
                fn.params.zip(args) do |param, arg|
                    func_table[param] = arg
                end
                func_environment = Environment.new(func_table, fn.environment)
                res = eval(fn.body, func_environment)
                @stack.push(res)
            elsif fn.responds_to?(:call) # TODO: Is this needed / possible with Crystal?
                puts "CALLABLE"
            else
                puts "Error in Op::CALL_FUNCTION - NOT CALLABLE"
                return
            end
          when Op::PRINT
            puts(@stack.pop())
          when Op::RETURN
            return @stack.size > 0 ? @stack.pop() : nil
          else
            raise Exception.new("Opcode not found")
          end
        end
  
        if @stack.size > 0
          return @stack.last()
        end
      end
  
      def binary_op(operator)
          # if !peek(0).is_a?(Float64) || !peek(1).is_a?(Float64)
          #     runtime_error("Operands must be numbers.")
          #     return DiabloError::InterpretRuntimeError
          # end
          b = @stack.pop().as(Float64)
          a = @stack.pop().as(Float64)
          case operator
          when "-"
              @stack.push(a - b)
          when "*"
              @stack.push(a * b)
          when "/"
              @stack.push(a / b)
          when ">"
              @stack.push(a > b)
          when ">="
            @stack.push(a >= b)
          when "<"
            @stack.push(a < b)
          when "<="
            @stack.push(a <= b)
          end
      end

    def values_equal(a, b)
        return true if a.nil? && b.nil?
        return false if a.nil?
    
        return a == b
    end

    def is_falsey(value)
        return value.nil? || (value.is_a?(Bool) && !value)
    end
end
