################ CSC258H1F Fall 2022 Assembly Final Project ##################
# This file contains our implementation of Breakout.
#
# Student 1: Hanif Rizky Noegroho, 1007680742
# Student 2: Poorvi Sharma, 1006145146
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       8
# - Unit height in pixels:      8
# - Display width in pixels:    256
# - Display height in pixels:   256
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################

    .data
    displayAddress: .word 0x10008000
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000

##############################################################################
# Mutable Data
##############################################################################

##############################################################################
# Code
##############################################################################
	.text
	lw $t0, displayAddress 	# $t0 stores the base address for display
	li $t2, 0xbea9df 	# $t2 stores the pastel purple
	li $t9, 0xff0000 	# $t2 stores the color red
	li $s1, 0xffc300 	# $s1 stores the color yellow
	li $s2, 0x50C878 	# $t2 stores the color green
	.globl main

	# Run the Brick Breaker game.
main:

add $t7, $zero, $t0
add $t5, $zero, $zero
add $s4, $zero, $zero
add $s3, $zero, $zero
add $s6, $zero, $zero
addi $t6, $zero, 4
addi $s7, $zero, 3

# Building the bricks
build_bricks_red:
beq $t5, $t6, build_bricks_blue
sw $t9, 408($t7)
addi $t7, $t7, 4
sw $t9, 408($t7)
addi $t7, $t7, 4
sw $t9, 408($t7)
addi $t7, $t7, 4
sw $t9, 408($t7)
addi $t7, $t7, 8
sw $t9, 408($t7)

addi $t5, $t5, 1
j build_bricks_red

build_bricks_blue:
addi $t7, $t7, 52
build_bricks_blue_loop:
beq $s4, $t6, build_bricks_green
sw $s1, 408($t7)
addi $t7, $t7, 4
sw $s1, 408($t7)
addi $t7, $t7, 4
sw $s1, 408($t7)
addi $t7, $t7, 4
sw $s1, 408($t7)
addi $t7, $t7, 8

addi $s4, $s4, 1
j build_bricks_blue_loop

build_bricks_green:
addi $t7, $t7, 44
build_bricks_green_loop:
beq $s6, $t6, Exit
sw $s2, 408($t7)
addi $t7, $t7, 4
sw $s2, 408($t7)
addi $t7, $t7, 4
sw $s2, 408($t7)
addi $t7, $t7, 4
sw $s2, 408($t7)
addi $t7, $t7, 8

addi $s6, $s6, 1
j build_bricks_green_loop


Exit:
# Initialize the game
#initialization of function parameters
add $a0, $zero, $t0 # $a0 : Starting location for drawing the rectangle
addi $a0, $a0, 276 # determine starting pixel
addi $a1, $zero, 21 # $a1 : The width of the rectangle
addi $a2, $zero, 27 # $a2 : The height of the rectangle
add $a3, $zero, $t2 # &a3 : The color of the rectangle
jal draw_rect

draw_rect:
add $t0, $zero, $a0		# drawing location to $t0
add $t1, $zero, $a2		# height to $t1
add $t2, $zero, $a1		# width to $t2
add $t3, $zero, $a3		# color into $t3

# draw the top line
hor_line_draw:
beq $t2, $zero, end_hor_line	# if width == 0, jump to the end of the horizontal line checkpoint
sw $t3, 0($t0)			# draw a pixel at the current location.
addi $t0, $t0, 4		# move the current drawing location to the right.
addi $t2, $t2, -1		# decrement width
j hor_line_draw			# repeat the loop

end_hor_line:
addi $t1, $t1, -1		# decrement the height variable
add $t2, $zero, $a1		# reset the width variable to $a1
# reset the current drawing location to the first pixel of the next line.
addi $t0, $t0, 128		# move $t0 to the next line
sll $t4, $t2, 2			# convert $t2 into bytes
sub $t0, $t0, $t4		# move $t0 to the first pixel to draw in this line.

ver_line_draw:
beq $t1, $zero, prep_ver_two	# if the height is zero, jump to preparation of next vertical line
sw $t3, 0($t0)			# draw a pixel at the current location.
addi $t0, $t0, 128		# move the current drawing location down.
addi $t1, $t1, -1		# decrement the height variable
j ver_line_draw			# repeat the loop

