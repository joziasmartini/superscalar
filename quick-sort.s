# Estudantes: CAROLINE DE QUADROS PIAZZA - JOZIAS MARTINI DEQUI - MARCO ANTONIO BERNARDELI DA VEIGA

.data
unsorted_str: .string "Array desordenado: \n"
sorted_str:   .string "\nArray ordenado: \n"
fmt_int:      .string "%d "

# Vetor fixo na seção .data para substituir a entrada manual do usuário no gem5
input_data:   .word 42, 15, 8, 99, 23, 4, 16, 81, 3, 10

.text
.globl main

main:
    # Preservar o ra da main na pilha
    addi sp, sp, -4
    sw ra, 0(sp)

    # 1. Alocação Dinâmica usando malloc da libc
    li a0, 40      # 10 inteiros * 4 bytes
    call malloc
    mv s0, a0      # s0 = ponteiro base no heap (não mude s0 até o fim)

    # 2. Preenchimento do Array (Copiando do .data para o heap)
    la s1, input_data  # Endereço dos dados fonte
    li t0, 0           # i = 0
    li t1, 10          # tamanho = 10

read_loop:
    beq t0, t1, read_end
    
    # Calcula endereços
    slli t2, t0, 2     # offset = i * 4
    add t3, s1, t2     # endereço fonte (input_data + offset)
    add t4, s0, t2     # endereço destino (heap + offset)

    # Copia o valor
    lw t5, 0(t3)
    sw t5, 0(t4)

    addi t0, t0, 1
    j read_loop

read_end:
    # 3. Impressão do Array Original usando printf
    la a0, unsorted_str
    call printf

    mv a0, s0
    li a1, 10
    call print_array

    # 4. Chamada da Ordenação (Quick Sort)
    mv a0, s0      # Endereço do array
    li a1, 0       # low
    li a2, 9       # high
    call quick_sort

    # 5. Impressão do Array Ordenado
    la a0, sorted_str
    call printf

    mv a0, s0
    li a1, 10
    call print_array

    # Finaliza o programa restaurando a pilha e o ra
    lw ra, 0(sp)
    addi sp, sp, 4
    ret

# --- Funções Auxiliares ---

print_array:
    # Salvando registradores 's' e 'ra' porque chamaremos printf repetidamente
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s3, 8(sp)   # s3 vai assumir o papel de t0
    sw s4, 4(sp)   # s4 vai assumir o papel de t1
    sw s5, 0(sp)   # s5 vai assumir o papel de t2

    mv s3, a0      # s3 = Ponteiro
    mv s4, a1      # s4 = Tamanho
    li s5, 0       # s5 = i
print_loop:
    beq s5, s4, print_end
    
    slli t3, s5, 2
    add t3, s3, t3
    lw a1, 0(t3)   # a1 = Valor a ser impresso pelo printf

    la a0, fmt_int # a0 = String de formato "%d "
    call printf

    addi s5, s5, 1
    j print_loop
print_end:
    # Restaurando os registradores salvos
    lw s5, 0(sp)
    lw s4, 4(sp)
    lw s3, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16
    ret

quick_sort:
    # Aumentamos a pilha para salvar s0 (base do array) e o pivô p
    addi sp, sp, -20
    sw ra, 16(sp)
    sw s0, 12(sp)
    sw s1, 8(sp)
    sw s2, 4(sp)

    mv s0, a0      # Salva endereço base do array
    mv s1, a1      # low
    mv s2, a2      # high

    # Caso base: if (low >= high) return
    bge s1, s2, qs_end

    # Partição
    mv a0, s0
    mv a1, s1
    mv a2, s2
    call partition
    sw a0, 0(sp)   # SALVA O PIVÔ (p) NA PILHA

    # Recursão Esquerda: quick_sort(arr, low, p - 1)
    mv a0, s0
    mv a1, s1
    lw t0, 0(sp)
    addi a2, t0, -1
    call quick_sort

    # Recursão Direita: quick_sort(arr, p + 1, high)
    mv a0, s0
    lw t0, 0(sp)
    addi a1, t0, 1
    mv a2, s2
    call quick_sort

qs_end:
    lw ra, 16(sp)
    lw s0, 12(sp)
    lw s1, 8(sp)
    lw s2, 4(sp)
  
    addi sp, sp, 20
    ret

partition:
    # Usa registradores t pois é uma função folha (não chama outras)
    slli t0, a2, 2
    add t0, a0, t0
    lw t1, 0(t0)   # t1 = pivot (valor)
    addi t2, a1, -1 # t2 = i
    mv t3, a1      # t3 = j
part_loop:
    bge t3, a2, part_end
    slli t4, t3, 2
    add t4, a0, t4
  
    lw t5, 0(t4)   # t5 = arr[j]
    bge t5, t1, part_next
    addi t2, t2, 1
    slli t6, t2, 2
    add t6, a0, t6
    lw a3, 0(t6)   # Troca arr[i] e arr[j]
    sw t5, 0(t6)
    sw a3, 0(t4)
part_next:
    addi t3, t3, 1
    j part_loop
part_end:
    addi t2, t2, 1
    slli t4, t2, 2
    add t4, a0, t4
    
    lw t5, 0(t4)
    slli t6, a2, 2
    add t6, a0, t6
    lw t1, 0(t6)
    sw t1, 0(t4)
    sw t5, 0(t6)
    mv a0, t2      # Retorna o índice do pivô
    ret
