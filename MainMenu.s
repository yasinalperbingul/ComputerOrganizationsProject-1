.data
	welcome_message: .asciiz "Welcome to our MIPS project!"
	main_menu_prompt: .asciiz "\n\nMain Menu:\n1. Base Converter\n2. Add Rational Number\n3. Text Parser\n4. Mystery Matrix Operation\n5. Exit\nPlease select an option:"
	exit_prompt: 	.asciiz "Program ends, bye. "
	q1_prompt1: 	.asciiz "\nInput:"
	q1_prompt2: 	.asciiz "Type:"
	q1_prompt3: 	.asciiz "Output:"
	nom1: 		.asciiz "Enter the first numerator:"
	nom2: 		.asciiz "Enter the second numerator:"
	denom1: 	.asciiz "Enter the first denominator:"
	denom2:		.asciiz "Enter the second denominator:"
	sentence: 	.asciiz "Please enter the input text : "
	parser: 	.asciiz "Please enter the parser characters : "
	q4_prompt1:	.asciiz "Input:\n"
	output: 	.asciiz "Output:\n"
	tab:		.asciiz "\t"
	new_line2: 	.asciiz "\n"
	q1_input: 		.space 1024
	q1_output_list: 	.space 1024
	
	sentence_length:	.space 1024
	parser_length: 		.space 16
	
	q4_input_size:		.space 256
	q4_array_size:		.word 64
	
	
