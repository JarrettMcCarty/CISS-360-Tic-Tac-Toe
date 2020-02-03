#######################################################################
# File   : main.s
# Author : Jarrett McCarty
# 
# Description: Create a NxN tic-tac-toe from user input.
#               This game has a somewhat competitive AI.
#
#
#
#######################################################################

#######################################################################
# text segment
#######################################################################
.text

#######################################################################
# Procedure(i.e. Function) definitions
#######################################################################

#######################################################################
# ** Game-board initialization ** #
# Algorithm:
#
# 1) Load address to Game-board into $t0
# 2) Set $t1 = 1 for iterator
# 3) Set $t2 = 400 size (in bytes) of game-board
# 4) Check if $t1 == $t2 { exit } 
# else 
# {
#     store $0 into current i($t1) of $t0 : $t0[i($t1)] = $0 aka 0($t0)
# }
# 5) Increment $t1 += 4 (4 for bytes)
# 6) Increment $t0 += 4 (4 for bytes)
# 7) jump to top of func 
#######################################################################

# START: INIT/ALLOC Game-board
INIT_GAMEBOARD:
                la $t0, GAMEBOARD  # Load the 400byte board
                li $t1, 0          # Set t1 to 0 -> for (int i = 0; ...
                #addi $sp, $sp, -4
                #sw $ra, 0($sp)
GAMEBOARD_ALLOC:
                li $t2, 400        # Size of the game board
                beq $t1, $t2, INIT_GAMEBOARD_END # Exit when board=size
                sw $0, 0($t0)      
                addi $t1, $t1, 4   
                # Add 4 to counter to break when storage is full
                addi $t0, $t0, 4
                # Update the by 4bits in memory for next place in board
                j GAMEBOARD_ALLOC

INIT_GAMEBOARD_END:
                #lw $ra, 0($sp)
                #addi $sp, $sp, 4
                jr $ra
# END: INIT/ALLOC Game-board
#######################################################################

#######################################################################
# ** Display Game-board ** #
# Algorithm:
#
# 1) Print newline
# 2) Set $t0 = 0 for iterator
# 3) Load address to allocated Game-board into $t1
# 4) If $t0 == $a2(user input n) { exit }
# else
# {
#     displayrow
# }
#
# displayrow
# 1) Set $t2 = 0 
# 2) Print +
# 3) if $t2 == $a2(input of n) { move to displaycol }
# else
# {
#      displayrowloop
# }
#
# displayrowloop
# 1) Print -+
# 2) Increment $t2 += 1
# 3) Jump back to previous if-else
#
# displaycol
# 1) Set $t3 = 0
# 2) Print newline
# 3) Print |
# 4) if $t3 == $a2(user input n) { jump to $t3 += 1 }
# else
# {
#       displaycolloop
# }
#
# displaycolloop
# 1) Load the current 4 bytes of $t1(board) into $t8
# 2) Set $t5 = 1 if $t8 == $0 else $t5 = 0
# 3) if $t5 == $0 { jump to checking for 'O' } 
# else print " " and jump to side
#
# O check
# 1) $t6 = 1
# 2) Set $t5 to 1 if $t8 == $t6 else $t5 = 0
# 3) If $t5 == $0 { Display X } else { print 'O' jump to side }
#
# display x
# 1) print 'X'
#
# side
# 1) print '|'
# 2) Both $t1 and $t3 += 4 to increment counter/board loc
# 
# Inc iter
# 1) $t0 += 1 increment main loop/print newline
#
# row_iter produces the bottom of the board
#######################################################################

# START: Display Game-board

BAD_N:
        move $a2, $t1
        j DISPLAY_GAMEBOARD

DISPLAY_GAMEBOARD:
                li $t0, 0  # for (int i = 0; ...
                li $t1, 3
                blt $a2, $t1, BAD_N
                
                la $t1, GAMEBOARD # Load the allocated gameboard space

DISPLAY_GAMEBOARD_EXIT_CHECK:
                beq $t0, $a2, DISPLAY_EXIT # i = n get out

# START: Row drawing 
DISPLAY_ROW:
                li $t2, 0  # for (int i = 0; ...

                li $v0, 4
                la $a0, ROWPLUS
                syscall

DISPLAY_ROW_EXIT_CHECK:
                beq $t2, $a2, DISPLAY_COL # i = n goto columns

DISPLAY_ROW_ITER:
                li $v0, 4
                la $a0, ROWBAR
                syscall

                addi $t2, $t2, 1
                j DISPLAY_ROW_EXIT_CHECK 
# END: Row drawing 
# START: Col drawing
DISPLAY_COL:
                li $t3, 0  # for (int i = 0; ...

                li $v0, 4
                la $a0, NEWLINE  # Newline
                syscall

                li $v0, 4
                la $a0, COLBAR   # '|'
                syscall

DISPLAY_COL_EXIT_CHECK:
                beq $t3, $a2, INC_ITER  # Jump to i++

#DISPLAY_COL_ITER:
DISPLAY_SPACE_CHECK:
                lw $t8, 0($t1)
                seq $t5, $t8, $0
                beq $t5, $0, O_CHECK

                li $v0, 4
                la $a0, SPACE
                syscall

                j SIDE

O_CHECK:
                li $t6, 2 # 2 for 'O' 1 for 'X' 0 for ' '
                seq $t5, $t8, $t6
                beq $t5, $0, DISPLAY_X

                li $v0, 4
                la $a0, O
                syscall

                j SIDE

