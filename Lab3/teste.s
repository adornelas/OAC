.eqv N 32

.data
#Vetor:  .word 9,2,5,1,8,2,4,3,6,7,10,2,32,54,2,12,6,3,1,78,54,23,1,54,2,65,3,6,55,31,4,-4

.text	
MAIN:	jal INICIALIZA #vai pra função que carrega o vetor
	li a0, 0x10010000 #move 0 para a0, limpando a0, que era usado para colocar coisas na memória
	li a1,N #a1 = 32, tamanho do vetor
	jal SORT #vai pra sort

	li a0,0x10010000
	li a1,N
	jal SHOW

	j FIM


SWAP:	slli t1,a1,2     #t1 = a1*4
	add t1,a0,t1     #t1 = a0 + t1
	lw t0,0(t1)      #carrega o que está em t1 (a1*4 + a0)
	lw t2,4(t1)
	sw t2,0(t1)
	sw t0,4(t1)
	ret

SORT:	addi sp,sp,-20    #abre 4 espaços na pilha
	sw ra,16(sp)      #bota o return adress na pilha
	sw s3,12(sp)      #bota o que tá em s3 na pilha
	sw s2,8(sp)
	sw s1,4(sp)
	sw s0,0(sp)
	mv s2,a0          #s2 recebe a0
	mv s3,a1          #s3 recebe a1
	mv s0,zero        #limpa s0
for1:	slt t6,s0,s3      #set t6 = s0 < s3
	beq t6,zero,exit1 # if s3 > s0 : exit1
	addi s1,s0,-1     #s1 = s0 -1
for2:	slt t6,s1,zero    #t6 = s1 < 0
	li tp,1           #local thread = 1
	beq t6,tp,exit2   #exit2 se t6 = 1
	slli t1,s1,2      #t1 = s1*4
	add t2,s2,t1      #t2 = s2 + t1
	lw t3,0(t2)       #t3 = o que tá no endereço t2 // t2 = s2 + t1 // t2 = a0 + s1*4 // t2 = a0 + (s0 -1)*4 
	lw t4,4(t2)
	slt t6,t4,t3      #se o numero na frente for maior que o menor, seta t6. Ou seja t6 = 1 se a ordem está correta.
	beq t6,zero,exit2 #vai pra exit2 se a ordem está errada.
	mv a0,s2          #a0 = s2
	mv a1,s1          #a1 = s1
	jal SWAP          #vai pro SWAP
	addi s1,s1,-1
	j for2
exit2:	addi s0,s0,1
	j for1
exit1: 	lw s0,0(sp)
	lw s1,4(sp)
	lw s2,8(sp)
	lw s3,12(sp)
	lw ra,16(sp)
	addi sp,sp,20
	ret

SHOW:	mv t0,a0
	mv t1,a1
	mv t2,zero

loop1: 	beq t2,t1,fim1
	lw a0,0(t0)
	addi t0,t0,4
	addi t2,t2,1
	j loop1
fim1:	ret


INICIALIZA:       # Inicializa a RAM de dados com o vetor a apartir do endereço 0x00000000
#Vetor:  .word 9,2,5,1,8,2,4,3,
	li s6, 0x10010000 #s6 recebe o endereço onde colocar a memória
	li a0,9 
	sw a0,0(s6)
	li a0,2
	sw a0,4(s6)	
	li a0,5
	sw a0,8(s6)
	li a0,1
	sw a0,12(s6)	
	li a0,8
	sw a0,16(s6)
	li a0,2
	sw a0,20(s6)	
	li a0,4
	sw a0,24(s6)
	li a0,3
	sw a0,28(s6)	
	#Vetor:  .word 6,7,10,2,32,54,2,12,
	li a0,6
	sw a0,32(s6)
	li a0,7
	sw a0,36(s6)	
	li a0,10
	sw a0,40(s6)
	li a0,2
	sw a0,44(s6)	
	li a0,32
	sw a0,48(s6)
	li a0,54
	sw a0,52(s6)	
	li a0,2
	sw a0,56(s6)
	li a0,12
	sw a0,60(s6)	
	
	#Vetor:  .word 6,3,1,78,54,23,1,54
	li a0,6
	sw a0,64(s6)
	li a0,3
	sw a0,68(s6)	
	li a0,1
	sw a0,72(s6)
	li a0,78
	sw a0,76(s6)	
	li a0,54
	sw a0,80(s6)
	li a0,23
	sw a0,84(s6)	
	li a0,1
	sw a0,88(s6)
	li a0,54
	sw a0,92(s6)	

	#Vetor:  .word 2,65,3,6,55,31,4,-4
	li a0,2
	sw a0,96(s6)
	li a0,65
	sw a0,100(s6)	
	li a0,3
	sw a0,104(s6)
	li a0,6
	sw a0,108(s6)	
	li a0,55
	sw a0,112(s6)
	li a0,31
	sw a0,116(s6)	
	li a0,4
	sw a0,120(s6)
	li a0,-4
	sw a0,124(s6)	

	ret
	
FIM:	li a7, 10
	ecall