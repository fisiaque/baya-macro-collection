#Requires AutoHotkey v2.0

FileReadLine(file, row) {
    text := FileRead(file)
    return StrSplit(Text, "`n", "`r")[row]
}