DISPLAY_X:
                li $v0, 4
                la $a0, X  # 'X'
                syscall

                j SIDE

SIDE:
                li $v0, 4
                la $a0, COLBAR  # '|'
                syscall

                addi $t1, $t1, 4  # Add 4 to the board 
                addi $t3, $t3, 1  # Add one to the loop iter
                j DISPLAY_COL_EXIT_CHECK

INC_ITER:
                addi $t0, 1  # i++ for outer most loop

                li $v0, 4
                la $a0, NEWLINE  # Newline
                syscall

                j DISPLAY_GAMEBOARD_EXIT_CHECK

DISPLAY_EXIT:
                jr $ra  # Get out of display looping
# END: Col drawing         
# END: Display Game-board

# START: Game-board solid row
DISPLAY_FULL_ROW:
                li $t7, 0

                li $v0, 4
                la $a0, ROWPLUS
                syscall

DISPLAY_FULL_ROW_EXIT_CHECK:
                beq $t7, $a2, RET_GAME_ITER

DISPLAY_FULL_ROW_ITER:
                li $v0, 4
                la $a0, ROWBAR
                syscall

                addi $t7, $t7, 1
                j DISPLAY_FULL_ROW_EXIT_CHECK

RET_GAME_ITER:
                jr $ra
# END: Game-board solid row

# START: User input sequence
LT_ROW:
                li $v0, 4
                la $a0, LTROW
                syscall 

                j USER_INPUT

LT_COL:
                li $v0, 4
                la $a0, LTCOL
                syscall 

                j USER_INPUT

GT_ROW:
                li $v0, 4
                la $a0, GTROW
                syscall 

                j USER_INPUT

GT_COL:
                li $v0, 4
                la $a0, GTCOL
                syscall 

                j USER_INPUT

USER_INPUT:
                li $t5, 0
                addi $t5, $a2, -1

                li $v0, 4
                la $a0, NEWLINE
                syscall

                li $v0, 4
                la $a0, ENTERROW
                syscall

                li $v0, 5
                syscall
                move $a1, $v0   # $a1 is our row input
                
                # user row input cannot be < 0 or > n-1
                blt $a1, $0, LT_ROW
                bgt $a1, $t5, GT_ROW

                li $v0, 4
                la $a0, ENTERCOL
                syscall

                li $v0, 5
                syscall
                move $a3, $v0   # $a3 is our col input

                # user col input cannot be < 0 or > n-1
                blt $a3, $0, LT_COL
                bgt $a3, $t5, GT_COL
# END: User input sequence
#######################################################################

#######################################################################
# ** Check if the user input is as valid move ** #
#######################################################################
CHECK_VALID_MOVE:
                li $t4, 4
                la $t8, GAMEBOARD # t8 = address for gameboard
                move $t0, $a1 # move our row input into t0 offset
                mul $t0, $t0, $a2 # a2 = n, t0 = t0 * n (ex 2*3=6)
                move $t1, $a3 # move our col input into t1 offset
                add $t0, $t0, $t1 # t0 = t0 + t1 (ex 6+1=7)
                mul $t0, $t0, $t4 # t0 = t0 * 4 (ex 7*4=28)

                add $t8, $t8, $t0 # add offest to the board $t0($t8)

                lw $t7, 0($t8) # get the .word at the board location

                seq $t6, $t7, $0  # t6 = 1 if t7 == 0(i.e. ' ') else 0
                beq $t6, $0, INVALID # t6 == 0 then invalid

                li $t2, 1     # 'X' = 1
                sw $t2, 0($t8) # Put players move

                jr $ra
INVALID:
        li $v0, 4
        la $a0, BAD_MOVE
        syscall

        j USER_INPUT                
#######################################################################

#######################################################################
# ** Player1 winning message ** #
#######################################################################
SHOW_PLYR_WIN:
                li $v0, 4
                la $a0, PLYRWIN
                syscall
                li $v0, 10
                syscall
#######################################################################

#######################################################################
# ** CPU winning message ** #
#######################################################################
SHOW_CPU_WIN:
                li $v0, 4
                la $a0, NEWLINE
                syscall
                li $v0, 4
                la $a0, CPUWIN
                syscall
                li $v0, 10
                syscall
#######################################################################

#######################################################################
# ** Draw ** #
#######################################################################
SHOW_DRAW:
                li $v0, 4
                la $a0, DRAW
                syscall
                li $v0, 10
                syscall
#######################################################################

#######################################################################
# ** Checking player moves for wins ** #
#######################################################################
RET:
                jr $ra


# START: Check rows
X_ROW_INC:
                addi $t3, 1 # count += 1
                addi $t4, 4 # add four bytes to the board location
                addi $t6, 1 # j += 1
                j PLYR_ROW_WIN_J_EXIT_CHECK

PLYR_ROW_WIN:
                li $t0, 1 # 'X' = 1
                li $t2, 4
                li $t3, 0 # 'X' count
                la $t4, GAMEBOARD
                li $t5, 0 # i
                li $t6, 0 # j

PLYR_ROW_WIN_I_EXIT_CHECK:
                 beq $t5, $a2, RET

PLYR_ROW_WIN_J_EXIT_CHECK:
                beq $t6, $a2, X_ROW_COUNT_CHECK # if i == n check our count 
                lw $t8, 0($t4) # load current location on the board
                beq $t8, $t0, X_ROW_INC # if board location == 'X' move to next board spot
                j PLYR_ROW_WIN_I_INC

