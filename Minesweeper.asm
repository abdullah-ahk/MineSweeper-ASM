	.data
file:	.asciiz	"mine_record.dat"
continue:
	.asciiz	"Continue? (y/n):"
welcome:
	        .asciiz "  ╔══════════════════════════════════╗\n"
                .asciiz "  ║        MINESWEEPER v1.0          ║\n"
                .asciiz "  ╠══════════════════════════════════╣\n"
                .asciiz "  ║                                  ║\n"
                .asciiz "  ║  Select Difficulty Level:        ║\n"
                .asciiz "  ║                                  ║\n"
                .asciiz "  ║   Beginner    - 9×9, 10 mines    ║\n"
                .asciiz "  ║   Intermediate-16×16,40 mines    ║\n"
                .asciiz "  ║   Advanced    -30×16,99 mines    ║\n"
                .asciiz "  ║   Custom      - Set your own     ║\n"
                .asciiz "  ║                                  ║\n"
                .asciiz "  ║                                  ║\n"
                .asciiz "  ║                                  ║\n"
                .asciiz "  ╚══════════════════════════════════╝\n"
c_row:	.asciiz "Enter number or rows:" 
c_col: 	.asciiz "Enter number or columns:"
n_bomb:	.asciiz	"Enter number of bomb(): "
new:	.asciiz	"\n"
title:	.asciiz "\fMinesweeper 	Bombs:         Time:"							
score:	.ascii	"\n\tÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»\n"
	.ascii	"\tº        Leader Board         º\n"
	.ascii	"\tº Difficulty:                 º\n"
	.ascii  "\tº Best Time:                  º\n"
	.ascii	"\tº Your Time:                  º\n"
	.ascii	"\tº Wins:                       º\n"
	.ascii	"\tº Losses:                     º\n"
	.ascii	"\tÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼\n"
	.asciiz	"Press enter to continue"
custom: .asciiz "\nCustom"
cus: 	.asciiz "Custom"
begg: 	.asciiz "Begginer"
inter: 	.asciiz "Intermidiate"
adv: 	.asciiz "Advanced"
win:	.asciiz	"\fYou Won!!!"
loss:	.asciiz	"\fYou Loose!!!"
default: .asciiz "\nPlease input again!!!" 
number:	.space 9
bomb 	= 0x0f
mark 	= 0xfa 
blank 	= 0xda 
hide 	= 0xf0
space 	= 0x20
expo 	= 0xfa
screen: .word 	0:500
mandf:	.word	
buffer: .space 15
 	.extern mines,word
 	.extern lfsr,word 
	.extern grid,word
	.extern col,word
	.extern row,word
	.extern	flag,word
	.extern	option,word
	.extern	case,word
times:	.double	0,0
	.double 0,0.125
	.double 0,0.25
	.double	0,0.5
	.double	0,1.0
 	.code
 	.globl main
main: 	la 	$a0,file     	# output file name
  	li 	$a1,0        	# flags
  	syscall	$open         	# open a file (file descriptor returned in $v0)
  	move 	$s7,$v0    	# save file descriptor in $t0	



	
	addi 	$a0,$0,\f
 	syscall $print_char # clear screen
	addi 	$a0,$0,\f
	syscall $print_char # clear screen
0: 	la $a0,welcome
	syscall $print_string
	la 	$a0,buffer # load address of input buffer into a0
	li 	$a1,15 # lenght of buffer, n
	syscall $read_string
	la 	$a0,buffer
	lb 	$v0,($a0)
	sb	$v0,case($gp)
1:	syscall	$random
	beqz	$v0,1b	
	sw	$v0,lfsr($gp)
switch: mov	$s5,$0
	lb	$v0,case($gp)
	la 	$t2,jumpTable 		#get base address of tables
	addi 	$t0,$v0,-'a 		#subtract lowest case
	sltiu 	$t1,$t0,CASES 		#number too high or too low?
	beqz 	$t1,def 		#then branch to default
	sll 	$t0,$t0,2 		#multiply by word size (x4)
	add 	$t2,$t2,$t0 		#add to table base address
	lw 	$t4,($t2) 		#load pointer from jump table
	jr 	$t4 			#jump to correct case
jumpTable:
 	.word case_a,case_b,case_c,def,def,def,def,def,case_i
endJTable:
CASES = endJTable-jumpTable/4
case_a: addi 	$a0,$0,\f
 	syscall $print_char
 	addi 	$a1,$0,30
 	addi 	$a2,$0,16
 	addi 	$t0,$0,480
 	addi 	$v1,$0,99
	sw	$v1,mines($gp)
	sw	$t0,grid($gp)
	sw	$a2,row($gp)
	sw	$a1,col($gp)
	la	$t0,adv
	sw	$t0,option($gp)
 	jal 	board
 	b 	break
