.global _start
.align 2

.data
values:
.quad 1, 2, 3, 4, 5, 6, 7, 8, 9, 10

.text
_start:
	adrp x4, values
	add x4, x4, :lo12:values

	mov x0, #10

	bl .Lsum

	bl _printInt

	adrp x4, values
	add x4, x4, :lo12:values

	mov x0, #10

	bl .Lmul

	bl _printInt

	mov x0, #0
	bl _exit

.Lsum:
	lsl x3, x0, #3	// x3 - stack offset
	sub x3, x3, #8
	add x4, x4, x3

	mov x2, x0		// x2 - number of values
	mov x0, #0

.Lsum_loop:
	cbz x2, .Lsum_return

	ldr x1, [x4], #-8
	add x0, x0, x1
	sub x2, x2, #1
	b .Lsum_loop

.Lsum_return:
	ret

.Lmul:
	lsl x3, x0, #3
	sub x3, x3, #8
	add x4, x4, x3

	mov x2, x0		// x2 - number of values
	mov x0, #1

.Lmul_loop:
	cbz x2, .Lmul_return

	ldr x1, [x4], #-8
	mul x0, x0, x1
	sub x2, x2, #1
	b .Lmul_loop

.Lmul_return:
	ret
