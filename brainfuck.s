    #%rcx = instruction pointer
    #%rsi = memory pointer

    .data

commands:   .fill 100,   8, 0
memory:     .fill 30000, 1, 0
syntax_error_message:   .asciz "Syntaxe invalide.\n"
out_of_bounds_message:  .asciz "Limite de la mémoire atteinte.\n"
position:   .asciz "Position: "
    
    .text
    .globl main
    
main:
    mov     $0, %rsi

pre_read:
    lea     position(%rip), %rax
    push    %rax
    call    print_string    
    push    %rsi
    call    print_word_dec
    push    $'\n'
    call    putchar
    push    $'$'
    call    putchar
    push    $' '
    call    putchar
    xor     %rcx, %rcx

read:       
    
    call    getchar
    cmp     $'\n', %rax
    je      pre_execute
    cmp     $'<', %rax
    je      w1    
    cmp     $'>', %rax
    je      w2
    cmp     $'+', %rax
    je      w3
    cmp     $'-', %rax
    je      w4
    cmp     $'.', %rax
    je      w5
    cmp     $',', %rax
    je      w6
    cmp     $'[', %rax
    je      w7
    cmp     $']', %rax
    je      w8
    cmp     $-1, %rax   #EOF, quit
    je      quit
    jmp     syntax_error

w1:
    lea     move_left, %rax
    mov     %rax, commands(,%rcx,8)
    inc     %rcx
    jmp     read
w2:
    lea     move_right, %rax
    mov     %rax, commands(,%rcx,8)
    inc     %rcx
    jmp     read
w3:
    lea     increment, %rax
    mov     %rax, commands(,%rcx,8)
    inc     %rcx
    jmp     read
w4:
    lea     decrement, %rax
    mov     %rax, commands(,%rcx,8)
    inc     %rcx
    jmp     read
w5:
    lea     output, %rax
    mov     %rax, commands(,%rcx,8)
    inc     %rcx
    jmp     read
w6:
    lea     input, %rax
    mov     %rax, commands(,%rcx,8)
    inc     %rcx
    jmp     read
w7:
    lea     while,  %rax
    mov     %rax, commands(,%rcx,8)
    inc     %rcx
    jmp     read
w8:
    lea     loop, %rax
    mov     %rax, commands(,%rcx,8)
    inc     %rcx
    jmp     read
    
move_left:
    cmp     $0, %rdx
    je      execute
    cmp     $0, %rsi #Si on est au début de la mémoire
    je      memory_out_of_bounds
    dec     %rsi
    jmp     execute

move_right:
    cmp     $0, %rdx
    je      execute
    cmp     $29999, %rsi  #Si on est a la fin de la mémoire
    je      memory_out_of_bounds
    inc     %rsi
    jmp     execute

increment:
    cmp     $0, %rdx
    je      execute
    mov     memory(%rsi), %rax
    inc     %rax
    mov     %rax, memory(%rsi)
    jmp     execute

decrement:
    cmp     $0, %rdx
    je      execute
    mov     memory(%rsi), %rax
    dec     %rax
    mov     %rax, memory(%rsi)
    jmp     execute
    
while:
    push    %rdx
    mov     memory(%rsi), %rdx
    push    %rcx
    jmp     execute
    
loop:   
    cmp     $0, %rdx
    je      exit_loop
    mov     memory(%rsi), %rax
    cmp     $0, %rax
    je      exit_loop
    pop     %rcx
    push    %rcx
    jmp     execute

exit_loop:
    add     $8, %rsp
    pop     %rdx
    jmp     execute
    
input:
    cmp     $0, %rdx
    je      execute
    call    getchar
    sub     $'0', %rax
    mov     %rax, memory(%rsi)
    jmp     execute
    
output:
    cmp     $0, %rdx
    je      execute
    mov     memory(%rsi), %rax
    push    %rax
    call    print_word_dec
    push    $'\n'
    call    putchar
    jmp     execute
    
    #exécution de la commande compilée
pre_execute:
    #la dernière commande exécuté par le repl
    #est de réinitialiser le compteur d'instruction et de lire une nouvelle commande
    lea     pre_read, %rax
    mov     %rax, commands(,%rcx,8)
    xor     %rcx, %rcx    

execute:
    mov     commands(,%rcx,8), %rax
    push    %rax
    inc     %rcx
    ret

syntax_error:
    lea     syntax_error_message(%rip), %rax
    push    %rax
    call    print_string
    jmp     execute

memory_out_of_bounds:
    lea     out_of_bounds_message(%rip), %rax
    push    %rax
    call    print_string
    jmp     execute

quit:
    #

        