case_b: addi 	$a0,$0,\f
 	syscall $print_char
 	addi 	$a1,$0,9
 	addi 	$v1,$0,10
	addi	$t0,$0,81
	sw	$v1,mines($gp)
	sw	$t0,grid($gp)
	sw	$a1,row($gp)
	sw	$a1,col($gp)
	la	$t0,begg
	sw	$t0,option($gp)
 	jal 	board
 	b 	break
case_c: addi 	$a0,$0,\f
	syscall $print_char
	la 	$a0,custom
	la 	$a0,c_row
	syscall $print_string
	syscall $read_int
	mov 	$a1,$v0
	blt 	$a1,1,case_c
	bgt 	$a1,79,case_c
	la 	$a0,c_col
	syscall $print_string
	syscall $read_int
	mov	$a2,$v0
	blt 	$a2,1,case_c
	bgt 	$a2,23,case_c
	addi 	$v1,$0,10
	la 	$a0,n_bomb
	syscall $print_string
	syscall $read_int
	mov	$v1,$v0
	sw	$v1,mines($gp)
	mul	$t0,$a1,$a2
	sw	$t0,grid($gp)
	sw	$a2,row($gp)
	sw	$a1,col($gp)
	la	$t0,cus
	sw	$t0,option($gp)
 	jal 	board
 	b 	break
def: 	la 	$a0,default
 	syscall $print_string 
 	b 	0b
case_i: addi 	$a0,$0,\f
 	syscall $print_char 
 	addi 	$a1,$0,16
 	addi 	$t0,$0,256
 	addi 	$v1,$0,40
	sw	$v1,mines($gp)
	sw	$t0,grid($gp)
	sw	$a1,row($gp)
	sw	$a1,col($gp)
	la	$t0,inter
	sw	$t0,option($gp)
 	jal 	board
break: 	syscall $exit 
#-------------------------------------------------------------------------------
Print:	mov	$a0,$0
	mov	$a1,$0
	syscall	$xy
	la	$a0,title		#display title
	syscall	$print_string
	addi	$a0,$0,42
	mov	$a1,$0
	syscall	$xy			#display time
	la	$t6,times
	sll	$a0,$t7,4
	add	$a0,$a0,$t6
	syscall	$print_double
	addi	$a0,$0,22
	mov	$a1,$0
	syscall	$xy			# display number of mines
	lw	$a0,mines($gp)	
	syscall	$print_int
	mov	$a0,$0
	addi	$a1,$0,1
	syscall	$xy			# Print out array/game board
	la	$a1,screen		# a1 = array
	lw	$a2,grid($gp)
	mul	$a2,$a2,2		
	add	$a2,$a2,$a1		# a2 = end of array
	lw	$t2,col($gp)		# t2 = number of row
	mov	$t3,$t0
	mov	$t3,$t2			# t3 = counter
0:	bnez	$t3,1f			# if (t2!=0) branch 1f
	la	$a0,new			# print \n to go to  next line	
	syscall $print_string
	mov	$t3,$t2			# reset counter
1:	lb	$a0,byte($a1)		# load 2nd byte
	syscall $print_char		
	addi	$a1,$a1,half		# move array 
	addi	$t3,$t3,-1		# decrease t3 counter
 	bne 	$a1,$a2,0b		# go through whole array
	jr $ra
#-------------------------------------------------------------------------------
random: # lfsr = (lfsr >> 1) ^ (-(signed int)(lfsr & 1) & 0xd0000001u); 
 	lw 	$v0,lfsr($gp) # static unsigned int lfsr = 1; 
 	srl 	$v1,$v0,1 	# v1 = (lfsr >> 1)
 	andi 	$v0,$v0,1 	# lsfr = (lfsr & 1)
	neg 	$v0,$v0		# lsfr = -lsfr
	lui 	$t1,0xd0000001
	and 	$v0,$v0,$t1 	# lsfr = lsfr & 0xd0000001
 	xor 	$v0,$v1,$v0 	# lsfr = v1 ^ lsfr
 	sw 	$v0,lfsr($gp) 	# return lfsr; 
 	jr 	$ra 
#------------------------------------------------------------------------------
board:	la	$a0,title
	syscall	$print_string
	addi	$a0,$0,22
	mov	$a1,$0
	syscall	$xy
	lw	$a0,mines($gp)	
	syscall	$print_int
	mov	$a0,$0
	addi	$a1,$0,1
	syscall	$xy			# display fake board with everything hiden
	lw	$t1,grid($gp)		# t1 = array size
	lw	$t4,col($gp)		# t4 = number of columns
0:	bnez	$t4,1f			# if (t4!=0) branch 25+
	lw	$t4,col($gp)
	la	$a0,new			
	syscall $print_string
