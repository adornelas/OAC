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
	
	
	addi a0, zero, 1
	addi a1, zero, 3
	and a2, a0, a1		# a2 = 0x00000001
	or a2, a0, a1		# a2 = 0x00000003
	xor a2, a0, a1		# a2 = 0x00000002
	slt a2, a1, a0		# a2 = 0x00000001
	
	jal a3, PULO		# pula pra PULO
	addi a0, a0, 1		# não deve rodar
	addi a0, a0, 2		# não deve rodar

PULO:	add a1, a0, zero	# a1 = 0x00007000
	beq a0, a1, PULO2	# pula pra PULO2
	addi a0, a0, 3		# não deve rodar
	addi a0, a0, 4		# não deve rodar

PULO2:	jalr a0, a0, 2		# a0 = pc, pula 2 instruções
	addi a1, a1, 5		# não deve rodar
	addi a1, a1, 6		# não deve rodar