.text
	li $v0, 4											
	la $a0, welcome_message
	syscall
	menu_loop:					
		li $v0, 4											
		la $a0, main_menu_prompt
		syscall
		
		li   $v0, 5     	   # Syscall to read an integer
          	syscall
          	move $t0, $v0   	   # User select stored in t0
          	
          	beq $t0, 1, question1
          	beq $t0, 2, question2 
          	beq $t0, 3, question3 
          	beq $t0, 4, question4  
          	beq $t0 ,5, exit
          
	question1:
		li $v0, 4											
		la $a0, q1_prompt1
		syscall												# Print the prompt1 (Input:)
		
		li $a1, 1024
		li $v0, 8
		la $a0, q1_input
		syscall												# Get the user input
	
		move $t2, $a0 											# t2 = input address
		move $t9, $a0 											# t9 = input address temp
		
		li $v0, 4
		la $a0, q1_prompt2
		syscall												# Print the prompt2 (Type:)
	
	
		li $v0, 5
		syscall												# Get the type input
		move $s3, $v0											# s3 = type (ascii)

   		li $s0, 0 											# s0 = 0 (length of the input)
   		li $t4, 1 											# t4 = 1 (For shift operations)
   		
   		calculate_input_length:
    			lb $t3, ($t2) 										# first byte of the input
    			beq $t3, 10, calculate_value 								# if the pointer at the end of line, exit from the loop
    			addi $s0, $s0, 1 									# increment the input length counter by 1
    			addi $t2, $t2, 1 									# increment input address by 1
    			j calculate_input_length
    		
    		calculate_value:
    			add $t2, $t9, $zero 									# input address
    			add $t2, $t2, $s0 									# get the end of line character from the input
    			addi $t2, $t2, -1 									# Decrement 1 to get rightmost bit	
			lb $t3, ($t2) 										# load right most bit of the input into t3
			li $t5, 0 										# t5 = bit position
			add $t7, $s0, -1 									# t7 = length of the input - 1 
			add $s1, $s1, $zero 									# s1 = final output value
			beq $s3, 2, calculate_hex 								# if s3 = 2 (type) calculate hex
		
		loop_input:
			beq $s0, $t5, end_q1 									# if we are at the left most bit, execute end
			beq $t3, 49, add_value 									# if current bit is 1, execute add_value
			addi $t5, $t5, 1 									# increment position by 1
			addi $t2, $t2, -1 									# decrement address of input by 1
			lb $t3, ($t2) 										# load the next bit of the input into t3
			j loop_input
		
			add_value:
				beq $t5, 0, rightmost_bit_calculation 						# if t5=0 it means it is at the rightmost bit
				beq $t5, $t7, leftmost_bit_calculation 						# if we are at the leftmost bit, check two's complement condition
				sllv $t6, $t4, $t5 								# shift left (power of two calculation) 
				add $s1, $s1, $t6 								# add the value of the t6 to the final result
				addi $t5, $t5, 1 								# increment position by 1
				addi $t2, $t2, -1 								# decrement address of input by 1
				lb $t3, ($t2) 									# load the next bit of the input into t3 
				j loop_input
			
			rightmost_bit_calculation:
				addi $s1, $s1, 1 								# add 1 to the final result
				addi $t5, $t5, 1 								# increment position by 1
				addi $t2, $t2, -1 								# decrement address of input by 1
				lb $t3, ($t2) 									# load the next bit of the input into t3 
				j loop_input
			
			leftmost_bit_calculation:
				beq $t3, 48, end_q1 								# if leftmost bit is 0, end the calculation , otherwise do two's complement calculation
				sllv $t6, $t4, $t5 								# shift left (power of two calculation)
				sub $s1, $t6, $s1 								# substract leftmost bit value from current result
				mul $s1, $s1, -1 								# multiply by -1 to make it negative
				j end_q1 
				
		calculate_hex:	
			li $t8, 4										# t8 = 4 (for divisoin)				
			div $s0, $t8										# divide the length of the input by 4
			mflo $t0										# t0 = result of the div operation
			mfhi $t1										# t1 = remainder of the div operation
			addi $t1, $t1, -1									# t1 = remainder -1 (for shift operation)
			lb $t3, ($t9)										# load the first bit of the input into t3
			la $s1, q1_output_list									# load adress of output_list size into s1
			la $t5, ($s1)										# load adress of s1 into t5
			li $t8, 0										# t8 = 8
			
			hex_loop:
				beq $t1, -1, generate_hex							# if we finished part of the 4 bit, generate hex value from these	
				beq $t3, 10, type2_check							# if end of line, go to type2_check
				beq $t3, 49, add_hex_value							# if bit is 1, add hex value
				addi $t1, $t1, -1 								# decrement position by 1
				addi $t9, $t9, 1 								# increment address of input by 1
				lb $t3, ($t9) 									# load the next bit of the input into t3
				j hex_loop
		
			add_hex_value:
				sllv $t8,$t4,$t1								# shift left (power of 2 operation)
				add $t6,$t6,$t8									# add the t6 = t6 + t8
				addi $t1,$t1,-1 								# decrement position by 1
				addi $t9,$t9,1 									# increment address of input by 1
				lb $t3,($t9) 									# load the next bit of the input into t3 
				j hex_loop
			
			generate_hex:										# generate hex value from 1 to F
				beq $t6,0,zero
				beq $t6,1,one
				beq $t6,2,two
				beq $t6,3,three
				beq $t6,4,four
				beq $t6,5,five
				beq $t6,6,six
				beq $t6,7,seven
				beq $t6,8,eight
				beq $t6,9,nine
				beq $t6,10,A
				beq $t6,11,B
				beq $t6,12,C
				beq $t6,13,D
				beq $t6,14,E
				beq $t6,15,F
			
				zero:										# based on t6, load corresponding character into 
					li $s6,48								# the result and go back to the hex loop
					sb $s6,($t5)
					addi $t5,$t5,1
					li $t1,3
					li $t8,0
					li $t6,0
					j hex_loop
				one:
					li $s6,49
					sb $s6,($t5)
					addi $t5,$t5,1
					li $t1,3
					li $t8,0
					li $t6,0
					j hex_loop
				two:
					li $s6,50
					sb $s6,($t5)
					addi $t5,$t5,1
					li $t1,3
					li $t8,0
					li $t6,0
					j hex_loop
				three:
					li $s6,51
					sb $s6,($t5)
					addi $t5,$t5,1
					li $t1,3
					li $t8,0
					li $t6,0
					j hex_loop	
				four:
					li $s6,52
					sb $s6,($t5)
					addi $t5,$t5,1
					li $t1,3
					li $t8,0
					li $t6,0
					j hex_loop
				five:
					li $s6,53
					sb $s6,($t5)
					addi $t5,$t5,1
					li $t1,3
					li $t8,0
					li $t6,0
					j hex_loop
				six:
					li $s6,54
					sb $s6,($t5)
					addi $t5,$t5,1
					li $t1,3
					li $t8,0
					li $t6,0
					j hex_loop
				seven:
					li $s6,55
					sb $s6,($t5)
					addi $t5,$t5,1
					li $t1,3
					li $t8,0
					li $t6,0
					j hex_loop
				eight:
					li $s6,56
					sb $s6,($t5)
					addi $t5,$t5,1
					li $t1,3
					li $t8,0
					li $t6,0
					j hex_loop
				nine:
					li $s6,57
					sb $s6,($t5)
					addi $t5,$t5,1
					li $t1,3
					li $t8,0
					li $t6,0
					j hex_loop
				A:
					li $s6,65
					sb $s6,($t5)
					addi $t5,$t5,1
					li $t1,3
					li $t8,0
					li $t6,0
					j hex_loop

				B:
					li $s6,66
					sb $s6,($t5)
					addi $t5,$t5,1
					li $t1,3
					li $t8,0
					li $t6,0
					j hex_loop
				C:
					li $s6,67
					sb $s6,($t5)
					addi $t5,$t5,1
					li $t1,3
					li $t8,0
					li $t6,0
					j hex_loop
				D:
					li $s6,68
					sb $s6,($t5)
					addi $t5,$t5,1
					li $t1,3
					li $t8,0
					li $t6,0
					j hex_loop
				E:
					li $s6,69
					sb $s6,($t5)
					addi $t5,$t5,1
					li $t1,3
					li $t8,0
					li $t6,0
					j hex_loop
				F:	
					li $s6,70
					sb $s6,($t5)
					addi $t5,$t5,1
					li $t1,3
					li $t8,0
					li $t6,0
					j hex_loop

    		delete_first_zero:										# delete the mostleft 0 from the hex
    			la $s1, 1($s1)
    			j end_q1				
    		type2_check:											# check if first bit of the s1 is 0
    			lb $t3, ($s1)
    			beq $t3, 48, delete_first_zero
    			
    		end_q1:
			la $a0, q1_prompt3												
			li $v0, 4
			syscall											# print "Output:"
			beq $s3, 2, print_type2									# if type is 2, print hex value
	
		print_type1:
			la $a0, ($s1)
			li $v0, 1
			syscall
			j back_to_main_menu									# print two's complement
	
		print_type2:
			la $a0, ($s1)
			li $v0, 4
			syscall
			j back_to_main_menu									# print hex
			
		back_to_main_menu:
			j clear_registers									# clear registers to prevent collusion and go to the menu	
			
		
														
	question2:
	main:     		   # Take the input values
	  li   $v0, 4    	   # Syscall to print prompt string nominator
          la   $a0, nom1           # li and la are pseudo instr.
          syscall
          li   $v0, 5     	   # Syscall to read an integer
          syscall
          move $t0, $v0   	   # First nominator stored in $t0
          
          li   $v0, 4    	   # Syscall to print prompt string nominator
          la   $a0, denom1         # li and la are pseudo instr.
          syscall
          li   $v0, 5     	   # Syscall to read an integer
          syscall
          move $t1, $v0   	   # First denominator stored in $t1
          
          li   $v0, 4    	   # Syscall to print prompt string nominator
          la   $a0, nom2           # li and la are pseudo instr.
          syscall
          li   $v0, 5     	   # Syscall to read an integer
          syscall
          move $t2, $v0   	   # Second nominator stored in $t2
          
          li   $v0, 4    	   # Syscall to print prompt string nominator
          la   $a0, denom2         # li and la are pseudo instr.
          syscall
          li   $v0, 5     	   # Syscall to read an integer
          syscall
          move $t3, $v0   	   # Second denominator stored in $t3
          
          
          # Compute the sum of two rational numbers without simplification.
          mul $t4, $t0, $t3	   # $t4 : FirstNominator*SecondDenominator
          mul $t5, $t1, $t2        # $t5 : SecondNominator*FirstDenominator
          add $t4, $t4, $t5        # $t4 : FirstNominator*SecondDenominator + SecondNominator*FirstDenominator
          			   # Result nominator stored in $t4
          
          mul $t5, $t1, $t3        # $t5 : FirstDenominator*SecondDenominator
          			   # Result denominator stored in $t5
          			   
          			   
          # Make simplification with using Eculid's Algortihm
	  div $t5, $t4
	  mfhi $t6
	  move $t8, $t4
	  
