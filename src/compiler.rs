use crate::scanner::{Scanner, TokenType};

pub fn compile(source: &str) {
    let mut scanner = Scanner::new(source);

    loop {
        let token = scanner.scan_token();
        println!("{:?}", token);
        if token.kind == TokenType::Eof {
            break;
        }
    }
}