import array, struct, win32con, win32gui
import ctypes 
import sys

def Mbox(text, title, style):
    return ctypes.windll.user32.MessageBoxW(0, text, title, style)

Mbox(sys.argv[1], "Arguments", 1)

def copy_data(hwnd, message, dwData = 0):
    buffer = array.array('u', message + '\x00')
    buffer_address, buffer_length = buffer.buffer_info()

    copy_struct = struct.pack('PLP', dwData, buffer_length * buffer.itemsize, buffer_address)

    return win32gui.SendMessage(hwnd, win32con.WM_COPYDATA, None, copy_struct)

hwnd = win32gui.FindWindow(None, 'ZhornSoftwareStickiesMain')
copy_data(sys.argv[1], 'Hello 👍')