while:    beq $t6, $zero, endwhile
	  div $t8, $t6
	  mfhi $t7
	  move $t8, $t6
	  move $t6, $t7
	  j while
	  
endwhile:
	  
	  div $t4, $t4, $t8
	  div $t5, $t5, $t8
	  
	  
	  # Printing all values		   
          move	$a0, $t0	   # move the FirstNominator to print into $a0
	  li	$v0, 1		   # load syscall print_int into $v0
	  syscall
	  
	  addi $a0, $zero, 47	   # move the / character to print into $a0
	  li $v0, 11               # load syscall print_int into $v0
	  syscall
	  
	  move	$a0, $t1	   # move the FirstDenominator to print into $a0
	  li	$v0, 1		   # load syscall print_int into $v0
	  syscall
	  
	  addi $a0, $zero, 43	   # move the + character to print into $a0
	  li $v0, 11               # load syscall print_int into $v0
	  syscall
	  
	  move	$a0, $t2	   # move the SecondNominator to print into $a0
	  li	$v0, 1		   # load syscall print_int into $v0
	  syscall
	  
	  addi $a0, $zero, 47	   # move the / character to print into $a0
	  li $v0, 11               # load syscall print_int into $v0
	  syscall
	  
	  move	$a0, $t3	   # move the SecondDenominator to print into $a0
	  li	$v0, 1		   # load syscall print_int into $v0
	  syscall	
	  
	  addi $a0, $zero, 61	   # move the = character to print into $a0
	  li $v0, 11               # load syscall print_int into $v0
	  syscall		
	  
	  move	$a0, $t4	   # move the SecondNominator to print into $a0
	  li	$v0, 1		   # load syscall print_int into $v0
	  syscall
	  
	  addi $a0, $zero, 47	   # move the / character to print into $a0
	  li $v0, 11               # load syscall print_int into $v0
	  syscall
	  
	  move	$a0, $t5	   # move the SecondDenominator to print into $a0
	  li	$v0, 1		   # load syscall print_int into $v0
	  syscall	
	  
	  j clear_registers	   # go back to the main menu
	  
		
		
	question3:
	
		la $a0,sentence   
		li $v0,4			# print string
		syscall
                                      
		la  $a0,sentence_length		#sentence lenght
		li $a1,1024			#sentence lenght max
		li $v0,8			# read string
		syscall
		move $s0,$a0			#define $s0 as sentence string
                                                                          
		la $a0,parser
		li $v0,4
		syscall
                                      
		la $a0,parser_length
		li $a1,16                            #parser lenght max
		li $v0 ,8                            #read string
		syscall
		move $s1,$a0                         #define #s1 as parser characters string
                                      
		la $a0,output
		li $v0,4
		syscall
                                      
		move      $t4,$s0                     #sentence temporary value is $t4
		move      $t5,$s1                     #parser temporary value is $t5
		li $a0,10
		
		i_loop:                                
					   
			lb $t1,($t4)                         #sentence character moved to temporary byte value
			addi $t4,$t4,1                       #All $t5 value and $t4 values are not equals then system checking new sentence byte
			beq $t1,32,newLine	           #If sentence character is space go to the newLine label                
			beq $t1,10,end_q3                      #10 is end of line in ascii code
			move $t5,$s1                         #reset the parser character
			j j_loop                              #if $t1 not equal 10 then jump to Jloop
			
		j_loop:                               
			lb $t2,0($t5)                         #parser character moved to temporary byte value
			beq $t1,$t2,newLine                   #If the $t1(sentence byte) and $t2(parser byte) are equal go to new line label
			addi $t5,$t5,1                        #If the $t1 and $t2 are not equal change the $t5 first byte
			bne $t1,$t2,k_loop                     #If $t1 and $t2 are not equal go to the Kloop label
			
		k_loop:
			bne $t2,10,j_loop                      #If the $t2 value not equal 10 so system did not check all values
			beq $t2,10,printSentence              #�f the $t2 value equal 10,system check all values for parser character 
			
		newLine:
			beq $a0,10,i_loop	
			la $a0,'\n'                           #Load adrress for new line character
			li $v0,11                             #Print character '\n'
			syscall 
			j i_loop                               #Go to iloop for increase $t1 value and other values
			
		printSentence:            
			la $a0,($t1)                             
			li $v0,11                             #Print character
			syscall
			j i_loop                               #Go to Iloop to increase $t4
		end_q3: 
			j clear_registers	   # go back to the main menu
	
