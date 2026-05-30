.global _exit
.align 2

.text

_exit:
	mov x16, #1
	svc #0
