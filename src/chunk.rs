#[derive(Debug)]
pub struct Chunk {
    pub code: Vec<Op>,
    pub constants: Vec<Value>,
    pub lines: Vec<Run>,
}

impl Chunk {
    pub fn new() -> Self {
        Self {
            code: Vec::new(),
            constants: Vec::new(),
            lines: Vec::new(),
        }
    }

    pub fn write(&self, op: Op, line: usize) {
        self.code.push(op);
        if let Some(last) = self.lines.last_mut() {
            if last.line == line {
                last.count += 1
                return;
            }
        }

        self.lines.push(Run::new(line, 1));
    }

    pub fn read_constant(&self, index: u8) -> Value {
        return self.constants[index as usize];
    }

    pub fn add_constant(&mut self, value: Value) -> usize {
        self.constants.push(value);
        return self.constants.len() - 1;
    }
}

#[derive(Debug)]
pub enum Op {
    Constant(u8),
    Return,
}

#[derive(Debug, Clone, Copy)]
pub enum Value {
    Number(f64),
}

#[derive(Debug)]
pub struct Run {
    line: usize,
    count: usize,
}

impl Run {
    fn new(line: usize, count: usize) -> Self {
        Self { line, count }
    }
}