question4:
	
	li $v0, 4
	la $a0,	q4_prompt1
	syscall			# Prompt the input string 
	
	li $v0, 8
	la $a0, q4_input_size
	li $a1, 1024
	syscall			# Take the input string from user
	
	move $t0, $a0   
	move $t1, $a0  		# Take base adress of the input text to the temp register $t0 and $t1
	
	la $s3, q4_array_size		# Take base adress of the array text to the temp register $s3
	
	addi $s0,$s0,1		# start the size of array from 1
	li $t2, 0		# total length of the input (including spaces)
	
	calculate_input_size:
    	lb $t3, ($t0) 			# first byte of the input
    	beq $t3, 10, edit_input_address	# if the pointer at the end of line, exit from the loop 
    	beq $t3, 32, increment_size    # if the pointer points a space caharacter, then increment array size by 1										
    	addi $t0, $t0, 1 	        # increment input address by 1
    	addi $t2, $t2, 1		# increment total input length by 1
    	j calculate_input_size
    	
    	
    	increment_size:
	addi $s0, $s0, 1		# increment size by 1 (size in $s0)
	addi $s3, $s3, 4		# increment int array index by 4 (to reach the last element)
	addi $t0, $t0, 1		# increment input address by 1
	addi $t2, $t2, 1		# increment total input length by 1
	j calculate_input_size

	edit_input_address:
	addi $t0, $t0, -1   		# t0 was at the end of line, add -1 to get the last character of the input
	addi $s3, $s3, -4		# decrement int array index by 1 element
	li $t4,1			# power of 10
	li $t5,0			# current value of the calculated int
	j construct_array
	
	construct_array:
	lb $t3, ($t0) 			# first byte of the input
	beq $t2, 0, insert_first_element	# when total size of input is 0, it means we are at the beginning of the input and exit from the loop
	addi $t2,$t2,-1			# decrement total size of input
	beq $t3,32,insert_to_array
	addi $t3,$t3,-48		# get the int value
	mul $t3, $t3,$t4
	add $t5,$t5,$t3			# sum current int value with current character's value
	mul $t4, $t4,10			# power of 10 operation
	addi $t0,$t0,-1			# decrement input address by 1
    	j construct_array

	insert_to_array:
	sw $t5, ($s3)			# store the int into last index of array
	addi $s3,$s3,-4			# go to the left side of the array
	li $t5,0			# reset calculated int value
	addi $t0,$t0,-1			# decrement input address by 1
	li $t4,1			# reset power of 10
	j construct_array 
	
	insert_first_element:
	sw $t5, ($s3)
	j find_square_root
	
	find_square_root:
	addi $t6, $zero,1		# using $t6 as a counter starting from 1
	
	root_loop:
	mul $t8, $t6, $t6		# take square of current count value andd store in $t8
	beq $t8,$s0,n_equal		# compare with size of array, if equal then continue the next process
	addi $t6,$t6,1			# if not equal, then increase the count number and start the loop again
	j root_loop
	
	n_equal:
	move $s4, $t6			# store the n in $s4
	
	
