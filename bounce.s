.text
.global _start
_start:

.equ ADDR_Front_Buffer, 0xFF203020 // where i write a 1 to to show which buffer is going
.equ ADDR_Slider_Switches, 0xFF200040

 .equ VGA_Back_Buffer1, 0xC1000000  // where is want to start the first buffer at 
 .equ VGA_End_Back1, 0xC103C280

 .equ VGA_Back_Buffer2, 0xC2000000  // start second buffer at 
 .equ VGA_End_Back2, 0xC203C280
 

// colour values for the Pixel buffer
 .equ black, 0x0000
 .equ pink, 0xFDB9C8
 .equ blue,  0x001F
 .equ red,  0xF100
 .equ green,  0x07E0
 .equ yellow,  0xFFE0

 ldr r7, =0xc1012D2C
 ldr r8, =0xc2012D2C 
 mov r1, #2
 mov r0, #1024 // issues with 15 dont use 

 mainloop:
  bl c1rect
  ldr r5, =ADDR_Front_Buffer
  ldr r3, =VGA_Back_Buffer1
  str r3, [r5, #4] 	// set pointer location of back buffer1
  mov  r6, #1
  str r6, [r5]         

 swapcheck:
 ldr r3,[r5, #12]
 ands r3,r3, r6
 bne swapcheck

 bl c2rect
 ldr r3, =VGA_Back_Buffer2
 str r3, [r5, #4] 
 mov r4, r3      
 str r6, [r5]    

 swapcheck2:
 ldr r3, [r5, #12]   
 ands r3,r3, r6
 bne swapcheck2

 b mainloop


c1rect: 
 ldr  r2, =black 
 ldr  r3, =VGA_Back_Buffer1
 ldr  r4, =VGA_End_Back1

mov r9, #24 // length and width number 
mov r10, #0 // counter 

count1:
  strh r2, [r3], #2
  cmp  r3, r4
  ble count1

ldr r12,=0x0003FE 
And r12, r7, r12 // 0x0003FE binary for 0000000011 1111 1110 DEC 1022
mov r12, r12, LSR #1   // shift for just x values into r12 
ldr r13,=0x03FC00
And r13, r7, r13 // 11 1111 1100 0000 0000 and with this num 
mov r13, r13, LSR #10  /// shift for just y values 

cmp r12, #292
bgt rightwall
cmp r12, #0
ble leftwall
add r7, r7, r1
b compy 

leftwall: 
mov r1, #2
add r7, r7, r1
b compy

rightwall: 
mov r1, #(-2)
add r7, r7, r1
b compy

compy:
cmp r13, #240
bgt topwall
cmp r13, #24
ble bottomwall
add r7, r7, r0 // if nothing happens load with current register 
mov r3, r7 // move into reg for loop 
b lengthloop 

bottomwall: 
mov r0, #1024
add r7, r7, r0
mov r3, r7
b lengthloop

topwall: 
ldr r0,=(-0x000400) // 1024
add r7, r7, r0
mov r3, r7
b lengthloop

lengthloop: 
  ldr r2, =pink
  sub r3, r3, #25600 // resetting the loop by 25x1024 
  add r3, r3, #2
  strh r2, [r3]
  add r10, r10, #1
  mov r11, #0 // reset for each row 

heightloop: 
  ldr r2, =pink
  strh r2, [r3]
  add r3, r3, #1024 // incrememnt y by one 
  strh r2, [r3]
  add r11, r11, #1 // incrementn counter 
  cmp r11, r9 // jump back to height loop if right 
  ble heightloop
  cmp r10, r9 // go back to width loop if equals 25 
  ble lengthloop 
  bx lr

c2rect:
// Fill back buffer2 memory locations with the color green
 ldr r2, =black
 ldr r3, =VGA_Back_Buffer2
 ldr r4, =VGA_End_Back2

// counter to increment through each back buffer2 memory location until 256k locations have been filled with green Pixel value

 count2:
  strh r2, [r3], #2
  cmp  r3, r4
  ble count2

mov r10, #0

ldr r12,=0x0003FE
and r12, r8, r12 
mov r12, r12, LSR #1  
ldr r13,=0x03FC00
And r13, r7, r13 
mov r13, r13, LSR #10  

comparex: 
cmp r12, #292
bgt rightwall2
cmp r12, #0
ble leftwall2
add r8, r8, r1 
b comparey

leftwall2: 
mov r1, #2
add r8, r8, r1
b comparey

rightwall2:
mov r1, #(-2)
add r8, r8, r1
b comparey

comparey: 
cmp r13, #240
bgt topwall2
cmp r13, #24
ble bottomwall2
add r8, r8, r0 
mov r3, r8
b lengthloop2

bottomwall2: 
mov r0, #1024
add r8, r8, r0
mov r3, r8
b lengthloop2

topwall2:
ldr r0,=(-0x000400)
add r8, r8, r0
mov r3, r8
b lengthloop2

lengthloop2: 
  ldr r2, =pink
  sub r3, r3, #25600 
  add r3, r3, #2
  strh r2, [r3]
  add r10, r10, #1
  mov r11, #0 // reset for each row 

heightloop2: 
  ldr r2, =pink
  strh r2, [r3]
  add r3, r3, #1024
  strh r2, [r3]
  add r11, r11, #1 // incrementn counter 
  cmp r11, r9 // jump back to height loop if right 
  ble heightloop2
  cmp r10, r9 // go back to width loop if equals 25 
  ble lengthloop2 
  bx lr
