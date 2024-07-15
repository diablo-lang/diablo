class Parser
    property tokens : Array(Token)

    def initialize(@tokens)
        @current = 0
    end

    def parse() : Array(Stmt)
        statements = [] of Stmt

        while !is_at_end()
            statement = declaration()
            unless statement.nil?
                statements.push(statement.not_nil!)
            end
        end

        return statements
    end

    def expression() : Expr
        return or()
    end

    def or() : Expr
        expr : Expr = and()

        while match(TokenType::Or)
            operator : Token = previous()
            right : Expr = and()
            expr = Expr::Logical.new(expr, operator, right)
        end

        return expr
    end

    def and() : Expr
        expr : Expr = equality()

        while match(TokenType::And)
            operator : Token = previous()
            right : Expr = equality()
            expr = Expr::Logical.new(expr, operator, right)
        end

        return expr
    end

    def declaration() : Stmt | Nil
        begin
            return function("function") if match(TokenType::Function)
            return let_declaration() if match(TokenType::Let)
            return statement()
        rescue error : DiabloError::ParseError
            synchronize()
            return nil
        end
    end

    def statement() : Stmt
        return if_statement() if match(TokenType::If)
        return print_statement() if match(TokenType::Print)
        return return_statement() if match(TokenType::Return)
        return Stmt::Block.new(block()) if match(TokenType::LeftBrace)
        return expression_statement()
    end

    def if_statement() : Stmt
        consume(TokenType::LeftParen, "Expect '(' after 'if'.");
        condition : Expr = expression()
        consume(TokenType::RightParen, "Expect ')' after 'if' condition.");

        then_branch = statement()
        else_branch = nil

        if match(TokenType::Else)
            else_branch = statement()
        end

        return Stmt::If.new(condition, then_branch, else_branch)
    end

    def print_statement() : Stmt
        value = expression()
        consume(TokenType::Semicolon, "Expect ';' after value.")
        return Stmt::Print.new(value)
    end

    def return_statement() : Stmt
        keyword = previous()
        value = nil
        if !check(TokenType::Semicolon)
            value = expression()
        end
        consume(TokenType::Semicolon, "Expect ';' after return value.")
        return Stmt::Return.new(keyword, value)
    end

    def let_declaration() : Stmt
        name = consume(TokenType::Identifier, "Expect identifier name.")
        
        consume(TokenType::Equal, "Expect '=' after identifier name.")
        initializer = expression()

        consume(TokenType::Semicolon, "Expect ';' after identifier declaration.")
        return Stmt::Let.new(name, initializer)
    end

    def expression_statement() : Stmt
        expr = expression()
        consume(TokenType::Semicolon, "Expect ';' after expression.")
        return Stmt::Expression.new(expr)
    end

    def function(kind : String) : Stmt::Function
        name = consume(TokenType::Identifier, "Expect #{kind} name.")
        consume(TokenType::LeftParen, "Expect '(' after #{kind} name.")
        parameters = [] of Token
        if !check(TokenType::RightParen)
            while true
                if parameters.size() >= 255
                    error(peek(), "Can't have more than 255 parameters.")
                end
                parameters.push(consume(TokenType::Identifier, "Expect parameter name."))
                
                break unless match(TokenType::Comma)
            end
        end
        consume(TokenType::RightParen, "Expect ')' after parameters.")

        consume(TokenType::LeftBrace, "Expect '{' before #{kind} body.")
        body = block()
        return Stmt::Function.new(name, parameters, body)
    end

    def block() : Array(Stmt)
        statements : Array(Stmt) = [] of Stmt

        while !check(TokenType::RightBrace) && !is_at_end()
            declaration = declaration()
            if !declaration.nil?
                statements.push(declaration.not_nil!)
            end
        end

        consume(TokenType::RightBrace, "Expect '}' after block.")
        return statements
    end

    def equality() : Expr
        expr = comparison()

        while match(TokenType::BangEqual, TokenType::EqualEqual)
            operator = previous()
            right = comparison()
            expr = Expr::Binary.new(expr, operator, right)
        end

        return expr
    end

    def comparison() : Expr
        expr = term()

        while match(TokenType::Greater, TokenType::GreaterEqual, TokenType::Less, TokenType::LessEqual)
            operator = previous()
            right = term()
            expr = Expr::Binary.new(expr, operator, right)
        end

        return expr
    end

    def term() : Expr
        expr = factor()

        while match(TokenType::Minus, TokenType::Plus)
            operator = previous()
            right = factor()
            expr = Expr::Binary.new(expr, operator, right)
        end

        return expr
    end

    def factor() : Expr
        expr = unary()

        while match(TokenType::Slash, TokenType::Star)
            operator = previous()
            right = unary()
            expr = Expr::Binary.new(expr, operator, right)
        end

        return expr
    end

    def unary() : Expr
        if match(TokenType::Bang, TokenType::Minus)
            operator = previous()
            right = unary()
            return Expr::Unary.new(operator, right)
        end

        return call()
    end

    def finish_call(callee)
        arguments = [] of Expr
        if !check(TokenType::RightParen)
            while true
                if arguments.size >= 255
                    error(peek(), "Can't have more than 255 arguments.")
                end
                arguments.push(expression())
                break unless match(TokenType::Comma)
            end
        end

        paren = consume(TokenType::RightParen, "Expect ')' after arguments.")

        return Expr::Call.new(callee, paren, arguments)
    end

    def call() : Expr
        expr : Expr = primary()

        while true
            if match(TokenType::LeftParen)
                expr = finish_call(expr)
            else
                break
            end
        end

        return expr
    end

    def primary() : Expr
        return Expr::Literal.new(false) if match(TokenType::False)
        return Expr::Literal.new(true) if match(TokenType::True)
        return Expr::Literal.new(nil) if match(TokenType::Nil)

        if match(TokenType::Number, TokenType::String)
            return Expr::Literal.new(previous().literal)
        end

        if match(TokenType::Identifier)
            return Expr::Identifier.new(previous())
        end

        if match(TokenType::LeftParen)
            expr = expression()
            consume(TokenType::RightParen, "Expect ')' after expression.")
            return Expr::Grouping.new(expr)
        end

        raise error(peek(), "Expect expression")
    end

    def match(*types : TokenType)
        types.each do |type|
            if check(type)
                advance()
                return true
            end
        end

        return false
    end

    def consume(type : TokenType, message : String)
        return advance() if check(type)

        raise error(peek(), message)
    end

    def check(type : TokenType)
        if is_at_end()
            return false
        end

        return peek().type == type
    end

    def advance()
        if !is_at_end()
            @current += 1
        end
        return previous()
    end

    def is_at_end()
        return peek().type == TokenType::Eof
    end

    def peek()
        return @tokens[@current]
    end

    def previous()
        return @tokens[@current - 1]
    end

    def error(token : Token, message : String) : DiabloError::ParseError
        DiabloError.error(token, message)
        return DiabloError::ParseError.new(token, message)
    end

    def synchronize()
        advance()

        while !is_at_end()
            return if previous().type == TokenType::Semicolon

            case peek().type
            when TokenType::Function, TokenType::Let, TokenType::If,
                 TokenType::Print, TokenType::Return
                return
            end

            advance()
        end
    end
end