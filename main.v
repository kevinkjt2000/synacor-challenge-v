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
	if address >= 32768 {
		return m.registers[address - 32768]
	}
	return m.memory[address]
}

fn (mut m Machine) run() {
	for {
		op := m.memory[m.pc]
		match Operation(op) {
			.jt {
				a := m.read_argument(m.pc + 1)
				b := m.read_argument(m.pc + 2)
				if a != 0 {
					m.pc = b
				} else {
					m.pc++
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
				println('op($op) has not been coded yet')
				m.pc++
			}
		}
	}
}

fn main() {
	mut m := Machine{}
	m.load('challenge.bin') ?
	m.run()
}
