.data
.include "maze.s"
CAMINHO: .space 153600 # Estimativa de pior caso: 4x 320x240/2 tamanho do maior labirinto
#CAMINHO: .word 11,159,116,159,117,158,117,157,117,157,118,157,119,158,119,159,119,159,120,159,121,159,122  # onde 100 inicial é o número de passos e as duplas (160,120) (160,121)
.text
MAIN: 	la a0,MAZE
	jal draw_maze
	la a0,MAZE
	la a1,CAMINHO
#	jal solve_maze
#	la a0,CAMINHO
#	jal animate
	li a7,10
	ecall
	
	
# Preenche a tela de branco
draw_maze:
	li t1,0xFF000000	# endereco inicial da Memoria VGA - Frame 0
	li t2,0xFF012C00	# endereco final 
	li t3,0xFFFFFFFF	# cor branco|branco|branco|branco
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
	addi	s1,s1,1			# tira o numero real em nlin e ncol
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

animate:			#a0 tem maze e a1 tem CAMINHO
	li	t2,0x07070707	# cor vermelho
	li	t3,0		
	la	s0,CAMINHO	# endereço dos passos
	lw	s1,0(s0)	# numero de passos
	addi	s0,s0,4
LOOP2:	beq	t3,s1,FIMANIMATE#se for último passo, sai do loop
	lw	s2,0(s0)	# primeiro dado (coluna)
	addi	s0,s0,4
	lw	s3,0(s0)	# segundo dado (linha)
	li	t4,320
	mul 	t4,t4,s3	#ncoltotal * Numero de linhas
	add	t4,t4,s2	#t4= 320*nlin + ncol
	li	t0,0xFF000000	# endereco inicial da Memoria VGA - Frame 0
	add	t0,t0,t4	#soma o valor ao endereço da VGA
	sb 	t2,0(t0)	# escreve vermelho na memória VGA
	addi	t3,t3,1
	addi	s0,s0,4
	j	LOOP2
	

FIMANIMATE:
	ret
	
	



#solve_maze:				#a0 tem MAZE e a1 tem CAMINHO
#	lw 	s1,0(s0)		# numero de colunas				
#	srli	t0,s1,1			#t0 = (N/2)
#	addi	t0,t0,-1		#t0-- (primeiro lugar do labirinto)
#	addi	a1,a1,1			#pula a primeira posicao do CAMINHO
#	addi	s2,s2,1			#salva o indice de CAMINHO
#	sw	t0,0(a1)		#salva o primeiro numero da coluna
#	mv	s3,t0				#salva em s3 a coluna anterior
#	addi	a1,a1,4			#pula a posicao do CAMINHO
#	addi	s2,s2,1			#salva o indice de CAMINHO	
#	sw	zero,0(a1)		#salva a primeira linha em CAMINHO
#	mv	s4,zero				#salva em s4 a linha anterior
#	addi	a1,a1,4			#pula a posicao do CAMINHO
#	addi	s2,s2,1			#salva o indice de CAMINHO
#	sw	t0,0(a1)		#salva coluna da segunda posição
#	mv	s5,t0				#salva em s5 a coluna atual
#	addi	a1,a1,4			#pula a posicao do CAMINHO
#	addi	s2,s2,1			#salva o indice de CAMINHO
#	li	t0,1
#	sw	t0,0(a1)		#salva linha da segunda posição
#	mv	s6,t0				#salva em s6 a linha atual
#	addi	a1,a1,4			#pula a posicao do CAMINHO
#	addi	s2,s2,1			#salva o indice de CAMINHO
#LOOP2:	beq	s6,s6,VOLTA		#se chegou na ultima linha volta
#	blt	s6,s4,CIMA		#se andou pra cima
#	
#CIMA:					#se tem parede a direita, segue reto
					#se nao, vire a direita
