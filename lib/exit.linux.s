.global _exit
.align 2

.text
_exit:
	mov x8, #93
	svc #0
