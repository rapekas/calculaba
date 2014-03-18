var WshShell = WScript.CreateObject("WScript.Shell");
while (true)
{
WshShell.SendKeys("{ScrollLock}");
WshShell.SendKeys("{ScrollLock}");
WScript.Sleep(240000);
}