prep_ver_two:
add $t2, $zero, $a1

reincriment:
beq $t2, $zero, reset_height	# if the width variable is zero, jump to height reset
addi $t0, $t0, 4		# move the current drawing location to the right.
addi $t2, $t2, -1		# decrement the width variable
j reincriment	 

reset_height:
beq $t1, $a2, ver_line_draw2	# if the height variable is at the top, jump to drawing the second vertical line
addi $t0, $t0, -128		# move the current drawing location up.
addi $t1, $t1, 1		# increment the height variable
j reset_height

ver_line_draw2:
beq $t1, $zero, paddle_set_up	# if the height variable is zero, end
sw $t3, 0($t0)			# draw a pixel at the current location.
addi $t0, $t0, 128		# move the current drawing location down.
addi $t1, $t1, -1		# decrement the height variable
j ver_line_draw2	# repeat the inner loop


paddle_set_up:
addi $t2, $zero, 4
addi $t0, $t0, -128
addi $t0, $t0, -48

paddle_draw:
beq $t2, $zero, end_outer_loop	# if width == 0, jump to the end of the horizontal line checkpoint
sw $t3, 0($t0)			# draw a pixel at the current location.
addi $t0, $t0, 4		# move the current drawing location to the right.
addi $t2, $t2, -1		# decrement width
add $t7, $t0, $zero
j paddle_draw			# repeat the loop


end_outer_loop:			# the end of the rectangle drawing
addi $t7, $t0, -136
li $t3, 0xffffff 	# $t2 stores the pastel purple
sw $t3, 0($t7)			# draw a pixel at the current location.
add $t6, $zero, $t7
li $t3, 0xbea9df 	# $t2 stores the pastel purple
addi $t7, $t7, 136
add $t5, $zero, $zero
add $t4, $zero, $zero
add $t1, $zero, $zero
add $t9, $zero, $zero
j get_ready
jr $ra			# return to the calling program
		# return to the calling program

get_ready:
    li         $v0, 32
    li         $a0, 1
    syscall
	
    lw $t0, ADDR_KBRD               # $t5 = base address for keyboard
    lw $t8, 0($t0)                  # Load first word from keyboard
    beq $t8, 1, keyboard_start      # If first word 1, key is pressed
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (paddle, ball)
	# 3. Draw the screen
	# 4. Sleep
	
    #5. Go back to 1

    
    b get_ready

keyboard_start:                     # A key is pressed
    lw $a0, 4($t0)                  # Load second word from keyboard
    li $t2, 0xbea9df 	# $t2 stores the pastel purple

    beq $a0, 0x20, game_loop     # Check if the key q was pressed
   
    li $v0, 1                       # ask system to print $a0
    syscall

    b get_ready

game_loop:
	# 1a. Check if key has been pressed
    li         $v0, 32
    li         $a0, 1
    syscall

    
	
    lw $t0, ADDR_KBRD               # $t5 = base address for keyboard
    lw $t8, 0($t0)                  # Load first word from keyboard
    beq $t8, 1, keyboard_input      # If first word 1, key is pressed
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (paddle, ball)
	# 3. Draw the screen
	# 4. Sleep
	
    #5. Go back to 1
    b move_ball
    
    b game_loop

move_ball:
    li $t3, 0xffffff 	# $t2 stores the pastel purple
    sw $t3, 0($t6)
    beq, $t1, $zero, move_ball_right_up
    beq, $t1, 1, move_ball_left_up
    beq, $t1, 2, move_ball_left_down
    beq, $t1, 3, move_ball_right_down

change_right_up:
li $v0, 31                       # ask system to print $a0
    li $a0, 124
    li $a1, 234
    li $a2, 1
    li $a3, 88
    syscall
    add $t1, $zero, $zero

