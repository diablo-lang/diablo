use crate::chunk::{Chunk, Op};

pub fn disassemble_chunk(chunk: &Chunk, name: &str) {
    println!("== {} ==", name);

    for value in chunk.code.iter() {
        // println!("{:04} {:#?}", index, value);
        match value {
            Op::Constant(index) => println!("OP_CONSTANT: {:?}", chunk.read_constant(*index)),
            Op::Return => println!("OP_RETURN"),
            _ => println!("[!] Instruction Not Found"),
        }
    }
}
