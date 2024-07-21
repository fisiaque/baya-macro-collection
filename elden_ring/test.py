import win32api
import win32con


win32api.SendMessage(1311544, win32con.WM_COPYDATA, win32con.VK_SHIFT, 0)