move_ball_right_up:
    beq, $t4, 9, change_left_up
    beq, $t9, 24, change_right_down
    li         $v0, 32
    li         $a0, 125
    syscall
    li $t3, 0x000000 	# $t2 stores the pastel purple
    sw $t3, 0($t6)
    li $t3, 0xffffff 	# $t2 stores the pastel purple	
    addi $t6, $t6, -124
    sw $t3, 0($t6)
    
    addi $t4, $t4, 1
    addi $t9, $t9, 1
    
    beq, $t4, 9, change_left_up
    beq, $t9, 24, change_right_down
    addi $t6, $t6, -124
    
    # Load the address of the pixel into $a0
    la $a0, 0($t6)
    # Load the color of the pixel into $t0
    lb $t0, 0($a0)
    li $t3, 0x00000000   # Black color value
    

    bne $t0, $t3, not_blackr   # If $t0 != black, jump to not_black
    addi $t6, $t6, 124
    li $t3, 0xffffff 	# $t2 stores the pastel purple
    sw $t3, 0($t6)
    
    b game_loop

change_left_up:
li $v0, 31                       # ask system to print $a0
    li $a0, 124
    li $a1, 234
    li $a2, 1
    li $a3, 88
    syscall
    addi $t1, $zero, 1

move_ball_left_up:
    beq, $t9, 24, change_left_down
    beq, $t4, -10, change_right_up
    li         $v0, 32
    li         $a0, 125
    syscall
    li $t3, 0x000000 	# $t2 stores the pastel purple
    sw $t3, 0($t6)
    li $t3, 0xffffff 	# $t2 stores the pastel purple	
    addi $t6, $t6, -132
    addi $t4, $t4, -1
    addi $t9, $t9, 1
    beq, $t4, -10, change_right_up
    addi $t6, $t6, -132
    
    # Load the address of the pixel into $a0
    la $a0, 0($t6)
    # Load the color of the pixel into $t0
    lb $t0, 0($a0)
    li $t3, 0x00000000   # Black color value
    
    add $t8, $zero, $t6

    bne $t0, $t3, not_black   # If $t0 != black, jump to not_black
    addi $t6, $t6, 132
    li $t3, 0xffffff 	# $t2 stores the pastel purple
    sw $t3, 0($t6)
    
    b game_loop

change_left_down:
li $v0, 31                       # ask system to print $a0
    li $a0, 124
    li $a1, 234
    li $a2, 1
    li $a3, 88
    syscall
    addi $t1, $zero, 2
   
move_ball_left_down:
    beq, $t9, -2, lose_sit
    beq, $t4, -10, change_right_down
    li         $v0, 32
    li         $a0, 125
    syscall
    li $t3, 0x000000 	# $t2 stores the pastel purple
    sw $t3, 0($t6)
    li $t3, 0xffffff 	# $t2 stores the pastel purple	
    addi $t6, $t6, 124
    sw $t3, 0($t6)
    addi $t4, $t4, -1
    addi $t9, $t9, -1
    beq, $t4, -10, change_right_down
    
    addi $t6, $t6, 124
    
    # Load the address of the pixel into $a0
    la $a0, ($t6)
    # Load the color of the pixel into $t0
    lb $t0, 0($a0)
    li $t3, 0x00000000   # Black color value
    
    bne $t0, $t3, not_black_bounce_upl   # If $t0 != black, jump to not_black
    addi $t6, $t6, -124
    li $t3, 0xffffff 	# $t2 stores the pastel purple
    sw $t3, 0($t6)
    
    b game_loop    
 
change_right_down:
li $v0, 31                       # ask system to print $a0
    li $a0, 124
    li $a1, 234
    li $a2, 1
    li $a3, 88
    syscall
    addi $t1, $zero, 3
    
move_ball_right_down:
    beq, $t9, -2, lose_sit
    beq, $t4, 9, change_left_down
    li         $v0, 32
    li         $a0, 125
    syscall
    li $t3, 0x000000 	# $t2 stores the pastel purple
    sw $t3, 0($t6)
    li $t3, 0xffffff 	# $t2 stores the pastel purple	
    addi $t6, $t6, 132
    addi $t4, $t4, 1
    addi $t9, $t9, -1
    beq, $t4, 9, change_left_down
    
    addi $t6, $t6, 132
    
    # Load the address of the pixel into $a0
    la $a0, 0($t6)
    # Load the color of the pixel into $t0
    lb $t0, 0($a0)
    li $t3, 0x00000000   # Black color value
    
    bne $t0, $t3, not_black_bounce_up   # If $t0 != black, jump to not_black
    addi $t6, $t6, -132
    li $t3, 0xffffff 	# $t2 stores the pastel purple
    sw $t3, 0($t6)
    
    b game_loop