PLYR_ROW_WIN_I_INC:               
                li $t3, 0 # reset count
                addi $t5, 1 # i += 1
                li $t6, 0 # j = 0
                la $t4, GAMEBOARD # reset game board
                move $t7, $a2 # t7 = n
                mul $t7, $t7, $t5 # t7 = n * i
                mul $t7, $t7, $t2 # t7 = (n * i) * 4
                add $t4, $t4, $t7 # + t7 to board
                j PLYR_ROW_WIN_I_EXIT_CHECK

X_ROW_COUNT_CHECK:
                bne $t3, $a2, PLYR_ROW_WIN_I_INC
                jal DISPLAY_GAMEBOARD
                jal DISPLAY_FULL_ROW
                li $v0, 4
                la $a0, NEWLINE
                syscall
                j SHOW_PLYR_WIN 
# END: Check rows

# START: Check cols
X_COL_INC:
                addi $t3, 1 # count += 1
                addi $t6, 1 # j += 1
                move $t7, $a2 # t7 holds n
                mul $t7, $t7, $t2 # t7 = n * 4
                add $t4, $t4, $t7 # add t7 to the board to move below
                
                j PLYR_COL_WIN_J_EXIT_CHECK

PLYR_COL_WIN:
                li $t0, 1 # 'X' = 1
                li $t2, 4
                li $t3, 0 # 'X' count
                la $t4, GAMEBOARD
                li $t5, 0 # i
                li $t6, 0 # j

PLYR_COL_WIN_I_EXIT_CHECK:
                 beq $t5, $a2, RET

PLYR_COL_WIN_J_EXIT_CHECK:
                beq $t6, $a2, X_ROW_COUNT_CHECK
                lw $t8, 0($t4)
                beq $t8, $t0, X_COL_INC
 
                j PLYR_COL_WIN_I_INC

PLYR_COL_WIN_I_INC:
                li $t3, 0  # reset the 'X' counter
                addi $t5, 1 # i += 1
                li $t6, 0  # j = 0
                la $t4, GAMEBOARD # game board reset
                li $t7, 0 
                mul $t7, $t5, $t2 # t7 = the i * 4
                add $t4, $t4, $t7 # update the board to be at t7
                j PLYR_COL_WIN_I_EXIT_CHECK

X_COL_COUNT_CHECK:
                bne $t3, $a2, PLYR_COL_WIN_I_INC
                jal DISPLAY_GAMEBOARD
                jal DISPLAY_FULL_ROW
                li $v0, 4
                la $a0, NEWLINE
                syscall
                j SHOW_PLYR_WIN
# END: Check cols

# START: Diag checks

# START: Right Diag
X_RIGHT_DIAG_INC:
                addi $t3, 1
                j PLYR_RIGHT_DIAG_I_EXIT_CHECK

PLYR_RIGHT_DIAG_WIN:
                li $t0, 1 # 'X' = 1
                li $t2, 4
                li $t3, 0 # 'X' count
                la $t4, GAMEBOARD
                li $t5, 0 # i

PLYR_RIGHT_DIAG_I_EXIT_CHECK:
                beq $t5, $a2, X_RIGHT_DIAG_COUNT_CHECK
                move $t7, $a2
                addi $t7, -1
                mul $t7, $t7, $t2
                add $t4, $t4, $t7
                lw $t7, 0($t4)
                addi $t5, 1
                beq $t7, $t0, X_RIGHT_DIAG_INC
                j RET

X_RIGHT_DIAG_COUNT_CHECK:
                bne $t3, $a2, RET
                jal DISPLAY_GAMEBOARD
                jal DISPLAY_FULL_ROW
                li $v0, 4
                la $a0, NEWLINE
                syscall
                j SHOW_PLYR_WIN
# END: Right Diag

# START: Left Diag
X_LEFT_DIAG_INC:
                addi $t3, 1
                addi $t5, 1
                move $t7, $a2
                addi $t7, 1
                mul $t7, $t7, $t2
                add $t4, $t4, $t7
                j PLYR_LEFT_DIAG_I_EXIT_CHECK

PLYR_LEFT_DIAG_WIN:
                li $t0, 1 # 'X' = 1
                li $t2, 4
                li $t3, 0 # 'X' count
                la $t4, GAMEBOARD
                li $t5, 0 # i

PLYR_LEFT_DIAG_I_EXIT_CHECK:
                beq $t5, $a2, X_LEFT_DIAG_COUNT_CHECK
                lw $t7, 0($t4)
                beq $t7, $t0, X_LEFT_DIAG_INC
                j RET

X_LEFT_DIAG_COUNT_CHECK:
                bne $t3, $a2, RET
                jal DISPLAY_GAMEBOARD
                jal DISPLAY_FULL_ROW
                li $v0, 4
                la $a0, NEWLINE
                syscall
                j SHOW_PLYR_WIN
# END: Left Diag

# END: Diag checks
#######################################################################

#######################################################################
# ** Draw Check ** #
#######################################################################
# START
DRAW_CHECK:
                la $t0, GAMEBOARD
                li $t1, 0 # counter
                mul $t2, $a2, $a2 # t2 = n^2
                li $t3, 0 # ' ' counter 

