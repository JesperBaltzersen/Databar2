################################################################################
#
# File  : window.s
# Author: Laust Brock-Nannestad (laub@dtu.dk)
# Date  : January, 2014
# Brief : Source code skeleton for assembly assignment.
#
# Copyright 2013-14 Laust Brock-Nannestad, et. al., All rights reserved.
#
# You are allowed to change this file for the purpose of solving
# exercises in the 02333 course at DTU. You are not allowed to 
# change this message or disclose this file to anyone except for
# the course staff in the 02333 course at DTU. Disclosing the contents
# to fellow course mates or redistributing contents is a direct violation.
#
# You need to implement two two sub-routines as indicated below. Read the
# assignment instructions for more information.
#

.global _init

# We come here from multiboot2.s
_init:
 call clearscreen

 # As a test, print a few letters manually by using drawchar
 mov $0, %eax               # X position
 mov $0, %ebx               # Y position
 mov $'H', %cl              # Character
 mov $7, %ch                # Color
 call drawchar              # Sub-routine to draw

 mov $1, %eax
 mov $1, %ebx
 mov $'W', %cl
 mov $9, %ch
 call drawchar


 # Draw the windows
 mov num_windows, %esi      # Load number of windows to draw
 mov $windowdata, %edi      # Load pointer to window data structures
drloop: 
 mov %edi, %eax
 call drawwindow
 add datasize, %edi         # Increment pointer to next data structure
 dec %esi                   # Decrease number of windows to draw
 jnz drloop                 # Repeat until done

# We're done, loop forever
halt:
 jmp halt

################################################################################
# ClearScreen
# Clears the screen.
#
# Text screen is memory mapped at 0xb8000
# Each character is described by two bytes, one for the color and one for the
# character itself.
#
# We perform 32 bit writes so we clear two characters in one write. Hence, there
# are only 1000 iterations of the loop.
clearscreen:
 push %esi              # Preserve caller's esi

 xor %eax, %eax         # Clear eax
 mov $0xb8000, %esi     # Load base screen address into esi
 mov %esi, %ebx         # ebx = esi
 add $4000, %ebx        # ebx += 4000. Now it points to the
                        # end of the screen memory
loop:
 mov %eax, (%esi)       # *esi = eax
 add $4, %esi           # esi += 4
 cmp %esi, %ebx         
 jne loop               # if %esi != %ebx

 pop %esi               # Restore caller's esi
 ret

################################################################################
# DrawChar
# Draws character %cl (byte 0 of %ecx) and attribute %ch (byte 1 of %ecx)
# at position %eax, %ebx
drawchar:
 push %esi              # We must preserve esi
 # calculate proper offset from base of video memory
 mov $0xb8000, %esi     # esi = 0xb8000
 shl $1, %eax           # eax <<= 1 (2 bytes per character)
 add %eax, %esi
 mov %ebx, %eax
 # Convert y to number of rows
 mov scrwidth, %ebx     # ebx = 80 (width of line)
 shl $1, %ebx           # ebx <<= 1 (adjusted for 2 bytes per char)
 mul %ebx               # eax = eax * ebx
 add %eax, %esi         # esi is now base+xoffset*2+yoffset*160
 movw %cx, (%esi)       # *esi = cx

 pop %esi               # Restore caller's esi before returning
 ret

################################################################################
# DrawLine
# Draws the line given by coordinates (%eax, %ebx) direction %ecx and
# length %edx.
#
# Direction: 0 = draw leftwards (x increasing), 1 = downwards (y increasing)
#
# Decoration and color are passed on the stack.
#
# ADD YOUR IMPLEMENTATION HERE
drawline:
 ret

################################################################################
# ClearRect
# Clears a rectangular area of the screen.
#
# Receives x,y,xsize,ysize in %eax to %edx.
#
# ADD YOUR IMPLEMENTATION HERE
clearrect:
 ret

################################################################################
# DrawWindow
#
# Draws an entire window by drawing the four sides as separate lines
# %eax = pointer to window data structure
drawwindow:
 push %esi              # Preserve esi
 mov %eax, %esi

 mov (%esi), %eax       # eax = *esi     (x-pos)
 mov 4(%esi), %ebx      # ebx = *(esi+4) (y-pos) NB: byte addressing
 mov 8(%esi), %ecx      # ecx = *(esi+8) (x-size)
 mov 12(%esi), %edx     # edx = *(esi+12) (y-size)
 call clearrect

 xor %eax, %eax         # Clear eax
 movb 16(%esi), %al     # Load Character
 movb 17(%esi), %ah     # Load Color
 push %eax              # Decoration is passed on stack to drawline

 # Set up parameters for top side
 mov (%esi), %eax       # x-pos
 mov 4(%esi), %ebx      # y-pos
 mov $0, %ecx           # direction
 mov 8(%esi), %edx      # x-size
 call drawline

 # left side
 mov (%esi), %eax       # x-pos
 mov 4(%esi), %ebx      # y-pos
 mov $1, %ecx           # direction
 mov 12(%esi), %edx     # y-size
 call drawline

 # bottom side
 mov (%esi), %eax       # x-pos
 mov 4(%esi), %ebx      # y-pos
 add 12(%esi), %ebx
 sub $1, %ebx
 mov $0, %ecx           # direction
 mov 8(%esi), %edx      # x-size
 call drawline

 # right side
 mov (%esi), %eax       # x-pos
 add 8(%esi), %eax
 sub $1, %eax
 mov 4(%esi), %ebx      # y-pos
 mov $1, %ecx           # direction
 mov 12(%esi), %edx     # y-size
 call drawline

 add $4, %esp           # Remove the decoration argument again
 pop %esi               # Restore %esi
 ret
    
 .align 4

################################################################################
# Data definitions below

scrwidth:
 .long 80               # Width of display in characters
scrheight:
 .long 25               # Height of display, in lines
    
num_windows:            # Number of windows to draw
 .long 5
datasize:               # Size of the data structure for each window
 .long 5*4
    
# These define the windows to be drawn
windowdata:
 .long 7            # x-pos
 .long 5            # y-pos
 .long 48           # x-size
 .long 15           # y-size
 .byte '*'          # decoration
 .byte 5            # color
 .byte 0            # padding
 .byte 0            # padding

 .long 2            # x-pos
 .long 2            # y-pos
 .long 10           # x-size
 .long 11           # y-size
 .byte '+'          # decoration
 .byte 7            # color
 .byte 0            # padding
 .byte 0            # padding

 .long 35           # x-pos
 .long 2            # y-pos
 .long 8            # x-size
 .long 10           # y-size
 .byte '#'          # decoration
 .byte 10           # color
 .byte 0            # padding
 .byte 0            # padding

 .long 15           # x-pos
 .long 15           # y-pos
 .long 15           # x-size
 .long  9           # y-size
 .byte '*'          # decoration
 .byte 10           # color
 .byte 0            # padding
 .byte 0            # padding

 .long 40           # x-pos
 .long 10           # y-pos
 .long 65           # x-size
 .long 14           # y-size
 .byte '@'          # decoration
 .byte 15           # color
 .byte 0            # padding
 .byte 0            # padding

################################################################################
# The END                                                                      #
################################################################################