1:	addi	$a0,$0,hide
	syscall $print_char		
	addi	$t1,$t1,-1		# move counter 
	addi	$t4,$t4,-1		# decrease t4 counter
 	bnez 	$t1,0b			# go through whole array
	lw	$v1,mines($gp)
	sw	$v1,flag($gp)
	la 	$a0,screen		# a0 = array address
	lw	$t1,grid($gp)		# t1 = array size
	mul	$t1,$t1,half
	add 	$t2,$a0,$t1		# t2 = addres of last element
	b	2f			# no bomb in first 
3: 	beqz 	$v1,2f			# no bombs skip
 	add 	$t0,$0,bomb		# t0 = bomb
 	addi 	$v1,$v1,-1		# decrease bombs
 	b 	1f
2: 	add 	$t0,$0,space		
1: 	sb 	$t0,($a0) 		# store to array
 	addi 	$a0,$a0,half 		# move array
 	bne	$a0,$t2,3b

first:	
	addi	$a1,$0,3*record
	lw	$t1,col($gp)
	bne	$t1,9,1f
	mov	$a1,$0
1:	bne	$t1,16,2f
	addi	$a1,$0,record
2:	bne	$t1,30,3f	
	addi	$a1,$0,2*record
3:	mov	$a0,$s7
	mov	$a2,$0
	syscall	$position

	la	$a0,timer.flags		# 
	addi	$a1,$0,byte
	mov	$a2,$0
	syscall $IO_write
	addi	$t7,$0,1		# timer index
	addi	$t8,$0,2		# timer mask
	la	$t9,timer.t1		# timer hardware address pointer
2:					#do{
	move	$a0,$t9			# 
	syscall	$IO_read		# clear flag
	la	$t6,times
	sll	$a0,$t7,4
	add	$a0,$a0,$t6
	s.d	$0,($a0)		# }
4:	addi	$t7,$t7,1		# index++;
	sll	$t8,$t8,1		# mask<<1;
	addi	$t9,$t9,4		# pointer++;
	blt	$t7,8,2b		# }while index<8;<5
	mov.d	$f10,$0
	mov.d	$f12,$0
	la	$a0,mouse.flags
	mov	$a2,$0
	syscall	$IO_write
	sw	$0,mouseDownXY($gp)
	sw	$0,mouseDownButtons($gp)
	jal	poll
	srl	$t1,$v1,3		# mouse click type
	srl	$a1,$v0,16		# a1 = row
	andi	$a0,$v0,0x7f		# a0 = col
	mov	$a3,$a1			# a3 = a1
	mov	$a2,$a0			# a2 = a0
	lw	$t2,col($gp)		# t2 = columns
	addi	$t2,$t2,-1		# reduce column bc of range 
	lw	$t3,row($gp)		# t3 = rows
	beqz	$a1,0f			# range check
	bgt	$a1,$t3,0f		# 
	bgt	$a0,$t2,0f
	addi	$s5,$0,1	
	b	shuffle	
0:	b	first

shuffle:
	mov	$a0,$t0
	lw	$t6,col($gp)
	lw	$t7,row($gp)
	add	$t2,$0,$a0		# t2 = n col
	add	$t4,$a1,-1		# t4 = -1 row b/c title
	mul	$t3,$t4,$t6		# t3 = 
	add	$t2,$t3,$t2		# t2 = col + rows
	mul	$t2,$t2,2
	la	$a2,screen		# a3 = array
	add	$t9,$a2,$t2		# t9 = bottom left corner
 	jal	random
 	la 	$a0,screen		# a0 = address of array
	mul	$t6,$t6,2
	sub	$t7,$a0,$t6
	addi	$a0,$a0,2		# add 1 to skip over 1st element
	lw	$a1,grid($gp)		# a1 = grid 
	mul	$a2,$a2,2
	add	$a2,$a2,$a1		# a2 = end of array
	sub	$t8,$a2,$t6
	
	addi	$a1,$a1,-2		# subtract one from last address to skip
	mul	$t1,$a1,2
	add 	$a3,$a0,$t1		# a3 = address of last element -1

1:	jal	random
	remu	$t2,$v0,$a1		# random % n elements left
	mul	$t2,$t2,2
	add	$t3,$a0,$t2		# t3 addres to swap with
	beq	$t3,$t9,2f
	beq	$t3,$t8,2f
	beq	$t3,$t7,2f		#check if protected (y,branch to move)
	lbu 	$t0,($a0) 		# second element (leave corner alone
	lbu	$t4,($t3)
	sb	$t0,($t3)		
	sb	$t4,($a0)
2:	addi	$a1,$a1,-1
	addi	$a0,$a0,half		# move array
	bne	$a0,$a3,1b
	
