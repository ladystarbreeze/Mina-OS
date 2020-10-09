include "common/hardware.inc"
include "syscalls.asm"

; Addresses of important vectors:
; exception vector (Every fault event, including SVCalls, reset, etc, goes through this vector)
; depending on the event type, the exception vector jumps to one of these vectors:

; supervisor_call_handler: 300h
; boot_sequence: 1000h

section "exception vector" [0h]

.handleException:

    // Load FAULT into r14
    mfrc r14
    andi r14, r14, #F00h
    lsr r14, r14, #8

    cmpi/eq r14, FAULT_SVCALL // If FAULT == 14, call the SVCALL handler
    ct supervisor_call_handler

    cmpi/eq r14, FAULT_RESET
    bt boot_sequence // If FAULT == 15 (state of FAULT on boot), jump to the reset sequence

    stop // If FAULT is none of these values, this means we've stumbled upon an exception I haven't implemented. If so, STOP.


; POST code
section "boot sequence" [1000h]

boot_sequence:
    mov r1, #0
    mov r2, #0
    mov r15, #10007FFFh ; init the SP. TODO: Make this depend on the amount of RAM slotted

.POST:
    svcall get_RAM_amount_KB
    cmp/lo r0, #32 ; Check if system has less than 32 KiB of RAM. If so, crash
    bt not_enough_ram
    stop ; TODO: Add more tests

.greet_user:
    mov r0, .hello_message    
    svcall print_string

.not_enough_ram:
    mov r0, .not_enough_ram_message
    svcall fatal_error

.hello_message:
    db "This is sir Michel Rodrique, speaking to you from the white house.\nI'll shit in your face\n", 0

.not_enough_ram_message:
    db "Bruh you don't even have 32KB of RAM installed"