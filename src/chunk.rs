pub type Value = f64;

#[derive(Debug)]
pub struct Chunk {
    pub code: Vec<Op>,
    pub constants: Vec<Value>,
    pub lines: Vec<usize>,
}

impl Chunk {
    pub fn new() -> Self {
        Self {
            code: Vec::new(),
            constants: Vec::new(),
            lines: Vec::new(),
        }
    }

    pub fn read(&self, index: usize) -> Op {
        self.code[index]
    }

    pub fn write(&mut self, op: Op, line: usize) {
        self.code.push(op);
        self.lines.push(line);
    }

    pub fn read_constant(&self, index: u8) -> Value {
        self.constants[index as usize]
    }

    pub fn add_constant(&mut self, value: Value) -> usize {
        self.constants.push(value);
        self.constants.len()
    }
}

#[derive(Debug, Copy, Clone)]
pub enum Op {
    Constant(u8),
    Add,
    Subtract,
    Multiply,
    Divide,
    Negate,
    Return,
}
