.data
.include "maze.s"
CAMINHO: .space 153600 # Estimativa de pior caso: 4x 320x240/2 tamanho do maior labirinto

BIFURC:	.space 1000

.text
MAIN: 	la a0,MAZE
	jal draw_maze
	la a0,MAZE
	la a1,CAMINHO
	jal solve_maze
#	la a0,CAMINHO
#	jal animate
	li a7,10
	ecall
	
	
# Preenche a tela de branco
draw_maze:
	li t1,0xFF000000	# endereco inicial da Memoria VGA - Frame 0
	li t2,0xFF012C00	# endereco final 
	li t3,0xFFFFFFFF	# cor branco|branco|branco|branco
LOOPbs:
 	beq t1,t2,LAB		# Se for o ?ltimo endere?o ent?o sai do loop
	sw t3,0(t1)		# escreve a word na mem?ria VGA
	addi t1,t1,4		# soma 4 ao endere?o
	j LOOPbs		# volta a verificar
	
# Carrega a imagem

LAB:
	la	s0, MAZE		# S0 ( Endere?o Atual Labirinto )
	li	t0,0xFF009600		# Endere?o do meio
	lw 	s1,0(s0)		# N?mero de Colunas
	addi	s1,s1,1			# Acrescenta 1 nas Colunas
	lw 	s2,4(s0)		# N?mero de linhas
	addi	s2,s2,1			# Acrescenta 1 nas linhas
	addi 	s0,s0,8			# Primeiro pixel depois das informa??es de linhas e colunas
 	li	t2, 320			# Resolu??o Largura
 	li 	t3, 2			# Divisor 2
 	div	t1, s2, t3		# N?mero de Linhas / 2
 	mul	t1, t1, t2		# Multiplico (Linhas / 2 * 320)
 	neg	t1, t1			# (N?mero de Linhas / 2)*(320) (Negativo)
 	li	t2, 160
 	add	t0, t0, t1		# Subtraio do Endere?o Inicial
 	div	t3, s1,t3		# N?mero de Colunas / 2
 	sub	t4, t2,t3
 	add	t0, t0, t4		# Endere?o Inicial = Meio Deslocamento Direita -> Coluna
 	add	t4, t4, t4		
 	mv	s3, t0			# Endere?o Inicial
 	mul	t1, s1, s2		# Quantidade de Pixels no Labirinto
 	li	t2,0			# Zera contador de Linha
 	j	LOOP
 	
new_line:
	li	t2,0
	add	t0, t0, t4
	 	
LOOP:	beqz 	t1, FLOOP		# Se for o ?ltimo endere?o ent?o sai do loop
	lw	t3,0(s0)
	sw 	t3,0(t0)		# escreve a word na mem?ria VGA
	addi 	t1,t1,-4		# soma 4 ao endere?o
	addi	s0,s0,4
	addi	t0,t0,4
	addi	t2,t2,4
	bge	t2, s1, new_line
	j 	LOOP			# volta a verificar
FLOOP:	ret

animate:			#a0 tem maze e a1 tem CAMINHO
	li	t2,0x07070707	# cor vermelho
	li	t3,0		
	la	s0,CAMINHO	# endere?o dos passos
	lw	s1,0(s0)	# numero de passos
	addi	s0,s0,4
LOOPANIMATE:
	beq	t3,s1,FIMANIMATE#se for ?ltimo passo, sai do loop
	lw	s2,0(s0)	# primeiro dado (coluna)
	addi	s0,s0,4
	lw	s3,0(s0)	# segundo dado (linha)
	li	t4,320
	mul 	t4,t4,s3	#ncoltotal * Numero de linhas
	add	t4,t4,s2	#t4= 320*nlin + ncol
	li	t0,0xFF000000	# endereco inicial da Memoria VGA - Frame 0
	add	t0,t0,t4	#soma o valor ao endere?o da VGA
	sb 	t2,0(t0)	# escreve vermelho na mem?ria VGA
	addi	t3,t3,1
	addi	s0,s0,4
	j	LOOPANIMATE
	

FIMANIMATE:
	ret
	
solve_maze:
	#ebreak
	li	t6, 0x07070707		# Cor Vermelha
	li	t2, 320			# Resolu??o Largura
	li	t1, 2
	la	a2, BIFURC
	div	t1, s1, t1
	add	s3, s3, t1		# Come?ando pelo Primeiro Pixel
	addi	s3, s3, -1		# Ajusta primeiro pixel
	sb	t6, 0(s3)		# Carrega no s3 o primeiro PIXEL
	mv	t1, s3			# Endere?o do s3
	
	ebreak
	addi	s2, s2, -1
	mul	t4, t2, s2
	add	a4, s3,t4		# Endere?o do PIXEL ALVO 
	#sb	t6, 0(a4)		# Carrega no s3 o primeiro PIXEL
	
	sw	t1, 0(a1)		# Armazena primeiro endere?o no "CAMINHO"
	addi	a1, a1, 4
	addi	s11, s11, 4
	add	t1, t1, t2		# Descendo o Pixel
	jal 	ANDA
	
	
