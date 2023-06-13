format PE GUI
entry start

include 'win32a.inc'

section '.data' data readable writeable
  className db 'FASMWINCLASS',0
  windowName db 'My Window',0
  wc WNDCLASSEX
  msg MSG
  ps PAINTSTRUCT
  whitePen dd ?

section '.text' code readable executable
start:
    ; Initialize WNDCLASSEX structure
    mov [wc.cbSize], sizeof.WNDCLASSEX
    mov [wc.style], CS_HREDRAW + CS_VREDRAW
    mov [wc.lpfnWndProc], WndProc
    mov [wc.hInstance], 400000h
    mov [wc.lpszClassName], className
    mov [wc.hbrBackground], COLOR_WINDOW+19  ; Make the background black

    ; RegisterClassEx
    invoke RegisterClassEx, wc

    ; CreateWindowEx
    invoke CreateWindowEx, 0, className, windowName, WS_OVERLAPPEDWINDOW, 100, 100, 600, 400, NULL, NULL, 400000h, NULL
    test eax, eax
    jz exit

    ; ShowWindow
    invoke ShowWindow, eax, SW_SHOWDEFAULT

    ; Message loop
msg_loop:
    invoke GetMessage, msg, NULL, 0, 0
    cmp eax, 0
    je exit
    invoke TranslateMessage, msg
    invoke DispatchMessage, msg
    jmp msg_loop

exit:
    invoke ExitProcess, 0

proc WndProc uses ebx esi edi, hwnd, umsg, wparam, lparam
    cmp [umsg], WM_DESTROY
    je .wmdestroy
    cmp [umsg], WM_PAINT
    je .wmpaint
    jmp .defwndproc

  .wmpaint:
    invoke BeginPaint, [hwnd], ps
    mov ebx, eax

    ; Create a white pen
    invoke CreatePen, PS_SOLID, 1, 0xFFFFFF
    mov [whitePen], eax

    ; Select the white pen into the DC
    invoke SelectObject, ebx, eax
    mov esi, eax

    ; Draw rectangle
    invoke Rectangle, ebx, 50, 50, 70, 70

    ; Clean up: Select the old pen back into the DC and delete the white pen
    invoke SelectObject, ebx, esi
    invoke DeleteObject, [whitePen]

    invoke EndPaint, [hwnd], ps

    xor eax, eax
    ret

  .defwndproc:
    invoke DefWindowProc,[hwnd],[umsg],[wparam],[lparam]
    ret

  .wmdestroy:
    invoke PostQuitMessage, 0
    xor eax, eax
    ret
endp

section '.idata' import data readable writeable
  library kernel, 'KERNEL32.DLL',\
          user, 'USER32.DLL',\
          gdi, 'GDI32.DLL'

  import kernel,\
         ExitProcess, 'ExitProcess'

  import user,\
         RegisterClassEx, 'RegisterClassExA',\
         CreateWindowEx, 'CreateWindowExA',\
         ShowWindow, 'ShowWindow',\
         GetMessage, 'GetMessageA',\
         TranslateMessage, 'TranslateMessage',\
         DispatchMessage, 'DispatchMessageA',\
         DefWindowProc, 'DefWindowProcA',\
         PostQuitMessage, 'PostQuitMessage',\
         BeginPaint, 'BeginPaint',\
         EndPaint, 'EndPaint'

  import gdi,\
         CreatePen, 'CreatePen',\
         DeleteObject, 'DeleteObject',\
         SelectObject, 'SelectObject',\
         Rectangle, 'Rectangle'
