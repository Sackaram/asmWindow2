section .data
    ClassName db 'MyWindowClass',0
    WindowName db 'MyWindow',0

    ; Define constants
    WS_OVERLAPPEDWINDOW equ 0CF0000h
    WS_EX_OVERLAPPEDWINDOW equ 300h
    COLOR_WINDOW equ 5h
    CS_VREDRAW equ 1h
    CS_HREDRAW equ 2h

section .text
    global _start

    extern _RegisterClassExA@4
    extern _CreateWindowExA@48
    extern _ShowWindow@8
    extern _GetMessageA@16
    extern _TranslateMessage@4
    extern _DispatchMessageA@4

    _start:

    ; Define a window class
    push 0                    ; cbSize
    push CS_VREDRAW | CS_HREDRAW ; style
    call WndProc              ; lpfnWndProc
    add esp, 4
    push 0                    ; cbClsExtra
    push 0                    ; cbWndExtra
    push 0                    ; hInstance
    push COLOR_WINDOW + 1     ; hbrBackground
    push 0                    ; lpszMenuName
    push ClassName            ; lpszClassName
    call [_RegisterClassExA@4]

    ; Create a window
    push 0                    ; lParam
    push 0                    ; hMenu
    push 0                    ; hWndParent
    push 300                  ; Height
    push 400                  ; Width
    push 100                  ; Y
    push 100                  ; X
    push WS_OVERLAPPEDWINDOW  ; Style
    push ClassName            ; lpClassName
    push WindowName           ; lpWindowName
    push WS_EX_OVERLAPPEDWINDOW ; dwExStyle
    call [_CreateWindowExA@48]

    ; Display the window
    push 0                    ; uCmdShow
    call [_ShowWindow@8]

    ; Run the message loop
    MessageLoop:
    sub esp, 16               ; Allocate space for a MSG structure
    push esp                  ; lpMsg
    call [_GetMessageA@16]

    push esp                  ; lpMsg
    call [_TranslateMessage@4]

    push esp                  ; lpMsg
    call [_DispatchMessageA@4]
    jmp MessageLoop

    WndProc:
    