locate:	lw	$t6,col($gp)
	mul	$t6,$t6,2
	la	$a0,screen
	mov	$a3,$a0
	lw	$a2,grid($gp)		# a1 = grid 
	addi	$a2,$a2,-1
	mul	$a2,$a2,2
	add	$a2,$a2,$a0
0:	lbu	$t0,($a0)		# t0 = element
	bne	$t0,bomb,9f		# IF t0 != BOMB skip
	sub	$t3,$a0,$a3		# t3 = location - origin
	addi	$t3,$t3,2		# checl for rigth corner
	rem	$t3,$t3,$t6
	beqz	$t3,3f
	addi	$t1,$a0,2		# t1 = right
	lbu	$t2,($t1)
	beq	$t2,bomb,1f		# chek if next space is bomb
	addi	$t2,$t2,1
	sb	$t2,($t1)
1:	add	$t7,$t1,$t6		# t1 = right -> down
	blt	$t7,$a3,2f
	lbu	$t2,($t7)
	beq	$t2,bomb,2f		# chek if next space is bomb
	addi	$t2,$t2,1
	sb	$t2,($t7)
2:	sub	$t7,$t1,$t6		# t1 = right -> up
	blt	$t7,$a3,3f
	lbu	$t2,($t7)
	beq	$t2,bomb,3f		# chek if next space is bomb
	addi	$t2,$t2,1
	sb	$t2,($t7)
3:	sub	$t3,$a0,$a3		# t3 = location - origin
	rem	$t3,$t3,$t6
	beqz	$t3,6f			# check if left corner
	addi	$t1,$a0,-2		# t1 = left
	lbu	$t2,($t1)
	beq	$t2,bomb,4f		# chek if space is bomb
	addi	$t2,$t2,1
	sb	$t2,($t1)
4:	add	$t7,$t1,$t6		# t1 = left -> down
	blt	$t7,$a3,5f
	lbu	$t2,($t7)
	beq	$t2,bomb,5f		# chek if next space is bomb
	addi	$t2,$t2,1
	sb	$t2,($t7)
5:	sub	$t7,$t1,$t6		# t1 = left -> up
	blt	$t7,$a3,6f
	lbu	$t2,($t7)
	beq	$t2,bomb,6f		# chek if next space is bomb
	addi	$t2,$t2,1
	sb	$t2,($t7)
6:	sub	$t1,$a0,$t6		# t1 = up
	blt	$t1,$a3,7f
	lbu	$t2,($t1)
	beq	$t2,bomb,7f		# chek if next space is bomb
	addi	$t2,$t2,1
	sb	$t2,($t1)
7:	add	$t1,$a0,$t6		# t1 = down
	blt	$t1,$a3,9f
	lbu	$t2,($t1)
	beq	$t2,bomb,9f		# chek if next space is bomb
	addi	$t2,$t2,1
	sb	$t2,($t1)
9:	addi	$a0,$a0,half
	bne	$a0,$a2,0b
save:	la 	$a1,screen		# a1 = address of array
	lw	$a2,grid($gp)		# a1 = grid 
	mul	$a2,$a2,2
	add	$a2,$a2,$a1
11:	lbu	$a0,($a1)
	beq	$a0,space,12f
	beq	$a0,bomb,12f
	addi	$a0,$a0,16
	sb	$a0,($a1)		
12:	addi	$a0,$0,hide
	sb	$a0,byte($a1)	
	addi	$a1,$a1,half		# move array 
 	bne 	$a1,$a2,11b		# go through whole array
#-------------------------------------------------------------------------------
	la	$a0,timer.t4		# hardware address of timer4
	addi	$a1,$0,4		# 4 byte data
	addi	$a2,$0,1000		# timer interval every 1000 milliseconds
	syscall $IO_write		#TimerCheck
#-------------------------------------------------------------------------------
click:	jal	poll
	lw	$t6,col($gp)
	lw	$t7,row($gp)
	add	$t2,$0,$a0		# t2= n col
	add	$t4,$a1,-1		# t4 = -1 row b/c title
	mul	$t3,$t4,$t6		# t3 = 
	add	$t2,$t3,$t2		# t2 = col + rows
	mul	$t2,$t2,2
	mul	$t6,$t6,2
	la	$a2,screen		# array
	add	$a3,$a2,$t2		# array = xy
9:	bne	$t1,1,1f
	jal	l_click
1:	bne	$t1,2,2f
	jal	r_click
2:	bne	$t1,4,5f
	jal	m_click
5:	mov	$a0,$t8
	mov	$a1,$t9		
0:	mov	$a0,$t8
	mov	$a1,$t9
	jal	check
	sw	$0,mouseDownXY($gp)
	sb	$0,mouseDownButtons($gp)
	jal	Print
	b	click
#-------------------------------------------------------------------------------
check:	la 	$a1,screen		# a1 = address of array
	lw	$a2,grid($gp)		# a1 = grid 
	mul	$a3,$a2,2
	add	$a3,$a3,$a1		# a3 last element
	lw	$t3,flag($gp)
	mov	$t1,$0
