.text
message: .asciz "ASSIGNMENT 2: Factorial\nTeam 139:\nDiogo Piteira Castelos - NetID: dcastelos\nFilip Angheluta - NetID: fangheluta\n\n"
prompt: .asciz "Let's factorialize!\nEnter non-negative number: "
input: .asciz "%ld"
output: .asciz "Your factorialized number is: %ld\n"
undefined: .asciz "Your factorialized number is: undefined\n"

.global main

# main subroutine
main:
	# prologue
	pushq %rbp # push the base pointer
	movq %rsp , %rbp # copy stack pointer value to base pointer

	# print out student details
	movq $0 , %rax # no vector registers in use for printf
	movq $message , %rdi # first parameter: the message string
	call printf # call printf to print message

	# print out first prompt
	movq $0 , %rax # no vector registers in use for printf
	movq $prompt , %rdi # first parameter: the prompt string
	call printf # call printf to print out prompt
	
	# read number to be factorialized
	subq $16 , %rsp # make 16 bytes space on the stack for read variable
	movq $0 , %rax # no vector registers in use for scanf
	movq $input , %rdi # set the format string to input
	leaq -16(%rbp) , %rsi # set the address on the stack for the read variable
	call scanf # call scanf subroutine with the parameters above
	popq  %rdi # saving the base variable in %rdi (Pops 8 bytes, stack no longer aligned`)	
	addq $8 , %rsp # aligning the stack, because it was pushed 16 bytes and only popped 8

	# call factorial with the read parameter	
	call factorial # call pow subroutine with the %rdi parameter that was read above (returns result in %rax)

	cmpq $-1, %rax
	jne else_undefined
if_undefined:
	# the operation result is undefined
	movq $0 , %rax # no vector registers in use for printf
	movq $undefined , %rdi # first parameter: the undefined string
	call printf # call printf to print out undefined
	
	# epilogue
	movq %rbp, %rsp # clear local variables from stack
	popq %rbp # restore base pointer location
	jmp end	

else_undefined:
	# call printf to show result on screen
	movq %rax, %rsi # second parameter (the '%ld' in the format string) - the result from the pow function
	movq $0 , %rax # no vector registers in use for printf
	movq $output , %rdi # first parameter: the message string
	call printf # call printf to print message

	# epilogue
	movq %rbp, %rsp # clear local variables from stack
	popq %rbp # restore base pointer location

end: # this loads the program exit code and exits the program (end label does not serve a functional purpose here)
	movq $0 , %rdi
	call exit

# Subroutine that takes 2 parameters: base and exp and returns base to the power of exp.
pow:
	# prologue
	pushq %rbp # push the base pointer
	movq %rsp , %rbp # copy stack pointer value to base pointer
 
	# Passed arguments are: base in %rdi and exp in %rsi
	# Save %rsi value in %r9
	movq %rsi, %r9
		
	# Declare and initialize variables total to 1 in %r8 and i to 0 in %r10
	movq $1, %r8
	movq $0, %r10

# Execute loop until i (%rcx) is equal to exp (%rsi)
for:
	# total = total * base
	movq %rdi, %rax # move the %rdi (value of base variablie) value to %rax to be multiplied
	mulq %r8 # muliply the total (%r8) by base - result goes to %rax
	movq %rax, %r8 # move the multiplication result to %r8

	# increment i (i++)	
	incq %r10

	# jump back to loop if i is different from exp
	cmpq %r9, %r10	# compares i to exp
	jne for # jumps to label for if i != exp

	movq %r8, %rax # returns the variable total
	
	# epilogue
	movq %rbp, %rsp # clear local variables from stack
	popq %rbp # restore base pointer location
	ret # jumps back to main subroutine

# Subroutine that takes 1 parameter: n, and returns n factorial (n!)
factorial:
	# prologue
	pushq %rbp # push the base pointer
	movq %rsp , %rbp # copy stack pointer value to base pointer
	
	# If the number (%rdi) is 0, jump to case 0 which returns 1
	cmpq $0, %rdi
	je case_zero

	cmpq $0, %rdi
	jl case_negative

	# Passed arguments are: n in %rdi
	cmpq $1, %rdi # compares 1 to n
	jne else # if 1 != n jump to else
if: # If 1 == %rdi
	# return 1
	movq $1, %rax #
	jmp end_factorial
		
else: 
	# return n * factorial(n - 1)
	pushq %rdi # save n value on the stack (allocates 8 bytes on the stack)
	subq $8, %rsp # allocate 8 more bytes to keep stack aligned 
	dec %rdi # obtain n-1
	call factorial # places factorial result in %rax
	addq $8, %rsp # free 8 bytes from the stack that we previously allocated to keep stack aligned
	popq %r8 # get n from the stack
	mulq %r8 # multiplies factorial(n-1) (%rax) with n (%r8) and stores in %rax
		
end_factorial:
	# epilogue
	movq %rbp, %rsp # clear local variables from stack
	popq %rbp # restore base pointer location
	ret # jumps back to main subroutine

case_zero:
	movq $1, %rax # factorial returns 1
	
	#epilogue
	movq %rbp, %rsp
	popq %rbp

	ret #returns back in main

case_negative:
	movq $-1, %rax # factorial returns -1 (undefined)
	
	#epilogue
	movq %rbp, %rsp
	popq %rbp

	ret #returns back in main
	