DRAW_CHECK_EXIT:
                beq $t1, $t2, DISPLAY_DRAW # t1 = n^2 game is draw
                lw $t7, 0($t0) # load current board pos
                beq $t7, $0, RET # if there is a 0(i.e ' ') return
                addi $t1, 1 # t1 += 1
                addi $t0, 4 # board pos += 4 bytes
                j DRAW_CHECK_EXIT

DISPLAY_DRAW:
                #jal DISPLAY_GAMEBOARD
                #jal DISPLAY_FULL_ROW
                li $v0, 4
                la $a0, NEWLINE
                syscall
                j SHOW_DRAW 
# END
#######################################################################

#######################################################################
# ** CPU's first move <3 ** #
#######################################################################
CPU_FIRST_MOVE:
                li $v0, 4
                la $a0, CPUFIRST
                syscall
                li $t0, 0 
                li $t2, 2
                li $t3, 0
                li $t4, 4
                la $t5, GAMEBOARD
                div $t0, $a2, $t2 # n / 2
                div $t3, $a2, $t2 # n / 2

                mul $t0, $t0, $a2 # (n / 2) * n
                add $t0, $t0, $t3 # ((n / 2) * n) * (n / 2)
                mul $t0, $t0, $t4 # (((n / 2) * n) * (n / 2)) * 4
                add $t5, $t5, $t0 # add t0 to board to get pos
                li $t0, 2
                sw $t0, 0($t5) # put 'O' at pos
                jr $ra
#######################################################################

#######################################################################
# ** CPU Move ** #
#######################################################################
CPU_MOVE:
                la $t0, GAMEBOARD
                li $t1, 0
                move $t2, $a2
                mul $t2, $t2, $t2
                li $t3, 2
                li $t8, 0
                
CPU_MOVE_EXIT_CHECK:
                beq $t1, $t2, TTT_LOOP
                lw $t4, 0($t0)
                bne $t4, $0, CPU_MOVE_UP
                li $v0, 4
                la $a0, S2
                syscall               
                sw $t3, 0($t0)
                j TTT_LOOP

CPU_MOVE_UP:
                addi $t1, $t1, 1
                addi $t0, $t0, 4
                j CPU_MOVE_EXIT_CHECK
#######################################################################

#######################################################################
# ** CPU Row check ** #
#######################################################################
CPU_O_ROW_INC:
                addi $t7, $t7, 1
                addi $t4, $t4, 4
                addi $t6, $t6, 1
                j CPU_ROW_WIN_J_EXIT_CHECK
CPU_X_ROW_INC:
                addi $t3, $t3, 1
                addi $t4, $t4, 4
                addi $t6, $t6, 1
                j CPU_ROW_WIN_J_EXIT_CHECK

CPU_ROW_WIN:
                li $t0, 1 # 'X' = 1
                li $t1, 2 # 'O' = 2
                li $t2, 4
                li $t3, 0 # 'X' count
                la $t4, GAMEBOARD
                li $t5, 0 # i
                li $t6, 0 # j
                li $t7, 0 # 'O' count
                li $s0, 0
                addi $s0, $a2, -1

CPU_ROW_WIN_I_EXIT_CHECK:
                 beq $t5, $a2, RET

CPU_ROW_WIN_J_EXIT_CHECK:
                beq $t6, $a2, O_CPU_ROW_COUNT_CHECK # if i == n check our count 
                lw $t8, 0($t4) # load current location on the board
                beq $t8, $t0, CPU_X_ROW_INC # board pos = 'X' t3++
                beq $t8, $t1, CPU_O_ROW_INC # board pos = 'O' t7++
                addi $t4, $t4, 4            # board pos += 4 bytes
                addi $t6, $t6, 1            # j += 1
                j CPU_ROW_WIN_J_EXIT_CHECK

O_CPU_ROW_COUNT_CHECK:
                bne $t7, $s0, CPU_ROW_WIN_I_INC # 'O'count!=n continue
                bgt $t3, $0, CPU_ROW_WIN_I_INC # 'X' count = 0 

CPU_ROW_MOVE:
                la $s1, GAMEBOARD
                li $t7, 0
                add $t7, $t7, $t5 # t7 = 0 + i
                mul $t7, $t7, $a2 # t7 = t7 * n
                mul $t7, $t7, $t2 # t7 = (t7 * n) * 4
                add $s1, $s1, $t7 # board pos + t7

CPU_ROW_WIN_DISPLAY:
                lw $t7, 0($s1)
                bne $t7, $0, CPU_ROW_WIN_UPR # board pos != 0board += 4
                sw $t1, 0($s1) # store 'O' in board
                jal DISPLAY_GAMEBOARD
                jal DISPLAY_FULL_ROW
                j SHOW_CPU_WIN

CPU_ROW_WIN_UPR:
                add $s1, $s1, $t2
                j CPU_ROW_WIN_DISPLAY
CPU_ROW_WIN_I_INC:               
                li $t3, 0 # reset count
                li $t7, 0 
                addi $t5, $t5, 1 # i += 1
                li $t6, 0 # j = 0
                j CPU_ROW_WIN_I_EXIT_CHECK
#######################################################################

#######################################################################
# ** CPU Col check ** #
#######################################################################
CPU_O_COL_INC:
                addi $t7, $t7, 1
                mul $s1, $a2, $t2
                add $t4, $t4, $s1
                addi $t6, $t6, 1            # j += 1
                j CPU_COL_WIN_J_EXIT_CHECK
