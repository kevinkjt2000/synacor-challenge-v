import os

type MemoryWord = u16
enum Operation {
	halt = 0
	out = 19
	@in = 20
	nop = 21
}

struct Machine {
mut:
	memory [32768]MemoryWord
	registers [8]MemoryWord
	stack []MemoryWord = []MemoryWord{cap:1000}
	pc int
}

fn (mut m Machine) load(path string) ? {
	byte_code := os.read_file(path) ?
	for i in 0..(byte_code.len / 2) {
		low_byte := MemoryWord(byte_code[2*i])
		high_byte := MemoryWord(byte_code[2*i + 1])
		m.memory[i] = MemoryWord((high_byte << 8) + low_byte)
	}
}

fn (mut m Machine) run() {
	for {
		op := m.memory[m.pc]
		match Operation(op) {
			.out {
				arg := m.memory[m.pc+1]
				print(rune(arg))
				m.pc += 2
			}
			.halt {
				break
			}
			.nop {
				m.pc++
			}
			else {
				println("op($op) has not been coded yet")
				m.pc++
			}
		}
	}
}

fn main() {
	mut m := Machine{}
	m.load("challenge.bin") ?
	m.run()
}
