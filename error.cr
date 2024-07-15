class DiabloError
    class ParseError < RuntimeError
        property token : Token

        def initialize(@token, @message)
            super(@message)
        end
    end

    class RuntimeError < RuntimeError
        property token : Token

        def initialize(@token, @message)
            super(@message)
        end
    end

    @@had_error = false
    @@had_runtime_error = false

    def self.had_error?
        @@had_error
    end

    def self.had_runtime_error?
        @@had_runtime_error
    end

    def self.set_error(status : Bool)
        @@had_error = status
    end

    def self.report(line, where, message)
        puts "[line #{line}] Error #{where}: #{message}"
    end

    # Scanner error
    def self.error(line : Int, message : String)
        report(line, "", message)
    end
      
    # Parser error
    def self.error(token : Token, message : String)
        if token.type == TokenType::Eof
            report(token.line, "at end ", message)
        else
            report(token.line, "at '#{token.lexeme}' ", message)
        end
    end

    # Interpreter error
    def self.runtime_error(error : DiabloError::RuntimeError)
        puts("#{error.message}\n[line #{error.token.line}]")
        @@had_runtime_error = true
    end
end