CPU_X_COL_INC:
                addi $t3, $t3, 1
                mul $s1, $a2, $t2
                add $t4, $t4, $s1
                addi $t6, $t6, 1            # j += 1
                j CPU_COL_WIN_J_EXIT_CHECK

CPU_COL_WIN:
                li $t0, 1 # 'X' = 1
                li $t1, 2 # 'O' = 2
                li $t2, 4
                li $t3, 0 # 'X' count
                la $t4, GAMEBOARD
                li $t5, 0 # i
                li $t6, 0 # j
                li $t7, 0 # 'O' count
                li $s0, 0
                addi $s0, $a2, -1

CPU_COL_WIN_I_EXIT_CHECK:
                 beq $t5, $a2, RET

CPU_COL_WIN_J_EXIT_CHECK:
                beq $t6, $a2, O_CPU_COL_COUNT_CHECK # if i == n check our count 
                lw $t8, 0($t4) # load current location on the board
                beq $t8, $t0, CPU_X_COL_INC # board pos = 'X' t3++
                beq $t8, $t1, CPU_O_COL_INC # board pos = 'O' t7++
                mul $s1, $a2, $t2
                add $t4, $t4, $s1
                addi $t6, $t6, 1            # j += 1
                j CPU_COL_WIN_J_EXIT_CHECK

CPU_COL_WIN_I_INC:               
                li $t3, 0 # reset count
                li $t7, 0 
                addi $t5, $t5, 1 # i += 1
                li $t6, 0 # j = 0
                li $s3, 0
                la $s1, GAMEBOARD
                mul $s3, $t5, $t2
                add $s1, $s1, $s3
                j CPU_COL_WIN_I_EXIT_CHECK

O_CPU_COL_COUNT_CHECK:
                bne $t7, $s0, CPU_COL_WIN_I_INC # 'O'count!=n-1 cont
                bgt $t3, $0, CPU_COL_WIN_I_INC # 'X' count = 0 

CPU_COL_MOVE:
                la $s1, GAMEBOARD
                li $t7, 0 # reset 'O' count
                mul $t5, $t5, $t5  # i * 4 
                add $s1, $s1, $t5  # pos of first winning col spot

CPU_COL_WIN_DISPLAY:
                lw $t7, 0($s1)
                bne $t7, $0, CPU_COL_WIN_UPR # board pos != 0board += 4
                sw $t1, 0($s1) # store 'O' in board
                jal DISPLAY_GAMEBOARD
                jal DISPLAY_FULL_ROW
                j SHOW_CPU_WIN

CPU_COL_WIN_UPR:
                li $t8, 0
                mul $t8, $a2, $t2
                add $s1, $s1, $t8
                j CPU_COL_WIN_DISPLAY
#######################################################################

#######################################################################
# ** CPU Diags ** #
#######################################################################
# START: Right diag
CPU_RIGHT_DIAG_WIN:
                li $t0, 1 # 'X'
                li $t1, 2 # 'O'
                li $t2, 4
                li $t3, 0 # count 'X'
                li $t7, 0 # count 'O'
                la $t4, GAMEBOARD
                li $t5, 0 # i
                li $t6, 0 # n - 1
                addi $t6, $a2, -1
CPU_RIGHT_DIAG_WIN_I_CHECK:
                beq $t5, $a2, O_CPU_RIGHT_DIAG_COUNT_CHECK
                move $t8, $t6
                mul $t8, $t8, $t2 # t8 = (n - 1) * 4
                add $t4, $t4, $t8 # add to board
                lw $t8, 0($t4)  # get t8 pos from board
                beq $t8, $t1, O_CPU_RIGHT_DIAG_INC # O count ++
                beq $t8, $t0, X_CPU_RIGHT_DIAG_INC # X count ++
                addi $t5, $t5, 1 # i += 1
                j CPU_RIGHT_DIAG_WIN_I_CHECK

O_CPU_RIGHT_DIAG_INC:
                addi $t7, $t7, 1
                j CPU_RIGHT_DIAG_WIN_I_CHECK
X_CPU_RIGHT_DIAG_INC:
                addi $t3, $t3, 1
                j CPU_RIGHT_DIAG_WIN_I_CHECK

O_CPU_RIGHT_DIAG_COUNT_CHECK:
                bne $t7, $t6, RET # 'O' count != n-1 get out
                bgt $t3, $0, RET  # 'X' not > 0 get out
O_DIAG_CHECKS:
                la $s0, GAMEBOARD
O_DIAG_CHECKS2:
                move $t8, $t6
                mul $t8, $t8, $t2 # (n - 1) * 2
                add $s0, $s0, $t8 # add t8 to board pos
                lw $t8, 0($s0) # get item at t8 on board
                bne $t8, $0, O_DIAG_CHECKS2 # if not ' ' loop again
                sw $t1 0($s0)
                jal DISPLAY_GAMEBOARD
                jal DISPLAY_FULL_ROW
                j SHOW_CPU_WIN
# END: Right diag

# START: Left diag
CPU_LEFT_DIAG_WIN:
                li $t0, 1 # 'X'
                li $t1, 2 # 'O'
                li $t2, 4
                li $t3, 0 # count 'X'
                li $t7, 0 # count 'O'
                la $t4, GAMEBOARD
                li $t5, 0 # i
                li $t6, 0 # n - 1
                addi $t6, $a2, -1 