0:	lbu	$t0,byte($a1)
	beq	$t0,mark,2f
	bne	$t0,hide,1f
	add	$t1,$t1,1
1:	addi	$a1,$a1,half		# move array 
 	bne 	$a1,$a3,0b	
	bgt	$t1,$t3,2f	
	b	won
2:	lw	$t1,mines($gp)
	bnez	$t1,5f
	mov	$t4,$0			# counter
	la 	$a1,screen		# a1 = address of array
0:	lbu	$t2,byte($a1)
	bne	$t2,mark,4f
	lbu	$t2,($a1)
	bne	$t2,bomb,4f
	add	$t1,$t1,1
4:	addi	$a1,$a1,half		# move array 
 	bne 	$a1,$a3,0b	
	bne	$t1,$t3,5f	
	b	won
5:	jr	$ra
#-------------------------------------------------------------------------------	
r_click:	
	lbu	$t0,byte($a3)
	bne	$t0,hide,1f	
	addi	$t2,$0,mark
	sb	$t2,byte($a3)
	lw	$t0,mines($gp)
	addi	$t0,$t0,-1
	sw	$t0,mines($gp)
1:	bne	$t0,mark,0f
	addi	$t0,$0,hide
	sb	$t0,byte($a3)
	lw	$t0,mines($gp)
	addi	$t0,$t0,1
	sw	$t0,mines($gp)

0:	jr	$ra
#-------------------------------------------------------------------------------
won:	la 	$a1,recl 	# address of buffer to read to
  	addi 	$a2,$0,record   # read 1 record
  	mov 	$a0,$s7    	# load file handle		
  	syscall $read	   	# read from file
	lw	$t0,record.wins($a1)
	addi	$t0,$t0,1
	sw	$t0,record.wins($a1)
	syscall	$write
	la	$a0,win
	b	done

lost:	
# 	s.d	$0,s_time($gp)
	la 	$a1,recl 	# address of buffer to read to
  	addi 	$a2,$0,record   # read 1 record
  	mov 	$a0,$s7    	# load file handle		
  	syscall $read	   	# read from file
	lw	$t0,record.losses($a1)
	addi	$t0,$t0,1
	sw	$t0,record.losses($a1)
	syscall	$write
	la	$a0,loss
	
done:
	syscall	$print_string
	la	$a0,score
	syscall	$print_string	
	addi	$a0,$0,22
	addi	$a1,$0,3
	syscall	$xy
	lw	$a0,option($gp)		# difficulty level 	3
	syscall	$print_string
	
	addi	$a0,$0,22
	addi	$a1,$0,5
	syscall	$xy
	l.d	$a0,s_time($gp)
	syscall	$print_double		# your time 		5
	

	la 	$a1,recl 	# address of buffer to read to
  	addi 	$a2,$0,record   # read 1 record
  	mov 	$a0,$s7    	# load file handle		
  	syscall $read	   	# read from file
	l.d	$t5,s_time($gp)
	l.d	$t4,record.best($a1)
	c.lt.d	$t5,$t4
	bc1f	2f
	s.d	$t5,record.best($t1)
	la 	$a1,recl 	# address of buffer to read to
  	addi 	$a2,$0,record   # read 1 record
  	mov 	$a0,$s7    	# load file handle		
	syscall	$write		
  	syscall $read	   	# read from file
	l.d	$t4,record.best($a1)
2:	addi	$a0,$0,22
	addi	$a1,$0,4
	syscall	$xy
	mov.d	$a0,$t4
	syscall	$print_double		# best time 		4



	la 	$a1,recl 	# address of buffer to read to
  	addi 	$a2,$0,record   # read 1 record
  	mov 	$a0,$s7    	# load file handle		
  	syscall $read	   	# read from file
	mov	$t1,$a1
	addi	$a0,$0,22
	addi	$a1,$0,6
	syscall	$xy
	lw	$a0,record.wins($t1)	# Wins			6
	syscall	$print_int

	addi	$a0,$0,22
	addi	$a1,$0,7
	syscall	$xy
	lw	$a0,record.losses($t1)	# Losses		7
	syscall	$print_int
	
	syscall	$read_char
	la 	$a1,screen		# a1 = address of array
	lw	$a2,grid($gp)		# a1 = grid 
	mul	$a2,$a2,2
	add	$a2,$a2,$a1
	mov	$t9,$a2
11:	lbu	$a0,($a1)
	beq	$a0,hide,12f
	sb	$a0,byte($a1)
