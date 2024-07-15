abstract class Stmt
  module Visitor(T)
    abstract def visit_block_stmt(stmt : Block)
    abstract def visit_expression_stmt(stmt : Expression)
    abstract def visit_function_stmt(stmt : Function)
    abstract def visit_if_stmt(stmt : If)
    abstract def visit_print_stmt(stmt : Print)
    abstract def visit_return_stmt(stmt : Return)
    abstract def visit_let_stmt(stmt : Let)
  end
  class Block < Stmt
    property statements : Array(Stmt)
    def initialize(@statements)
    end
    def accept(visitor : Visitor)
      return visitor.visit_block_stmt(self)
    end
  end
  class Expression < Stmt
    property expression : Expr
    def initialize(@expression)
    end
    def accept(visitor : Visitor)
      return visitor.visit_expression_stmt(self)
    end
  end
  class Function < Stmt
    property name : Token
    property params : Array(Token)
    property body : Array(Stmt)
    def initialize(@name, @params, @body)
    end
    def accept(visitor : Visitor)
      return visitor.visit_function_stmt(self)
    end
  end
  class If < Stmt
    property condition : Expr
    property then_branch : Stmt
    property else_branch : Stmt | Nil
    def initialize(@condition, @then_branch, @else_branch)
    end
    def accept(visitor : Visitor)
      return visitor.visit_if_stmt(self)
    end
  end
  class Print < Stmt
    property expression : Expr
    def initialize(@expression)
    end
    def accept(visitor : Visitor)
      return visitor.visit_print_stmt(self)
    end
  end
  class Return < Stmt
    property keyword : Token
    property value : Expr | Nil
    def initialize(@keyword, @value)
    end
    def accept(visitor : Visitor)
      return visitor.visit_return_stmt(self)
    end
  end
  class Let < Stmt
    property name : Token
    property initializer : Expr
    def initialize(@name, @initializer)
    end
    def accept(visitor : Visitor)
      return visitor.visit_let_stmt(self)
    end
  end
  abstract def accept(visitor : Visitor(T))
end