CPU_LEFT_DIAG_WIN_I_CHECK:
                beq $t5, $a2, O_CPU_LEFT_DIAG_COUNT_CHECK
                lw $t8, 0($t4)  # get pos from board
                beq $t8, $t1, O_CPU_LEFT_DIAG_INC # O count ++
                beq $t8, $t0, X_CPU_LEFT_DIAG_INC # X count ++
                move $t8, $a2 
                addi $t8, $t8, 1 # n + 1
                mul $t8, $t8, $t2 # n * 4
                add $t4, $t4, $t8 # add t8 to curr board pos
                addi $t5, $t5, 1 # i += 1
                j CPU_LEFT_DIAG_WIN_I_CHECK

O_CPU_LEFT_DIAG_INC:
                addi $t7, 1
                move $t8, $a2
                addi $t8, $t8, 1
                mul $t8, $t8, $t2 # n * 4
                add $t4, $t4, $t8 # add t8 to curr board pos
                addi $t5, $t5, 1 # i += 1
                j CPU_LEFT_DIAG_WIN_I_CHECK

X_CPU_LEFT_DIAG_INC:
                addi $t3, $t3, 1
                move $t8, $a2
                addi $t8, $t8, 1
                mul $t8, $t8, $t2 # n * 4
                add $t4, $t4, $t8 # add t8 to curr board pos
                addi $t5, $t5, 1 # i += 1
                j CPU_LEFT_DIAG_WIN_I_CHECK
        
O_CPU_LEFT_DIAG_COUNT_CHECK:
                bne $t7, $t6, RET # 'O' count != n-1 get out
                bgt $t3, $0, RET  # 'X' not > 0 get out

CPU_LEFT_DIAG:
                la $s0, GAMEBOARD

CPU_LEFT_DIAG_CHECK_EXIT:
                lw $t8, 0($s0)
                bne $t8, $0, CPU_LEFT_DIAG_UPR
                sw $t1, 0($s0)
                jal DISPLAY_GAMEBOARD
                jal DISPLAY_FULL_ROW
                j SHOW_CPU_WIN
                
CPU_LEFT_DIAG_UPR:
                move $t8, $a2
                addi $t8, $t8, 1
                mul $t8, $t8, $t2 # n * 4
                add $s0, $s0, $t8 # add t8 to curr board pos
                j CPU_LEFT_DIAG_CHECK_EXIT

# END: Left diag
#######################################################################

#######################################################################
# ** CPU blocking row ** #
#######################################################################
CPUB_O_ROW_INC:
                addi $t7, $t7, 1
                addi $t4, $t4, 4
                addi $t6, $t6, 1
                j CPUB_ROW_WIN_J_EXIT_CHECK
CPUB_X_ROW_INC:
                addi $t3, $t3, 1
                addi $t4, $t4, 4
                addi $t6, $t6, 1
                j CPUB_ROW_WIN_J_EXIT_CHECK

CPUB_ROW_WIN:
                li $t0, 1 # 'X' = 1
                li $t1, 2 # 'O' = 2
                li $t2, 4
                li $t3, 0 # 'X' count
                la $t4, GAMEBOARD
                li $t5, 0 # i
                li $t6, 0 # j
                li $t7, 0 # 'O' count
                li $s0, 0
                addi $s0, $a2, -1

CPUB_ROW_WIN_I_EXIT_CHECK:
                 beq $t5, $a2, RET

CPUB_ROW_WIN_J_EXIT_CHECK:
                beq $t6, $a2, O_CPUB_ROW_COUNT_CHECK # if i == n check our count 
                lw $t8, 0($t4) # load current location on the board
                beq $t8, $t0, CPUB_X_ROW_INC # board pos = 'X' t3++
                beq $t8, $t1, CPUB_O_ROW_INC # board pos = 'O' t7++
                addi $t4, $t4, 4            # board pos += 4 bytes
                addi $t6, $t6, 1            # j += 1
                j CPUB_ROW_WIN_J_EXIT_CHECK

O_CPUB_ROW_COUNT_CHECK:
                bne $t3, $s0, CPUB_ROW_WIN_I_INC
                bgt $t7, $0, CPUB_ROW_WIN_I_INC
                j CPU_ROW_COUNTER_ATTACK

CPUB_ROW_WIN_I_INC:
                li $t7, 0 # 'O' count = 0
                li $t3, 0 # 'X' count = 0
                addi $t5, $t5, 1 # i += 1
                li $t6, 0 # j = 0
                j CPUB_ROW_WIN_I_EXIT_CHECK    

CPU_ROW_COUNTER_ATTACK:
                la $s1, GAMEBOARD
                li $t8, 0
                add $t8, $t8, $t5 # t8 = i
                mul $t8, $t8, $a2 # t8 = i * n
                mul $t8, $t8, $t2 # t8 = (i * n) * 4
                add $s1, $s1, $t8 # new curr pos is t8

CPU_ROW_COUNTER:
                lw $t8, 0($s1)
                bne $t8, $0, CPU_ROW_COUNTER_UPR # curr pos != ' ' loop
                sw $t1, 0($s1) # put '0'
                li $v0, 4
                la $a0, S5
                syscall
                j TTT_LOOP

CPU_ROW_COUNTER_UPR:
                addi $s1, $s1, 4 # add 4 bytes to the array
                j CPU_ROW_COUNTER
#######################################################################

#######################################################################
# ** CPU blocking cols ** #
#######################################################################
CPUB_O_COL_INC:
                addi $t7, $t7, 1
                mul $s1, $a2, $t2
                add $t4, $t4, $s1
                addi $t6, $t6, 1            # j += 1
                j CPUB_COL_WIN_J_EXIT_CHECK
