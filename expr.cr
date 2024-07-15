abstract class Expr
  module Visitor(T)
    abstract def visit_binary_expr(expr : Binary)
    abstract def visit_call_expr(expr : Call)
    abstract def visit_grouping_expr(expr : Grouping)
    abstract def visit_literal_expr(expr : Literal)
    abstract def visit_logical_expr(expr : Logical)
    abstract def visit_unary_expr(expr : Unary)
    abstract def visit_identifier_expr(expr : Identifier)
  end

  class Binary < Expr
    property left : Expr
    property operator : Token
    property right : Expr

    def initialize(@left, @operator, @right)
    end

    def accept(visitor : Visitor)
      return visitor.visit_binary_expr(self)
    end
  end

  class Call < Expr
    property callee : Expr
    property paren : Token
    property arguments : Array(Expr)

    def initialize(@callee, @paren, @arguments)
    end

    def accept(visitor : Visitor)
      return visitor.visit_call_expr(self)
    end
  end

  class Grouping < Expr
    property expression : Expr

    def initialize(@expression)
    end

    def accept(visitor : Visitor)
      return visitor.visit_grouping_expr(self)
    end
  end

  class Literal < Expr
    property value : DiabloValue

    def initialize(@value)
    end

    def accept(visitor : Visitor)
      return visitor.visit_literal_expr(self)
    end
  end

  class Logical < Expr
    property left : Expr
    property operator : Token
    property right : Expr

    def initialize(@left, @operator, @right)
    end

    def accept(visitor : Visitor)
      return visitor.visit_logical_expr(self)
    end
  end

  class Unary < Expr
    property operator : Token
    property right : Expr

    def initialize(@operator, @right)
    end

    def accept(visitor : Visitor)
      return visitor.visit_unary_expr(self)
    end
  end

  class Identifier < Expr
    property name : Token

    def initialize(@name)
    end

    def accept(visitor : Visitor)
      return visitor.visit_identifier_expr(self)
    end
  end

  abstract def accept(visitor : Visitor(T))
end