array_operations:
	addi $t7,$s4, -2 		# t7 = array size -2 
	j calculate_row_multiplications
	back:
	move $a0, $s7
	li $v0, 1
	syscall
	
	li   $v0, 4    	   	# Syscall to print prompt string "\n"
        la   $a0, new_line2        
        syscall
	
	
	j calculate_column_multiplications
	back2:
	move $a0, $s7
	li $v0, 1
	syscall
	
	
	j clear_registers


#----------------------------------Row Operations------------------------------------------------------
calculate_row_multiplications:
	li $s7, 1 # mult = 1
	li $t0, 0 # $t0 as the row index
	li $t3, 0 # $t3 as the column index
	 
	multLoop:
		mul $t1, $t0, $s4 # $t1: rowIndex * colSize         	a1 yerine s4
		add $t1, $t1, $t3  #		   + colIndex    
		mul $t1, $t1, 4   # 		   * dataSize    
		add $t1, $t1, $s3  # 		   + baseAddress	a3 yerine s3 
		
		lw $t2, ($t1)
		mul $s7, $s7, $t2
		
		addi $t3, $t3, 1   # column = column+1
		j increase_decrease_row
		continue_loop:
		
		blt $t3, $s4, multLoop  # if i<size, then loop again
		
		
	blt $t0, $t7, new_row_line # if current column index < array size -2 go to new column
	j back
	