CPUB_X_COL_INC:
                addi $t3, $t3, 1
                mul $s1, $a2, $t2
                add $t4, $t4, $s1
                addi $t6, $t6, 1            # j += 1
                j CPUB_COL_WIN_J_EXIT_CHECK

CPUB_COL_WIN:
                li $t0, 1 # 'X' = 1
                li $t1, 2 # 'O' = 2
                li $t2, 4
                li $t3, 0 # 'X' count
                la $t4, GAMEBOARD
                li $t5, 0 # i
                li $t6, 0 # j
                li $t7, 0 # 'O' count
                li $s0, 0
                addi $s0, $a2, -1

CPUB_COL_WIN_I_EXIT_CHECK:
                beq $t5, $a2, RET

CPUB_COL_WIN_J_EXIT_CHECK:
                beq $t6, $a2, O_CPUB_COL_COUNT_CHECK # if i == n check our count 
                lw $t8, 0($t4) # load current location on the board
                beq $t8, $t0, CPUB_X_COL_INC # board pos = 'X' t3++
                beq $t8, $t1, CPUB_O_COL_INC # board pos = 'O' t7++
                mul $s4, $a2, $t2
                add $t4, $t4, $s4
                addi $t6, $t6, 1            # j += 1
                j CPUB_COL_WIN_J_EXIT_CHECK

O_CPUB_COL_COUNT_CHECK:
                bne $t3, $s0, CPUB_COL_WIN_I_INC
                bgt $t7, $0, CPUB_COL_WIN_I_INC
                j CPU_COL_COUNTER_ATTACK

CPUB_COL_WIN_I_INC:
                li $t3, 0 # reset 'X' count
                li $t7, 0 # reset 'O' counter
                addi $t5, $t5, 1 # i += 1
                li $t6, 0 # j = 0
                li $s3, 0
                la $t4, GAMEBOARD
                mul $s3, $t5, $t2 # n * 4
                add $t4, $t4, $s3 # curr pos is next col
                j CPUB_COL_WIN_I_EXIT_CHECK 

CPU_COL_COUNTER_ATTACK:
                la $s1, GAMEBOARD
                li $t7, 0 # reset 'O' counter
                mul $t5, $t5, $t2 # i = i * 4
                add $s1, $s1, $t5 # new curr pos is t5 or i
CPU_COL_COUNTER:
                lw $t8, 0($s1)
                bne $t8, $0, CPU_COL_COUNTER_UPR
                sw $t1, 0($s1)
                li $v0, 4
                la $a0, S5
                syscall
                j TTT_LOOP

CPU_COL_COUNTER_UPR:
                mul $s3, $a2, $t2 # n * 4
                add $s1, $s1, $s3 # curr pos new col
                j CPU_COL_COUNTER
#######################################################################

#######################################################################
# ** CPU blocking diags ** #
#######################################################################
# START: Right diag
CPUB_RIGHT_DIAG_WIN:
                li $t0, 1 # 'X'
                li $t1, 2 # 'O'
                li $t2, 4
                li $t3, 0 # count 'X'
                li $t7, 0 # count 'O'
                la $t4, GAMEBOARD
                li $t5, 0 # i
                li $t6, 0 # n - 1
                addi $t6, $a2, -1
CPUB_RIGHT_DIAG_WIN_I_CHECK:
                beq $t5, $a2, O_CPUB_RIGHT_DIAG_COUNT_CHECK
                move $t8, $t6
                mul $t8, $t8, $t2 # t8 = (n - 1) * 4
                add $t4, $t4, $t8 # add to board
                lw $t8, 0($t4)  # get t8 pos from board
                beq $t8, $t1, O_CPUB_RIGHT_DIAG_INC # O count ++
                beq $t8, $t0, X_CPUB_RIGHT_DIAG_INC # X count ++
                addi $t5, $t5, 1 # i += 1
                j CPUB_RIGHT_DIAG_WIN_I_CHECK

O_CPUB_RIGHT_DIAG_INC:
                addi $t7, $t7, 1
                j CPUB_RIGHT_DIAG_WIN_I_CHECK
X_CPUB_RIGHT_DIAG_INC:
                addi $t3, $t3, 1
                j CPUB_RIGHT_DIAG_WIN_I_CHECK

O_CPUB_RIGHT_DIAG_COUNT_CHECK:
                bgt $t7, $0, RET # '0' count > 0 get out
                bne $t3, $t6, RET # 'X' != n get out
                la $s0, GAMEBOARD

CPU_RIGHT_DIAG_COUNTER_ATTACK:
                mul $s1, $t6, $t2
                add $s0, $s0, $s1
                lw $t8, 0($s0)
                bne $t8, $0, CPU_RIGHT_DIAG_COUNTER_ATTACK
                sw $t1, 0($s0)
                li $v0, 4
                la $a0, S5
                syscall
                j TTT_LOOP

# END: Right diag

# START: Left diag
CPUB_LEFT_DIAG_WIN:
                li $t0, 1 # 'X'
                li $t1, 2 # 'O'
                li $t2, 4
                li $t3, 0 # count 'X'
                li $t7, 0 # count 'O'
                la $t4, GAMEBOARD
                li $t5, 0 # i
                li $t6, 0 # n - 1
                addi $t6, $a2, -1 

