import struct
import win32con
import win32gui
import struct, array


int_buffer = array.array("L", [0])
char_buffer = array.array('b', b"do manage open")
int_buffer_address = int_buffer.buffer_info()[0]

# Add () to buffer_info to call it.
char_buffer_address, char_buffer_size = char_buffer.buffer_info()

# Need P  type for the addresses.
copy_struct = struct.pack("PLP",int_buffer_address,char_buffer_size, char_buffer_address)

hwnd = win32gui.FindWindow(None, "ZhornSoftwareStickiesMain")
win32gui.SendMessage(19172, win32con.WM_COPYDATA, None, copy_struct) #657652 #1509624