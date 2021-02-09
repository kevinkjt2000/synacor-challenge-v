import os

type MemoryWord = u16

enum Operation {
	halt = 0
	set = 1
	push = 2
	pop = 3
	eq = 4
	gt = 5
	jmp = 6
	jt = 7
	jf = 8
	add = 9
	mult = 10
	mod = 11
	and = 12
	@or = 13
	not = 14
	rmem = 15
	wmem = 16
	call = 17
	ret = 18
	out = 19
	@in = 20
	nop = 21
}

struct Machine {
mut:
	memory    [32768]MemoryWord
	registers [8]MemoryWord
	stack     []MemoryWord = []MemoryWord{cap: 1000}
	pc        int
}

fn (mut m Machine) load(path string) ? {
	byte_code := os.read_file(path) ?
	for i in 0 .. (byte_code.len / 2) {
		low_byte := MemoryWord(byte_code[2 * i])
		high_byte := MemoryWord(byte_code[2 * i + 1])
		m.memory[i] = MemoryWord((high_byte << 8) + low_byte)
	}
}

fn (m Machine) read_argument(address int) MemoryWord {
	val := m.memory[address]
	if val >= 32768 {
		return m.registers[val - 32768]
	}
	return val
}

fn (mut m Machine) write_to_register(reg int, val MemoryWord) {
	m.registers[reg - 32768] = val
}

fn (mut m Machine) run() {
	for {
		op := m.memory[m.pc]
		match Operation(op) {
			.push {
				a := m.read_argument(m.pc + 1)
				m.stack << a
				m.pc += 2
			}
			.pop {
				a := m.stack.pop()
				m.pc += 2
			}
			.set {
				a := m.memory[m.pc + 1]
				b := m.read_argument(m.pc + 2)
				m.write_to_register(a, b)
				m.pc += 3
			}
			.jf {
				a := m.read_argument(m.pc + 1)
				b := m.read_argument(m.pc + 2)
				if a == 0 {
					m.pc = b
				} else {
					m.pc += 3
				}
			}
			.jt {
				a := m.read_argument(m.pc + 1)
				b := m.read_argument(m.pc + 2)
				if a != 0 {
					m.pc = b
				} else {
					m.pc += 3
				}
			}
			.jmp {
				a := m.read_argument(m.pc + 1)
				m.pc = a
			}
			.out {
				a := m.read_argument(m.pc + 1)
				print(rune(a))
				m.pc += 2
			}
			.halt {
				break
			}
			.nop {
				m.pc++
			}
			else {
				panic("op($op) not implemented yet")
			}
		}
	}
}

fn main() {
	mut m := Machine{}
	m.load('challenge.bin') ?
	m.run()
}
