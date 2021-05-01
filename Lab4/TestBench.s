.text

INICIO:
	addi a0, zero, 10	# a0 = 0x0000000A
	add a1, a0, a0		# a1 = 0x00000014
	sub a1, a1, a0		# a1 = 0x0000000A
	addi a0, a0, 2		# a0 = 0x0000000C
	
	sw a0, 0(zero)
	lw a1, 0(zero)
	addi a1, a1, 0		# a1 = 0x0000000C
	
	slli a0, a0, 2		# a0 = 0x00000030
	lui a0, 7		# a0 = 0x00007000
	
	
	addi a0, zero, 0
	addi a1, zero, 1
	and a2, a0, a1		# a2 = 0x00000000
	or a2, a0, a1		# a2 = 0x00000001
	xor a2, a0, a1		# a2 = 0x00000001
	slt a2, a0, a1		# a2 = 0x00000001
	
	jal a3, PULO		# pula pra PULO
	li a0, 0xEEEEEEEE 	# não deve rodar
	li a0, 0xEEEEEEEE	# não deve rodar

PULO:	add a1, a0, zero	# a1 = 0x00007000
	beq a0, a1, PULO2	# pula pra PULO2
	li a0, 0xEEEEEEEE	# não deve rodar, a0=0xEEEEEEEE
	li a0, 0xEEEEEEEE	# não deve rodar, a0=0xEEEEEEEE

	li a0, 0xCCCCCCCC	# deve rodar ao final, a0=0xCCCCCCCC
	jal a3, FIM

PULO2:	li a1, 0x00000000	# a1 = 4
	jalr a0, a1, 100	# a0 = pc, vai pra ultima instrução
	li a0, 0xEEEEEEEE	# não deve rodar, a0=0xEEEEEEEE
	li a0, 0xEEEEEEEE	# não deve rodar, a0=0xEEEEEEEE
	li a0, 0xEEEEEEEE	# não deve rodar, a0=0xEEEEEEEE
	
FIM:	li a1, 0xCCCCCCCC