move_to_first_pixel:
# Load the address of the pixel into $a0
la $a0, ($t6)
# Load the color of the pixel into $t0
lb $t0, 0($a0)
li $t2, 0xbea9df   # pastel purple color value  
beq $t0, $t2, delete_brick
li $t2, 0x0000   # Black color value
addi $t6, $t6, -4
# Load the address of the pixel into $a0
la $a0, ($t6)
# Load the color of the pixel into $t0
lb $t0, 0($a0)
li $t2, 0x0000   # Black color value
beq $t0, $t2, delete_brick
bne $t0, $t2, move_to_first_pixel

move_to_first_pixelr:
# Load the address of the pixel into $a0
la $a0, ($t6)
# Load the color of the pixel into $t0
lb $t0, 0($a0)
li $t2, 0xbea9df   # pastel purple color value  
beq $t0, $t2, delete_brickr
li $t2, 0x0000   # Black color value
addi $t6, $t6, -4
# Load the address of the pixel into $a0
la $a0, ($t6)
# Load the color of the pixel into $t0
lb $t0, 0($a0)
li $t2, 0xbea9df   # pastel purple color value  
beq $t0, $t2, delete_brickr
li $t2, 0x0000   # Black color value
beq $t0, $t2, delete_brickr
bne $t0, $t2, move_to_first_pixelr

delete_brick:
li $t2, 0xbea9df   # pastel purple color value  
beq $t0, $t2, change_left_down
li $t2, 0x0000   # Black color value
sw $t2, 0($t6)
addi $t6, $t6, 4
# Load the address of the pixel into $a0
la $a0, ($t6)
# Load the color of the pixel into $t0
lb $t0, 0($a0)
bne $t0, $t2, delete_brick
add $t6, $zero, $t8
addi $t6, $t6, 132
b change_left_down

delete_brickr:
li $t2, 0xbea9df   # pastel purple color value  
beq $t0, $t2, change_right_down
li $t2, 0x0000   # Black color value
sw $t2, 0($t6)
addi $t6, $t6, 4
# Load the address of the pixel into $a0
la $a0, ($t6)
# Load the color of the pixel into $t0
lb $t0, 0($a0)
bne $t0, $t2, delete_brickr
add $t6, $zero, $t8
addi $t6, $t6, 124
b change_right_down

not_black_bounce_up:
li $t2, 0xbea9df   # Purple color value
bne $t0, $t2, brick_bounce_up   # If $t0 != pastel, jump to brick

not_black_bounce_upl:
li $t2, 0xbea9df   # Purple color value
bne $t0, $t2, brick_bounce_upl   # If $t0 != pastel, jump to brick

not_black:
li $t2, 0xbea9df   # Purple color value
bne $t0, $t2, move_to_first_pixel   # If $t0 != pastel, jump to brick
b game_loop

not_blackr:
li $t2, 0xbea9df   # Purple color value
bne $t0, $t2, move_to_first_pixelr   # If $t0 != pastel, jump to brick
b game_loop

brickr:
# assume $a0 contains the x-coordinate of the pixel
li $a1, 128 # load the midpoint into $t1
bge $a0, $a1, fix_crd_address # jump to right_half if $t0 >= $t1
ble $a0, $a1, change_right_down # jump to right_half if $t0 >= $t1

brick:
# assume $a0 contains the x-coordinate of the pixel
li $a1, 128 # load the midpoint into $t1
bge $a0, $a1, fix_cld_address # jump to right_half if $t0 >= $t1
ble $a0, $a1, change_right_down # jump to right_half if $t0 >= $t1

fix_crd_address:
addi $t6, $t6, 124
li $t3, 0xffffff 	# $t2 stores the pastel purple
sw $t3, 0($t6)
addi $a0, $a0, 124
add $t6, $zero, $a0
b change_right_down

fix_cld_address:
addi $t6, $t6, 132
li $t3, 0xffffff 	# $t2 stores the pastel purple
sw $t3, 0($t6)
addi $a0, $a0, 132
add $t6, $zero, $a0
b change_left_down