12:	addi	$a1,$a1,half		# move array 
 	bne 	$a1,$a2,11b		
	jal	Print
	addi	$a0,$0,60
	mov	$a1,$0
	syscall	$xy
	la	$a0,continue
	syscall	$print_string
	la	$a0,buffer
	addi	$a1,$0,14
	syscall $read_char
	beq	$v0,'y,switch	
	mov 	$a0,$s7    	# Restore fd
 	syscall $close		# close file
	syscall	$exit	

#-------------------------------------------------------------------------------
l_click:
	lbu	$t0,($a3)		# t0 = actual char
	bne	$t0,bomb,1f		# check if bomb
	b	lost			#DONE
1:	lbu	$t1,byte($a3)		# check if space is marked
	bne	$t1,mark,2f		# if t1 !=mark branch 2f
	sb	$t0,byte($a3)		# swap actual to print
	lw	$t2,mines($gp)
	addi	$t2,$t2,1		# decrease mine
	sw	$t2,mines($gp)
2:	beq	$t0,hide,13f
	bne	$t0,space,10f
	sb	$t0,byte($a3)		# swap actual to print
#-------------------------------------------------------------------------------	
clears:	addi	$t7,$0,half
	addi	$t8,$0,hide
	sb	$t8,($a3)
	mov	$v1,$sp
	addiu	$sp,$sp,-word*500
	move	$t2,$sp
	move	$t5,$t2
	la	$v0,screen
	b	20f		# v1 copy of address
0:	
	lbu	$t0,($a3)
	bne	$t0,hide,8f
20:	
	sub	$t4,$a3,$a2		# t4 = location - origin
	addi	$t4,$t4,2		# check for rigth corner
	rem	$t4,$t4,$t6
	beqz	$t4,3f	
	
	add	$a1,$a3,$t7		# move to right a1 = a3 + 1 half
	lbu	$t0,($a1)		# load in actual t0
	bne	$t0,bomb,11f		# check if bomb
	lbu	$t3,byte($a1)
	bne	$t3,mark,lost
	b	1f
11:	beq	$t0,hide,1f		# if hide then already clicked so skip
	sb	$t0,byte($a1)		# output fake
	bne	$t0,space,1f
	sub	$t0,$a1,$v0		# get difference in position
	bltz	$t0,1f
	sh	$t0,($t2)
	addi	$t2,$t2,half	
	sb	$t8,($a1)
1:
	add	$t1,$a1,$t6		# move to down t1 = a3 + 1 half
	lbu	$t0,($t1)		# load in actual t1
	bne	$t0,bomb,22f		# check if bomb
	lbu	$t3,byte($t1)
	bne	$t3,mark,lost
	b	2f	
22:	beq	$t0,hide,2f
	sb	$t0,byte($t1)		# output fake
	bne	$t0,space,2f
	sub	$t0,$t1,$v0		# get difference in position
	bltz	$t0,2f
	sh	$t0,($t2)
	addi	$t2,$t2,half
	sb	$t8,($t1)
2:
	sub	$t1,$a1,$t6		# move to up t1 = a3 + columns
	blt	$t1,$v0,3f
	lbu	$t0,($t1)		# load in actual t1
	bne	$t0,bomb,33f		# check if bomb
	lbu	$t3,byte($t1)
	bne	$t3,mark,lost
	b	3f
33:	beq	$t0,hide,3f
	sb	$t0,byte($t1)		# output fake	
	bne	$t0,space,3f
	sub	$t0,$t1,$v0		# get difference in position
	bltz	$t0,3f
	sh	$t0,($t2)
	addi	$t2,$t2,half
	sb	$t8,($t1)

3:	sub	$t4,$a3,$a2		# t4 = location - origin
	rem	$t4,$t4,$t6
	beqz	$t4,6f

	sub	$a1,$a3,$t7		# move to left t1 = a3 + 1 half
	lbu	$t0,($a1)		# load in actual t1
	bne	$t0,bomb,44f		# check if bomb
	lbu	$t3,byte($a1)
	bne	$t3,mark,lost
	b	4f
44:	beq	$t0,hide,4f
	sb	$t0,byte($a1)		# output fake
	bne	$t0,space,4f
	sub	$t0,$a1,$v0		# get difference in position
	bltz	$t0,4f
	sh	$t0,($t2)
	addi	$t2,$t2,half
	sb	$t8,($a1)
4:	add	$t1,$a1,$t6		# move to down t1 = a3 + 1 half
	lbu	$t0,($t1)		# load in actual t
	bne	$t0,bomb,55f		# check if bomb
	lbu	$t3,byte($t1)
	bne	$t3,mark,lost
	b	5f
55:	beq	$t0,hide,5f
	sb	$t0,byte($t1)		# output fake
	bne	$t0,space,5f
	sub	$t0,$t1,$v0		# get difference in position
	bltz	$t0,5f
	sh	$t0,($t2)
	addi	$t2,$t2,half
	sb	$t8,($t1)
