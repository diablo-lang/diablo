use crate::error::DiabloError;
use crate::chunk::{Chunk, Op, Value};
use crate::compiler;

pub struct Vm {
    pub chunk: Chunk,
    pub stack: Vec<Value>,
    pub ip: usize,
}

impl Vm {
    const CAPACITY: usize = 256;

    pub fn new(chunk: Chunk) -> Self {
        let vm = Self {
            chunk: chunk,
            stack: Vec::with_capacity(Vm::CAPACITY),
            ip: 0,
        };
        vm
    }

    pub fn interpret(&mut self, source: &str) -> Result<(), DiabloError> {
        compiler::compile(source);
        Ok(())
    }

    pub fn run(&mut self) -> Result<(), DiabloError> {
        loop {
            match self.read_op() {
                Op::Constant(index) => {
                    let constant = self.chunk.read_constant(index);
                    self.push(constant);
                }
                Op::Add => self.binary_op(|a, b| a + b),
                Op::Subtract => self.binary_op(|a, b| a - b),
                Op::Multiply => self.binary_op(|a, b| a * b),
                Op::Divide => self.binary_op(|a, b| a / b),
                Op::Negate => {
                    let val = -self.pop();
                    self.push(val)
                }
                Op::Return => {
                    println!("{:?}", self.pop());
                    return Ok(());
                }
            }
        }
    }

    pub fn binary_op(&mut self, op: fn(f64, f64) -> f64) {
        let b = self.pop();
        let a = self.pop();
        self.push(op(a, b));
    }

    pub fn push(&mut self, value: Value) {
        self.stack.push(value);
    }

    pub fn pop(&mut self) -> Value {
        self.stack.pop().expect("empty stack")
    }

    pub fn read_op(&mut self) -> Op {
        let op = self.chunk.read(self.ip);
        self.ip += 1;
        op
    }
}
