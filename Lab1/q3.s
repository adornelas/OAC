.data
.include "maze.s"
CAMINHO: .space 153600 # Estimativa de pior caso: 4x 320x240/2 tamanho do maior labirinto

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
	
	
# Preenche a tela de vermelho
draw_maze:
	li t1,0xFF000000	# endereco inicial da Memoria VGA - Frame 0
	li t2,0xFF012C00	# endereco final 
	li t3,0xFFFFFFFF	# cor vermelho|vermelho|vermelhor|vermelho
LOOP: 	beq t1,t2,LAB		# Se for o último endereço então sai do loop
	sw t3,0(t1)		# escreve a word na memória VGA
	addi t1,t1,4		# soma 4 ao endereço
	j LOOP			# volta a verificar
	
# Carrega a imagem

LAB:	li 	t0,0xFF000000		# endereco inicial da Memoria VGA - Frame 0
	la 	s0,MAZE			# endereço dos dados da tela na memoria
	lw 	s1,0(s0)		# numero de colunas
	addi	s1,s1,1			# soma um pra ficar par
	li	s3,320			# ncol do display
	sub 	s3,s3,s1		# ncol total - ncol labirinto
	li	t4,2
	div	s3,s3,t4		# numero do espaçamento horizontal do display e labirinto
	li	t4,240			# nlin do display
	sub	t4,t4,s1		# nlin total - nlin labirinto
	li 	t5,2
	div	t4,t4,t5
	li 	t5,320
	mul	t4,t4,t5		#espaçamento vertial
	add	t4,t4,s3		#soma espaçamento em cima com espaçamento lateral
	add	t0,t0,t4		
	addi	s1,s1,1
	lw 	s2,4(s0)		# numero de linhas
	addi	s2,s2,1			# soma 1 pra ficar par
	li	t4,4
	mv	s4,s2
	addi 	s0,s0,8			# primeiro pixels depois das informações de nlin ncol
	addi	s1,s1,-1		# coloca numero real em nlin e ncol pra calcular o numero total de pixels
	addi	s2,s2,-1
	mul 	t1,s1,s2            	# numero total de pixels da imagem
	addi	s1,s1,1			# coloca numero real em nlin e ncol pra calcular o numero total de pixels
	addi	s2,s2,1
	li 	t2,0
LOOP1: 	bge 	t2,t1,VOLTA		# Se for o último endereço então sai do loop
	bge	t2,s4,PULA		# Se acabar a linha, vai pro PULA
	lw 	t3,0(s0)		# le um conjunto de *4 pixels* : word
	sw 	t3,0(t0)		# escreve a word na memória VGA
	addi 	t0,t0,4			# soma 4 ao endereço
	addi 	s0,s0,4
	addi 	t2,t2,4			# incrementa contador de bits
	j 	LOOP1			# volta a verificar	
PULA:	add	t0,t0,s3		# pula a linha
	add	t0,t0,s3
	add	s4,s4,s2
	j	LOOP1
	
VOLTA:	ret

#Resolve Maze (Primeira Linha)
## Como na última linha sempre tem só 1 branco, pinto ele de vermelho.
solve_maze:
	li	s4, 0x07070707		# Cor Vermelha
	lb	s3, 0(s0)		# Carrega no s3 o primeiro PIXEL
	and	s3, s3,s4		# Faz a operação AND com Vermelho e o PIXEL
	sb	s3, 0(t0)		# Colore o Pixel
	addi	s0, s0, -1
	addi	t0, t0, -1
	beqz	s2, SBODY		# Ve se acabou as colunas
	addi	s2, s2, -1
	jal	solve_maze	
	
#Resolve Maze (Corpo)

SBODY:	li	s8, 2
	mul	s8, s8, s1
	sub	t2, t2, s8		# Contador Precisa diminuir 2 vezes as linhas pois nao é percorrido
LOOPSB:	addi	t2, t2, -1
	beqz	t2, FIM
	addi	s0, s0, -1
	addi	t0, t0, -1
	lb 	t3, 0(t0)		# Início do labirinto
	bnez	t3, ARG
	jal	LOOPSB
	
ARG:	li	t6,0			# Esquerda
	li	s6,0
	li	s5, 0xFFFFFFFF
	lb	t3, -1(t0)
	beqz	t3, ARG2
	addi	t6,t6,1
ARG2:	lb	t3, -8(t0)		#Em cima
	beqz	t3, ARG3
	addi	t6,t6,1
ARG3:	lb	t3, 8(t0)		#Em baixo
	beqz	t3, ARG4
	sub	t3,t3,s5
	beqz	t3, ARG4
	addi 	t6,t6,1	
ARG4:	lb	t3, 1(t0)		#Direita
	beqz	t3, COMP
	sub	t3,t3,s5
	beqz	t3, COMP
	addi	t6,t6,1
COMP:	li	t5, 2
	bge	t6,t5,RED	
	j	LOOPSB

RED:	li	s7,0x07070707		# Variável Vermelha (Pixel 1)
	sb	s7, 0(t0)
	jal LOOPSB
	
# devolve o controle ao sistema operacional
FIM:	la 	s0,MAZE			# endereço dos dados da tela na memoria
	lw 	s1,0(s0)		# numero de colunas
	addi	s1, s1, 1
	addi	s0, s0, 8
	li 	t0, 0xFF000000		# endereco inicial da Memoria VGA - Frame 0
	li	t1, 0x07070707
LOOPF:	lw	t2, 0(s0)
	and	t2, t2,t1
	sw	t2, 0(t0)
	addi	s1, s1, -4
	addi	s0, s0, 4
	addi	t0, t0, 4
	bnez 	s1, LOOPF		# Se for o último endereço então sai do loop
	li a7,10		# syscall de exit
	ecall
