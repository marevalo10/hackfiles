
#FROM COMMAND LINE:
"""
telnet mail.internal.bupa.com.au 25
HELO internal.bupa.com.au
MAIL FROM: Sara.Lelliott@bupa.com.au
RCPT TO: miguel.arevalo@bupa.com.au
DATA
SUBJECT: Test message
Hello,
this is a TEST message, 
please don't reply.
Thank you

.

QUIT
"""
#USING PYTHON - Working but needs to be reviewed
#!/usr/bin/python3
##!/usr/bin/env python3
from os.path import basename
from smtplib import SMTP
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email.mime.multipart import MIMEMultipart
from email.header import Header
from email.utils import parseaddr, formataddr
from base64 import encodebytes

server = 'mail.internal.bupa.com.au'
recipients = ['miguel.arevalo@bupa.com.au']
sender = 'adelaide_ups@bupa.com.au'
sender = "Sara.Lelliott@bupa.com.au"
replyto = 'miguel.arevalo@bupa.com.au'
subject = "UPS Problem"
#attachedfile = "uploadfiles.xlsx"
zipfiles=["uploadfiles.zip"]
#If authentication is required
username=False
password="password123"
to = ",".join(recipients)
charset = "utf-8"
body = 'Adelaide UPS issue. Please find the detailed report in the attached file'
try:
    body.encode(charset)
except UnicodeEncodeError:
    print("Could not encode " + body + " as " + charset + ".")
    exit

# Split real name (which is optional) and email address parts
sender_name, sender_addr = parseaddr(sender)
replyto_name, replyto_addr = parseaddr(replyto)

sender_name = str(Header(sender_name, charset))
replyto_name = str(Header(replyto_name, charset))

# Create the message ('plain' stands for Content-Type: text/plain)
try:
    msgtext = MIMEText(body.encode(charset), 'plain', charset)
except TypeError:
    print("MIMEText fail")
    exit

msg = MIMEMultipart()

msg['From'] = formataddr((sender_name, sender_addr))
msg['To'] = to #formataddr((recipient_name, recipient_addr))
msg['Reply-to'] = formataddr((replyto_name, replyto_addr))
msg['Subject'] = Header(subject, charset)

msg.attach(msgtext)

for zipfile in zipfiles:
    part = MIMEBase('application', "zip")
    b = open(zipfile, "rb").read()
    # Convert from bytes to a base64-encoded ascii string
    bs = encodebytes(b).decode()
    # Add the ascii-string to the payload
    part.set_payload(bs)
    # Tell the e-mail client that we're using base 64
    part.add_header('Content-Transfer-Encoding', 'base64')
    part.add_header('Content-Disposition', 'attachment; filename="%s"' %
                    basename(zipfile))
    msg.attach(part)

s = SMTP()
try:
    s.connect(server)
except:
    print("Could not connect to smtp server: " + server)
    exit

if username:
    s.login(username, password)

print("Sending the e-mail")
s.sendmail(sender, recipients, msg.as_string())
s.quit()

