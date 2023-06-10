section .data
    ClassName db "WindowClass", 0
    AppName db "My Window", 0

section .bss
    wc resb 48
    msg resb 28
    hwnd resd 1

section .text
    global _start
    extern _GetModuleHandleA@4, _ExitProcess@4
    extern _RegisterClassExA@4, _CreateWindowExA@48
    extern _ShowWindow@8, _GetMessageA@16
    extern _TranslateMessage@4, _DispatchMessageA@4

_start:
    ; Initialize WNDCLASSEX structure
    mov dword [wc], 48 ; size of WNDCLASSEX
    mov dword [wc+4], 3 ; CS_HREDRAW | CS_VREDRAW
    mov dword [wc+8], WndProc
    mov dword [wc+12], 0 ; cbClsExtra
    mov dword [wc+16], 0 ; cbWndExtra
    push 0 ; NULL
    call _GetModuleHandleA@4
    mov dword [wc+20], eax ; hInstance
    mov dword [wc+24], 0 ; hIcon
    mov dword [wc+28], 0 ; hCursor
    mov dword [wc+32], 5 ; COLOR_WINDOW
    mov dword [wc+36], 0 ; lpszMenuName
    mov dword [wc+40], ClassName
    mov dword [wc+44], 0 ; hIconSm
    push wc
    call _RegisterClassExA@4

    ; Create Window
    push 0 ; lParam
    push 0 ; hMenu
    push 0 ; hWndParent
    push 300 ; height
    push 300 ; width
    push 0 ; y
    push 0 ; x
    push 0x80000000 ; WS_VISIBLE
    push AppName
    push ClassName
    push 0 ; dwExStyle
    call _GetModuleHandleA@4
    push eax ; hInstance
    call _CreateWindowExA@48
    mov [hwnd], eax

    ; Show Window
    push 1 ; nCmdShow
    push eax ; hWnd
    call _ShowWindow@8

    ; Message Loop
message_loop:
    push 0 ; filterMax
    push 0 ; filterMin
    push 0 ; hWnd
    push msg
    call _GetMessageA@16
    test eax, eax
    jz end_program
    push msg
    call _TranslateMessage@4
    push msg
    call _DispatchMessageA@4
    jmp message_loop

end_program:
    push 0
    call _ExitProcess@4

; Window Procedure
WndProc:
    ret 16