5:	sub	$t1,$a1,$t6		# move to up t1 = a3 + 1 half
	lbu	$t0,($t1)		# load in actual t1
	bne	$t0,bomb,66f		# check if bomb
	lbu	$t3,byte($t1)
	bne	$t3,mark,lost
	b	6f
66:	beq	$t0,hide,6f
	sb	$t0,byte($t1)		# output fake
	bne	$t0,space,6f
	sub	$t0,$t1,$v0		# get difference in position
	bltz	$t0,6f
	sh	$t0,($t2)
	addi	$t2,$t2,half
	sb	$t8,($t1)
6:	add	$t1,$a3,$t6		# move  down t1 = a3 + row
	lbu	$t0,($t1)
	bne	$t0,bomb,77f		# check if bomb
	lbu	$t3,byte($t1)
	bne	$t3,mark,lost
	b	7f
77:	beq	$t0,hide,7f		# load in actual t1
	sb	$t0,byte($t1)		# output faker
	bne	$t0,space,7f
	subu	$t0,$t1,$v0		# get difference in position
	bltz	$t0,7f
	sh	$t0,($t2)
	addi	$t2,$t2,half
	sb	$t8,($t1)
7:	sub	$t1,$a3,$t6		# move to up t1 = a3 + 1 half
	lbu	$t0,($t1)
	bne	$t0,bomb,88f		# check if bomb
	lbu	$t3,byte($t1)
	bne	$t3,mark,lost
	b	8f
88:	beq	$t0,hide,8f
	sb	$t0,byte($t1)		# output fake
	bne	$t0,space,8f
	subu	$t0,$t1,$v0		# get difference in position
	bltz	$t0,8f
	sh	$t0,($t2)
	addi	$t2,$t2,half
	sb	$t8,($t1)
8:	lh	$t3,($t5)
	bnez	$t3,11f
	addi	$t5,$t5,half
	bne	$t5,$v1,8b
	b	12f
11:	beq	$t5,$v1,12f
	add	$a3,$v0,$t3
	addi	$t5,$t5,half
	b	0b
12:	sh	$0,($sp)
	addi	$sp,$sp,half
	bne	$sp,$v1,12b
	b	13f
10:	sb	$t0,byte($a3)		# swap actual to prin
13:	jr	$ra
#-------------------------------------------------------------------------------
m_click:		# check number clivked the compare to numberrt of bombs
	mov	$t8,$a3
	lbu	$t0,($a3)		# t0 = actual char
	lbu	$t5,byte($a3)
	beq	$t5,hide,9f
	beq	$t5,mark,9f	

	addi	$t2,$t5,-48			# counter bomb = $t5
	mov	$t3,$0			# counter
	sub	$t4,$a3,$a2		# t4 = location - origin
	addi	$t4,$t4,2		# check for rigth corner
	rem	$t4,$t4,$t6
	beqz	$t4,3f
	addi	$a1,$a3,half		# move to right t1 = a3 + 1 half
	lbu	$t0,byte($a1)		# load in fake
	bne	$t0,mark,1f		# end if not marked
	addi	$t3,$t3,1		# add to marked bomb counter
1:	add	$t1,$a1,$t6		# move to down t1 = a3 + 1 half
	lbu	$t0,byte($t1)		# load in fake
	bne	$t0,mark,2f		# end if not marked
	addi	$t3,$t3,1		# add to marked bomb counter
2:	sub	$t1,$a1,$t6		# move to up t1 = a3 + 1 half
	lbu	$t0,byte($t1)		# load in fake
	bne	$t0,mark,3f		# end if not marked
	addi	$t3,$t3,1		# add to marked bomb counter

3:	sub	$t4,$a3,$a2		# t4 = location - origin
	rem	$t4,$t4,$t6
	beqz	$t4,6f
	addi	$a1,$a3,-half		# move to right t1 = a3 + 1 half
	lbu	$t0,byte($a1)		# load in fake
	bne	$t0,mark,4f		# end if not marked
	addi	$t3,$t3,1		# add to marked bomb counter
4:	add	$t1,$a1,$t6		# move to down t1 = a3 + 1 half
	lbu	$t0,byte($t1)		# load in fake
	bne	$t0,mark,5f		# end if not marked
	addi	$t3,$t3,1		# add to marked bomb counter
5:	sub	$t1,$a1,$t6		# move to up t1 = a3 + 1 half
	lbu	$t0,byte($t1)		# load in fake
	bne	$t0,mark,6f		# end if not marked
	addi	$t3,$t3,1
6:	add	$t1,$a3,$t6		# move  down t1 = a3 + row
	lbu	$t0,byte($t1)		# load in fake
	bne	$t0,mark,7f		# end if not marked
	addi	$t3,$t3,1		# add to marked bomb counter