brick_bounce_up:
# assume $a0 contains the x-coordinate of the pixel
li $a1, 128 # load the midpoint into $t1
bge $a0, $a1, fix_cru_address # jump to right_half if $t0 >= $t1
ble $a0, $a1, fix_clu_address # jump to right_half if $t0 >= $t1

brick_bounce_upl:
# assume $a0 contains the x-coordinate of the pixel
li $a1, 128 # load the midpoint into $t1
bge $a0, $a1, fix_clu_address # jump to right_half if $t0 >= $t1d
ble $a0, $a1, fix_cru_address # jump to right_half if $t0 >= $t1

fix_cru_address:
addi $t6, $t6, -132
li $t3, 0xffffff 	# $t2 stores the pastel purple
sw $t3, 0($t6)
addi $a0, $a0, -132
add $t6, $zero, $a0
b change_right_up

fix_clu_address:
addi $t6, $t6, -124
li $t3, 0xffffff 	# $t2 stores the pastel purple
sw $t3, 0($t6)
addi $a0, $a0, -124
add $t6, $zero, $a0
b change_left_up

keyboard_input:                     # A key is pressed
    lw $a0, 4($t0)                  # Load second word from keyboard
    li $t2, 0xbea9df 	# $t2 stores the pastel purple

    beq $a0, 0x71, respond_to_Q     # Check if the key q was pressed
    beq $a0, 0x61, respond_to_A     # Check if the key a was pressed
    beq $a0, 0x64, respond_to_D     # Check if the key d was pressed
    beq $a0, 0x70, respond_to_P     # Check if the key d was pressed
    
    li $v0, 1                       # ask system to print $a0
    syscall

    b game_loop

respond_to_P:
    li         $v0, 32
    li         $a0, 1
    syscall

    lw $t0, ADDR_KBRD               # $t5 = base address for keyboard
    lw $t8, 0($t0)                  # Load first word from keyboard
    beq $t8, 1, pkeyboard_input
    b respond_to_P

pkeyboard_input:
    lw $a0, 4($t0)                  # Load second word from keyboard
    beq $a0, 0x70, game_loop     # Check if the key d was pressed
    
    li $v0, 1                       # ask system to print $a0
    syscall

    b respond_to_P

respond_to_A:
    li $v0, 31                       # ask system to print $a0
    li $a0, 120
    li $a1, 234
    li $a2, 1
    li $a3, 88
    syscall
    
    beq $t5, -8, game_loop
    b move_left
    
    
move_left:
    li $t2, 0x000000 	# $t2 stores the pastel purple
    addi $t7, $t7, -4
    sw $t2, 0($t7)            # draw a pixel at the current location.
    addi $t7, $t7, -16
    li $t2, 0xbea9df 	# $t2 stores the pastel purple
    sw $t2, 0($t7)   
    addi $t7, $t7, 16  
    addi $t5, $t5, -1
    b game_loop

respond_to_D:
    li $v0, 31                       # ask system to print $a0
    li $a0, 120
    li $a1, 234
    li $a2, 1
    li $a3, 88
    syscall
    
    beq $t5, 8, game_loop
    b move_right

move_right:
    li $t2, 0xbea9df 	# $t2 stores the pastel purple
    sw $t2, 0($t7)            # draw a pixel at the current location.
    addi $t7, $t7, -16
    li $t2, 0x000000 	# $t2 stores the pastel purple
    sw $t2, 0($t7)   
    addi $t7, $t7, 20
    addi $t5, $t5, 1  
    b game_loop

lose_sit:
lw $t7, displayAddress
add $t7, $t7, 1464
li $t2, 0xff0000
add $t3, $zero, $zero
b draw_ldown

draw_ldown:
beq $t3, 7, draw_lright
sw $t2, 0($t7) 
addi $t7, $t7, 128
addi $t3, $t3, 1
j draw_ldown

draw_lright:
beq $t3, 12, respond_to_Q
sw $t2, 0($t7) 
addi $t7, $t7, 4
addi $t3, $t3, 1
j draw_lright

respond_to_Q:
 li $v0, 31                       # ask system to print $a0
    li $a0, 139
    li $a1, 234
    li $a2, 1
    li $a3, 88
    syscall 
    li $v0, 10                      # Quit gracefully
    syscall