increase_decrease_row:
	and $t4, $t3, 1
	bne $t4, $zero, increase
	subi $t0, $t0, 1
	j continue
	
	increase:
	addi $t0, $t0, 1
	continue:
	j continue_loop

new_row_line:
	addi $t0, $t0, 2	# increase the row index by 2
	addi $t3, $zero, 0	# initilialize the coolumn index into 0
        
        move $a0, $s7
	li $v0, 1
	syscall
	li   $v0, 4    	   	# Syscall to print prompt string "\t"
        la   $a0, tab     
        syscall
        addi $s7, $zero, 1
        	
	j multLoop
	
#----------------------------------Column Operations------------------------------------------------------
calculate_column_multiplications:
	li $s7, 1 # mult = 1
	li $t0, 0 # $t0 as the index
	li $t3, 1 # $t3 as the column index
	 
	multLoop2:
		mul $t1, $t0, $s4 # $t1: rowIndex * colSize     
		add $t1, $t1, $t3  #		   + colIndex    
		mul $t1, $t1, 4   # 		   * dataSize    
		add $t1, $t1, $s3  # 		   + baseAddress
		
		lw $t2, ($t1)
		mul $s7, $s7, $t2
		
		addi $t0, $t0, 1   # i= i + 1
		j increase_decrease_column
		continue_loop2:
		
		blt $t0, $s4, multLoop2  # if i<size, then loop again
	
	blt $t3, $t7, new_column_line # if current column index < array size -1 go to new column
	j back2
	
	
increase_decrease_column:
	and $t4, $t0, 1
	bne $t4, $zero, increase2
	addi $t3, $t3, 1
	j continue2
	
	increase2:
	subi $t3, $t3, 1
	continue2:
	j continue_loop2

new_column_line:
	addi $t3, $t3, 2	# increase the column index by 2
	addi $t0, $zero, 0	# initilialize the row column into 0
	
	move $a0, $s7
	li $v0, 1
	syscall
	li   $v0, 4    	   	# Syscall to print prompt string "\t"
        la   $a0, tab       
        syscall
	
        addi $s7, $zero, 1
        
	j multLoop2
	
	clear_registers:	# clear registers to prevent collusions between questions
		li $at, 0
		li $v0, 0
		li $v1, 0
		li $a0, 0
		li $a1, 0
		li $a2, 0
		li $a3, 0
		li $t0, 0
		li $t1, 0
		li $t2, 0
		li $t3, 0
		li $t4, 0
		li $t5, 0
		li $t6, 0
		li $t7, 0
		li $t8, 0
		li $t9, 0
		li $s0, 0
		li $s1, 0
		li $s2, 0
		li $s3, 0
		li $s5, 0
		li $s6, 0
		li $s7, 0
		j menu_loop
		        
	exit:
		li $v0, 4											
		la $a0, exit_prompt
		syscall			# print the exit prompt 
		li $v0, 10
		syscall			# exit from the program	
