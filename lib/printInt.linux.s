.global _printInt
.align 2

.text
_printInt:
	// allocate 32 bytes
	sub sp, sp, #32

	// string stored on stack, but in reverse
	add x6, sp, #32	// x6 - finished string
	mov x4, #10		// x4 - base
	mov x5, #0		// x5 - str length

	mov x2, x0		// x2 - original number

.LprintInt_loop:
	udiv x7, x2, x4	// x7 - quotient
	mov x3, x7		// x3 - next digit

	// x mod 10
	mul x3, x3, x4
	sub x3, x2, x3

	// convert into ascii number
	add x3, x3, #'0'

	mov x2, x7

	// copy number onto stack, in reverse
	strb w3, [x6, #-1]!

	// increment number of chars
	add x5, x5, #1
	cbz x2, .LprintInt_return
	b .LprintInt_loop

.LprintInt_return:
	// add newline
	mov w3, #'\n'
	strb w3, [x6, #-1]!
	add x5, x5, #1

	// print stack
	mov x0, #1		// 1 = StdOut
	mov x1, x6
	mov x2, x5
	mov x8, #64
	svc #0

	// free
	add sp, sp, #32

	ret