AGAIN:	ebreak
	jal	VIZINHOS
	beq	t4, zero, SEM_SAIDA
	li	t3, 1
	bgt	t4, t3, NO_RECURSIVO
	jal	ANDA_LADO
	j	AGAIN
	

############################### Confere Pixels Vizinhos ###############################
VIZINHOS:
# Confere Pixel da Esquerda
	li	t4, 0
	li	s2, 0
	li	s3, 0
	li	s4, 0
	li	s5, 0
	addi	t1, t1, -1
	lb	t3, 0(t1)
	lw	t5, -8(a1)
	mv	t6, t1
	addi	t1, t1, 1
	beq	t5, t6, EMBAIXO
	beqz	t3, EMBAIXO
	addi	t4, t4, 1
	li	s2, 1			# s2 indica vizinho esquerdo
EMBAIXO:
	add	t1, t1, t2		# Confere Pixel de Baixo
	lb	t3, 0(t1)
	mv	t6, t1
	sub	t1, t1, t2
	beq	t5, t6, LADODIR
	beqz	t3, LADODIR	
	addi	t4, t4, 1
	li	s3, 1			# s3 indica vizinho em baixo
LADODIR:				# Confere Pixel da Direita
	addi	t1, t1, 1
	lb	t3, 0(t1)
	mv	t6, t1
	addi	t1, t1, -1
	beq	t5, t6, EMCIMA
	beqz	t3, EMCIMA
	addi 	t4, t4, 1
	li	s4, 1			# s2 indica vizinho direito
EMCIMA:
	sub	t1, t1, t2		# Confere Pixel de Cima
	lb	t3, 0(t1)
	mv	t6, t1
	add	t1, t1, t2
	beq	t5, t6, RETORNA
	beqz	t3, RETORNA
	addi	t4, t4, 1
	li	s5, 1
	ret
############################### Conferido Pixels Vizinhos ###############################
############################### s2, s3, s4, s5 (Vizinhos) ###############################
############################### Sem Sa?da / Com Vizinnhos ############################### 

ANDA_LADO:
	beqz 	s2, AAA			# S2 = 0 -> nada no lado ESQUERDO
	addi	t1, t1, -1
	## ANDA ##
	sb	t6, 0(t1)		# Carrega no s3 o primeiro PIXEL
	sw	t1, 0(a1)
	addi	a1, a1, 4
	addi	s11, s11, 4
	## ##
	ret
AAA:	beqz	s3, BBB			# S3 = 0 -> nada EM BAIXO
	add	t1, t1, t2
	## ANDA ##
	sb	t6, 0(t1)		# Carrega no s3 o primeiro PIXEL
	sw	t1, 0(a1)
	addi	a1, a1, 4
	addi	s11, s11, 4
	## ##	
	ret
BBB:	beqz	s4, CCC			# S4 = 0 -> nada no lado DIREITO
	addi	t1, t1, 1
	## ANDA ##
	sb	t6, 0(t1)		# Carrega no s3 o primeiro PIXEL
	sw	t1, 0(a1)
	addi	a1, a1, 4
	addi	s11, s11, 4
	## ##
	ret
CCC:	beqz	s5, RETORNA		# S5 = 0 -> nada EM CIMA
	sub	t1, t1, t2
	## ANDA ##
	sb	t6, 0(t1)		# Carrega no s3 o primeiro PIXEL
	sw	t1, 0(a1)
	addi	a1, a1, 4
	addi	s11, s11, 4
	## ##
	ret
ANDA:
	li	t6, 0x07070707
	sb	t6, 0(t1)		# Carrega no s3 o primeiro PIXEL
	sw	t1, 0(a1)
	addi	a1, a1, 4
	addi	s11, s11, 4
	ret
	
NO_RECURSIVO:
	sw 	t1, 0(a2) 		# empilha t1
	addi	a2, a2, 4
	addi	s10, s10, 1
	jal	ANDA_LADO
	jal	VIZINHOS
	beq	t4, zero, SEM_SAIDA
	li	t3, 1
	bgt	t4, t3, NO_RECURSIVO
	jal	ANDA_LADO
	j	AGAIN
	beq 	t1, a4, AGAIN 		
	add 	a0, zero, zero 		
	addi 	sp, sp, 8 		
	ret 				# retorna para a chamadora
	
L1:
	addi 	a0, a0, -1 		# argumento passa a ser (n-1)
	jal 	NO_RECURSIVO 		# 
	
	ret
	
SEM_SAIDA:
	beq	a4, t1, FIM
	lw 	a0, 0(a2)
	addi	a2, a2, -4
LOOPSS:	addi	s10, s10, -4
	sw	zero, 0(a1)
	addi	a1, a1, -4
	ebreak
	lw	t3, 0(a1)
	li	t6, 0xFFFFFFFF
	sb	t6, 0(t3)
	bne	t3, a0, LOOPSS
	
RETORNA:
	ret
	
CHEGOU:
	li 	a0, 1
	ret
# devolve o controle ao sistema operacional
FIM:	li a7,10		# syscall de exit
	ecall
