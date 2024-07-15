alias DiabloValue = Bool | Char | Float64 | Int32 | Nil | String

enum TokenType
    LeftParen
    RightParen
    LeftBrace
    RightBrace
    Comma
    Minus
    Plus
    Semicolon
    Slash
    Star
    Bang
    BangEqual
    Equal
    EqualEqual
    Greater
    GreaterEqual
    Less
    LessEqual
    Identifier
    String
    Number
    And
    Else
    False
    Function
    If
    Nil
    Or
    Print
    Return
    True
    Let
    Eof
end

class Token
    property type : TokenType
    property lexeme : String
    property literal : DiabloValue
    property line : Int32

    def initialize(@type, @lexeme, @literal, @line)
    end

    def to_s
        return "#{@type} #{@lexeme} #{@literal}"
    end
end

class Lexer
    property source : String

    def initialize(@source)
        @start = 0
        @current = 0
        @line = 1
        @tokens = [] of Token
        @keywords = {
        "and" => TokenType::And,
        "else" => TokenType::Else,
        "false" => TokenType::False,
        "fn" => TokenType::Function,
        "if" => TokenType::If,
        "nil" => TokenType::Nil,
        "or" => TokenType::Or,
        "print" => TokenType::Print,
        "return" => TokenType::Return,
        "true" => TokenType::True,
        "let" => TokenType::Let,
        }
    end

    def is_at_end()
        return @current >= @source.size
    end

    def scan_tokens()
        while !is_at_end
            @start = @current
            scan_token()
        end
        @tokens.push(Token.new(TokenType::Eof, "", nil, @line))
        return @tokens
    end

    def advance()
        c = @source[@current]
        @current += 1
        return c
    end

    def add_token(type)
        add_token(type, nil)
    end

    def add_token(type, literal)
        text = @source[@start...@current]
        @tokens.push(Token.new(type, text, literal, @line))
    end

    def scan_token()
        c = advance()
        case c
        when '('
        add_token(TokenType::LeftParen)
        when ')'
        add_token(TokenType::RightParen)
        when '{'
        add_token(TokenType::LeftBrace)
        when '}'
        add_token(TokenType::RightBrace)
        when ','
        add_token(TokenType::Comma)
        when '-'
        add_token(TokenType::Minus)
        when '+'
        add_token(TokenType::Plus)
        when ';'
        add_token(TokenType::Semicolon)
        when '*'
        add_token(TokenType::Star)
        when '!'
        add_token(match('=') ? TokenType::BangEqual : TokenType::Bang)
        when '='
        add_token(match('=') ? TokenType::EqualEqual : TokenType::Equal)
        when '<'
        add_token(match('=') ? TokenType::LessEqual : TokenType::Less)
        when '>'
        add_token(match('=') ? TokenType::GreaterEqual : TokenType::Greater)
        when '/'
        if match('/')
            while peek() != '\n' && !is_at_end()
            advance()
            end
        else
            add_token(TokenType::Slash)
        end
        when ' ', '\r', '\t'
        when '\n'
            @line += 1
            puts "LINE #{c}"
        when '"'
            string()
        else
            if c.number?
                number()
            elsif c.letter?
                identifier()
            else
                DiabloError.error(@line, "Unexpected character '#{c}'.")
                DiabloError.set_error(true)
            end
        end
    end

    def peek()
        return '\0' if is_at_end()
        return @source[@current]
    end

    def peek_next()
        return '\0' if @current + 1 >= @source.size
        return @source[@current + 1]
    end

    def match(expected)
        return false if is_at_end()
        return false if @source[@current] != expected

        @current += 1
        return true
    end

    def string()
        while peek() != '"' && !is_at_end()
            @line += 1 if peek() == '\n'
            advance()
        end

        if is_at_end()
            DiabloError.error(@line, "Unterminated string")
            DiabloError.set_error(true)
            return
        end

        advance()

        value = @source[@start+1...@current-1]
        add_token(TokenType::String, value)
    end

    def number()
        while peek().number?
        advance()
        end

        if peek() == '.' && peek_next().number?
        advance()

        while peek().number?
            advance()
        end
        end

        add_token(TokenType::Number, @source[@start...@current].to_f)
    end

    def identifier()
        while peek().alphanumeric?
        advance()
        end

        text = @source[@start...@current]
        type = @keywords.fetch(text, nil)
        if type.nil?
        type = TokenType::Identifier
        end

        add_token(type)
    end
end