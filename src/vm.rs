use crate::error::DiabloError;

pub struct Vm {}

impl Vm {
    pub fn new() -> Self {
        let mut vm = Self {};
        vm
    }

    pub fn interpret(&mut self, code: &str) -> Result<(), DiabloError> {
        Ok(())
    }
}