CPUB_LEFT_DIAG_WIN_I_CHECK:
                beq $t5, $a2, O_CPUB_LEFT_DIAG_COUNT_CHECK
                lw $t8, 0($t4)  # get pos from board
                beq $t8, $t1, O_CPUB_LEFT_DIAG_INC # O count ++
                beq $t8, $t0, X_CPUB_LEFT_DIAG_INC # X count ++
                move $t8, $a2 
                addi $t8, $t8, 1 # n + 1
                mul $t8, $t8, $t2 # n * 4
                add $t4, $t4, $t8 # add t8 to curr board pos
                addi $t5, $t5, 1 # i += 1
                j CPUB_LEFT_DIAG_WIN_I_CHECK

O_CPUB_LEFT_DIAG_INC:
                addi $t7, 1
                move $t8, $a2
                addi $t8, $t8, 1
                mul $t8, $t8, $t2 # n * 4
                add $t4, $t4, $t8 # add t8 to curr board pos
                addi $t5, $t5, 1 # i += 1
                j CPUB_LEFT_DIAG_WIN_I_CHECK

X_CPUB_LEFT_DIAG_INC:
                addi $t3, $t3, 1
                move $t8, $a2
                addi $t8, $t8, 1
                mul $t8, $t8, $t2 # n * 4
                add $t4, $t4, $t8 # add t8 to curr board pos
                addi $t5, $t5, 1 # i += 1
                j CPUB_LEFT_DIAG_WIN_I_CHECK

O_CPUB_LEFT_DIAG_COUNT_CHECK:
                bne $t3, $t6, RET
                bgt $t7, $0, RET
                la $s0, GAMEBOARD

CPU_LEFT_DIAG_COUTER_ATTACK:
                lw $t8, 0($s0)
                bne $t8, $0, CPU_LEFT_DIAG_COUNTER_UPR
                sw $t1, 0($s0)
                li $v0, 4
                la $a0, S5
                syscall
                j TTT_LOOP

CPU_LEFT_DIAG_COUNTER_UPR:
                move $t8, $a2
                addi $t8, $t8, 1
                mul $t8, $t8, $t2 # n * 4
                add $s0, $s0, $t8 # add t8 to curr board pos
                j CPU_LEFT_DIAG_COUTER_ATTACK
# END: Left diag
#######################################################################

#######################################################################
# ** Game-Loop ** #
# Algorithm:
#######################################################################

TTT_LOOP:
        # Following are a series of procedures called to handle game
        

        # Display
        jal DISPLAY_GAMEBOARD
        jal DISPLAY_FULL_ROW
        
        # Draw
        jal DRAW_CHECK
        
        # Player
        jal USER_INPUT
        jal PLYR_ROW_WIN
        jal PLYR_COL_WIN
        jal PLYR_RIGHT_DIAG_WIN
        jal PLYR_LEFT_DIAG_WIN
        
        # Draw
        #jal DRAW_CHECK

        # CPU 
        jal CPU_LEFT_DIAG_WIN
        jal CPU_RIGHT_DIAG_WIN
        jal CPU_COL_WIN
        jal CPU_ROW_WIN
        jal CPUB_LEFT_DIAG_WIN
        jal CPUB_RIGHT_DIAG_WIN
        jal CPUB_COL_WIN
        jal CPUB_ROW_WIN
        jal CPU_MOVE

        jal TTT_LOOP # keep going till over
#######################################################################

.globl main

main:
        li $v0, 4                   # Greet player with message
        la $a0, INTRO
        syscall

        li $v0, 4                   # Prompt the user for a number 'n'
        la $a0, USERN
        syscall

        li $v0, 5                   # Get 'n' and move it to $a0
        syscall
        move $a2, $v0
        
        jal INIT_GAMEBOARD          # Initialize board
        jal CPU_FIRST_MOVE          # CPU always makes first move
        jal TTT_LOOP                # Start game loop

#######################################################################
# data segment
#######################################################################

.data

# Gameboard
GAMEBOARD: .space 400 # allocate 400 bytes for the board

# String components
NEWLINE: .asciiz "\n"
BAD_MOVE: .asciiz "Invalid move. Try again"
INTRO: .asciiz "Let's play a game of tic-tac-toe.\n"
USERN: .asciiz "Enter n: "
CPUFIRST: .asciiz "I'll go first.\n"
ENTERROW: .asciiz "Enter row: "
ENTERCOL: .asciiz "Enter col: "
DRAW: .asciiz "We have a draw!\n"
CPUWIN: .asciiz "I'm the winner!\n"
PLYRWIN: .asciiz "You are the winner!\n"
X: .asciiz "X"
O: .asciiz "O"
SPACE: .asciiz " "
COLBAR: .asciiz "|"
ROWBAR: .asciiz "-+"
ROWPLUS: .asciiz "+"
LTROW: .asciiz "Row cannot be less than 0. Try again."
LTCOL: .asciiz "Column cannot be less than 0. Try again."
GTROW: .asciiz "Row cannot be greater than n-1. Try again."
GTCOL: .asciiz "Column cannot be greater than n-1. Try again."
#S1: .asciiz "CPU is about to make his move...\n"
S2: .asciiz "I'm finalizing my calculation...\n"
#S3: .asciiz "CPU is nearing his decision...\n"
#S4: .asciiz "CPU is triangulating the coordinates...\n"
S5: .asciiz "I'm countering..\n"
#CPUSAY: .word S1 S2 S3 S4