7:	sub	$t1,$a3,$t6		# move to up t1 = a3 + 1 half
	lbu	$t0,byte($t1)		# load in fake
	bne	$t0,mark,8f		# end if not marked
	addi	$t3,$t3,1
8:	bne	$t2,$t3,9f
	b	clears
9:	jr	$ra
#-------------------------------------------------------------------------------
poll:	
97:	beqz	$s5,5f
	la	$a0,timer.flags		# 
	addi	$a1,$0,1
	syscall $IO_read
	blez	$v0,5f			# if(!timer)goto 5;
	move	$t0,$v0
	addi	$t7,$0,1		# timer index
	addi	$t8,$0,2		# timer mask
	la	$t9,timer.t1		# timer hardware address pointer
2:					#do{
	and	$t1,$t0,$t8		# check flag
	beqz	$t1,4f			# if(flag[index]) {
	move	$a0,$t9			# 
	syscall	$IO_read		# clear flag
	addi	$a0,$0,42
	mov	$a1,$0
	syscall	$xy
	la	$t6,times
	sll	$a0,$t7,4
	add	$a0,$a0,$t6
	l.d	$f12,($a0)		# pick up elapsed time
	l.d	$f10,8($a0)		# get associated interval
	add.d	$f12,$f12,$f10
	s.d	$f12,($a0)
	s.d	$a0,s_time($gp)
	syscall	$print_double		# }
4:	addi	$t7,$t7,1		# index++;
	sll	$t8,$t8,1		# mask<<1;
	addi	$t9,$t9,4		# pointer++;
	blt	$t7,5,2b		# }while index<8;<5
5:	la	$a0,mouse.flags			#address of flags
	addi	$a1,$0,word
	syscall	$IO_read
	andi	$t0,$v0,mouseflag.down
	beqz	$t0,3f
	addi	$a0,$a0,mouse.down-mouse.flags	#restore a0 to mouse.flags
	syscall	$IO_read
	sw	$v0,mouseDownXY($gp)		#button click down
	addi	$a0,$a0,word
	syscall	$IO_read
	sb	$v0,mouseDownButtons($gp)
	b	poll
3:	addi	$t0,$v0,mouseflag.up
	beqz	$t0,97b
	addi	$a0,$a0,mouse.up-mouse.flags
	syscall	$IO_read
	lw	$t0,mouseDownXY($gp)
	bne	$t0,$v0,97b
	addi	$a0,$a0,word
	syscall	$IO_read		#check all buttons up (depressed)
	andi	$v0,$v0,mouseButtons.left|mouseButtons.right|mouseButtons.middle
	bnez	$v0,97b
	lw	$v0,mouseDownXY($gp)
	lb	$v1,mouseDownButtons($gp)
0:	srl	$t1,$v1,3		# mouse click type
	srl	$a1,$v0,16		# a1 = row
	andi	$a0,$v0,0x7f		# a0 = col
	lw	$t2,col($gp)		# t2 = columns
	addi	$t2,$t2,-1		# reduce column bc of range 
	lw	$t3,row($gp)		# t3 = rows
	beqz	$a1,poll			# range check
	bgt	$a1,$t3,poll		# 
	bgt	$a0,$t2,poll
	jr	$ra
	.extern mouseDownXY,word
	.extern mouseDownButtons,word
	.extern	s_time,double
#-------------------------------------------------------------------------------
mouse: 		.struct 0xa0000018 	# start from mouse base address
flags: 		.byte 0 	# 1 = move; 2 = down; 4 = up;...
mask: 		.byte 0 	# 8 = wheel; mask same as flags
	 	.half 0
		.word 0
move: 		.word 0,0 	# mouse move data
down: 		.word 0,0 	# mouse button down data
up: 		.word 0,0 	# mouse button up data
wheel: 		.word 0,0 	# mouse wheel data
wheeldown: 	.word 0,0 	# mouse wheel down data
wheelup: 	.word 0,0 	# mouse wheel up data }
		.data 
mouseflag:	.struct
move		= 1
down		= 2
up		= 4
wheel		= 8
wheeldown	= 16
wheelup		= 32
		.data
mouseButtons:	.struct
keyShift	= 1
keyAlt		= 2
keyCtrl		= 4 
left 		= 8
right 		= 16
middle 		= 32
doubleclick 	= 64
		.data
timer:		.struct 0xa0000050 	#start from timer base address
flags:		.byte 0
mask:		.byte 0
		.half 0
t1:		.word 0
t2:		.word 0
t3:		.word 0
t4:		.word 0
		.data
	.data
record:		.struct
cols:		.byte	0	#change to word becasue .extern on mine is diiff
rows:		.byte	0
wins:		.word	0
losses:		.word	0
best:		.double	
	.data
	.align	2
recl:	.space	record	#static allocated place to read data from file where 1 record strcut is saved
	.code
