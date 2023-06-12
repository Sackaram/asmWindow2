format PE GUI
entry start

include 'win32a.inc'

section '.data' data readable writeable
  className db 'FASMWINCLASS',0
  windowName db 'My Window',0
  wc WNDCLASSEX
  msg MSG

section '.text' code readable executable
start:
  ; Initialize WNDCLASSEX structure
  mov [wc.cbSize], sizeof.WNDCLASSEX
  mov [wc.style], CS_HREDRAW + CS_VREDRAW
  mov [wc.lpfnWndProc], WndProc
  mov [wc.hInstance], 400000h
  mov [wc.lpszClassName], className
  mov [wc.hbrBackground], COLOR_WINDOW+1

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

proc WndProc hwnd, umsg, wparam, lparam
  cmp [umsg], WM_DESTROY
  je .wmdestroy

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
          user, 'USER32.DLL'

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
         PostQuitMessage, 'PostQuitMessage'
