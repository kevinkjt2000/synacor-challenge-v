import os

type MemoryWord = u16

fn main() {
	mut memory := [32768]MemoryWord{}
	mut registers := [8]MemoryWord{}
	mut stack := []MemoryWord{cap: 1000}
	byte_code := os.read_file("challenge.bin")?
	for i in 0..(byte_code.len / 2) {
		low_byte := MemoryWord(byte_code[2*i])
		high_byte := MemoryWord(byte_code[2*i + 1])
		memory[i] = MemoryWord((high_byte << 8) + low_byte)
	}
	mut pc := 0
	for {
		op := memory[pc]
		match op {
			0 { //halt
				break
			}
			else {
				println("op($op) has not been coded yet")
			}
		}
		pc++
	}
}
