#Requires AutoHotkey v2.0 
#SingleInstance Force

bot := Object()
author := Object()
info := Object()
webhook := Object()

bot.Username := "Baya's Macro 🖱️⌨️"
bot.Avatar_URL := "https://i.imgur.com/rTHyKfI.png"

author.Name := ""
author.URL := ""
author.Icon_URL := "https://i.imgur.com/xOSKPKG.png"

info.UserId := 400783672980144128
info.Description := "Description Here!"
info.URL := "https://www.roblox.com/games/17450551531"
info.Color := 16711680
info.Thumbnail := "https://i.imgur.com/Pj2qqnA.gif"
info.Image := ""

webhook.URL := "https://discord.com/api/webhooks/1254967330321076358/GD1IuDi3aEZQuTvuUkwWbvcfzfq1Qx3LrLM95DDjKUQf9QHwBoLX05hVri9JQfOO0Aiq"
webhook.Method := "POST"
webhook.Body := '{"username": "' bot.Username '", "avatar_url": "' bot.Avatar_URL '", "content": "<@' info.UserId '>", "embeds": [{"author": {"name": "' author.Name '", "url": "' author.URL '", "icon_url": "' author.Icon_URL '"}, "title": "Gym League", "description": "(' info.Description ')", "url": "' info.URL '", "color": ' info.Color ', "thumbnail": {"url": "' info.Thumbnail '"}, "image": {"url": "' info.Image '"}}]}'


WHR := ComObject("WinHttp.WinHttpRequest.5.1")
WHR.Open(webhook.Method, webhook.URL, true)
WHR.SetRequestHeader("Content-Type", "application/json")
WHR.Send(webhook.Body)
; Using 'true' above and the call below allows the script to remain responsive.
WHR.WaitForResponse()
ResponseText := WHR.ResponseText
MsgBox ResponseText