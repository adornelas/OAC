.include “MAZE.s”
CAMINHO: .space 153600 # Estimativa de pior caso: 4x 320x240/2 tamanho do maior labirinto

.text
MAIN:	la a0,MAZE
	jal draw_maze
	la a0,MAZE
	la a1,CAMINHO
	jal solve_maze
	la a0,CAMINHO
	jal animate
	li a7,10
	ecall