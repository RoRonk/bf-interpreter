.bss
buffer: .skip 60000

.text

.global main

format_str: .asciz "We should be executing the following code:\n%s"
input_str:	.asciz "%c"
output_str:	.asciz "%c"

main:
	# prologue
	pushq %rbp 			# push the base pointer (and align the stack)
	movq %rsp, %rbp			# copy stack pointer value to base pointer
	# callee
	pushq %rbx			# callee saved register so we push onto the stack (BF pointer)
	pushq %r12			# callee saved register so we push onto the stack (Store string char)
	pushq %r13			# callee saved register so we push onto the stack (Instruction pointer)
	pushq %r14			# callee saved register so we push onto the stack (Store input memory address)

	call bf_start

	# callee
	popq %r14			# callee saved register so we pop back into r14
	popq %r13			# callee saved register so we pop back into r13
	popq %r12			# callee saved register so we pop back into r12
	popq %rbx			# callee saved register so we pop back into rbx
	# epilogue
	movq %rbp, %rsp			# clear local variables from stack
	popq %rbp			# restore base pointer location 
	ret

bf_start:
	# prologue
	pushq %rbp 			# push the base pointer (and align the stack)
	movq %rsp, %rbp			# copy stack pointer value to base pointer

	movq $0, %r13			# set instruction pointer at 0
	movq $0, %rbx			# set memory pointer at 0
	movq %rdi, %r14			# move string pointer to R14

	movq $0, %r12 			# empty R12
	movb (%r14, %r13), %r12b	# grabs the (r13)th byte (ASCII-char) at the bf-file starting from the address on r12

	cmpb $0, %r12b			# if -- is 0, then the string is empty  (we have reached the end of the string)
	je	bf_end			# jump to bf_end
	jmp bf_loop			# jump to bf_loop

next_command:
	incq %r13			# point to next instruction
	movq $0, %r12 			# empty R12
	movb (%r14, %r13), %r12b	# grabs the (r13)th byte (ASCII-char) at the bf-file starting from the address on r12

	cmpb $0, %r12b			# if R12 is 0, then the string is empty  (we have reached the end of the string)
	je	bf_end			# jump to bf_end

bf_loop:

	cmpb $62, %r12b			# compare R12B to 62 '<'
	je bf_move_right		# if equal, jump move data pointer to the right
	
	cmpb $60, %r12b			# compare R12B to 60 '>'
	je bf_move_left			# if equal, jump move data pointer to the left

	cmpb $43, %r12b			# compare R12B to 43 '+'
	je bf_incr_cell			# if equal, jump increment memory cell
	
	cmpb $45, %r12b			# compare R12B to 45 '-'
	je bf_decr_cell			# if equal, jump iecrement memory cell
	
	cmpb $46, %r12b			# compare R12B to 46 '.'
	je bf_output_char 		# if equal, jump output character
	
	cmpb $44, %r12b			# compare R12B to 44 ','
	je bf_input_char		# if equal, jump input a character and store it in the cell
	
	cmpb $91, %r12b			# compare R12B to 91 '['. [ 91 Jump past the matching ] if the cell at the pointer is 0
	je bf_open_bracket		# if equal, jump to bf_open_bracket
	
	cmpb $93, %r12b			# compare R12B to 93 ']'. ] 93 Jump back to the matching [ if the cell at the pointer is nonzero
	je bf_closed_bracket		# if equal, jump to bf_open_bracket

	jmp next_command		# char in R12B is not a instruction, get next instruction until we find 0 (end of string)

bf_move_right:
	incq %rbx			# move data pointer 1 to the right
	jmp next_command		# jump to next_command

bf_move_left:
	decq %rbx			# move data pointer 1 to the left
	jmp next_command		# jump to next_command

bf_incr_cell:
	incb buffer(, %rbx, 1)		# increments the byte at [buffer + %RBX]
	jmp next_command		# jump to next_command

bf_decr_cell:
	decb buffer(, %rbx, 1)		# increments the byte at [buffer + %RBX]
	jmp next_command		# jump to next_command

bf_output_char:
	movq $0, %rax			# no vector register
	movq $0, %rsi			# empty %RSI to put the char in
	movq $output_str, %rdi		# move output_str to %RDI
	addb buffer(, %rbx, 1), %sil	# move the byte at [buffer + %RBX] to %SIL (%RSI)

	call printf			# call printf
	jmp next_command		# jump to next_command

bf_input_char:
	subq $16 , %rsp 		# reserve stack space for variable
	leaq -16(%rbp) , %rsi 		# load address of stack in rsi
	movq $input_str, %rdi 		# load first argument of scanf
	movq $0 , %rax 			# no vector registers for scanf
	call scanf 			# call scanf

	movq -16(%rbp), %rdi		# move the byte at [buffer + %RBX] to %SIL (%RSI)
	movb %dil, buffer(, %rbx, 1)	# move rdi to memory cell
	addq $16, %rsp			# add 16 to %RSP	

	jmp next_command		# jump to next_command

bf_open_bracket:
	cmpb $0, buffer(, %rbx, 1) 	# compare current cell value with 0
	jne next_command		# if not equal, then jump to next_command (continue with next instruction)
	movq $0, %rdi			# else we jump past the matching closing bracket and set counter of opening brackets (RDI) to 0

bf_jump_past:
	// Step 1
	incq %r13			# increment instruction pointer (get next instruction)
	// Step 2.1
	cmpb $91, (%r14, %r13)		# compare R12B to 91 '[' 
	jne not_open_bracket		# if not '[', then jump to not_open_bracket
	incq %rdi			# else increment counter (RDI)
	jmp bf_jump_past		# loop

	not_open_bracket:
	// Step 2.2
	cmpb $93, (%r14, %r13)		# compare R12B to 93 ']' 
	jne bf_jump_past		# Step 3 - if not ']', then it is a regular instruction thus loop
	// Step 2.2.1
	cmpq $0, %rdi			# else if counter (RDI) == 0
	jle next_command		# then this is the matching bracket
	// Step 2.2.2
	decq %rdi			# else this is not the matching bracket
	jmp bf_jump_past		# so loop till we do find it

bf_closed_bracket:
	cmpb $0, buffer(, %rbx, 1) 	# checks if current cell is 0
	je	next_command		# if equal, then jump to next_command (continue with next instruction)
	movq $0, %rdi			# else we jump infront of the matching opening bracket and set counter of closing brackets (RDI) to 0

bf_jump_back:
	// Step 1
	decq %r13			# increment instruction pointer (get next instruction)
	// Step 2.1
	cmpb $93, (%r14, %r13)		# compare R12B to 93 ']' 
	jne not_closed_bracket		# if not ']', then jump to not_closed_bracket
	incq %rdi			# else increment counter (RDI)
	jmp bf_jump_back		# loop

	not_closed_bracket:
	// Step 2.2
	cmpb $91, (%r14, %r13)		# compare R12B to 91 '[' 
	jne bf_jump_back		# Step 3 - if not '[', then it is a regular instruction thus loop
	// Step 2.2.1
	cmpq $0, %rdi			# else if counter (RDI) == 0
	jle next_command		# then this is the matching bracket
	// Step 2.2.2
	decq %rdi			# else this is not the matching bracket
	jmp bf_jump_back		# so loop till we do find it

bf_end:
	# epilogue
	movq %rbp, %rsp			# clear local variables from stack
	popq %rbp			# restore base pointer location 
	ret
