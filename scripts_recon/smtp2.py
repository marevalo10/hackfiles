import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email import encoders

server = 'mail.internal.bupa.com.au'
port = 25
receiver_email = ['miguel.arevalo@bupa.com.au']
sender_email = 'adelaide_ups@bupa.com.au'
#replyto = 'miguel.arevalo@bupa.com.au'
subject = "UPS Problem"
#attachedfile = "uploadfiles.xlsx"
file="uploadfiles.zip"
#If authentication is required
authenticate = False
username="miguel"
password="password123"
to = ",".join(recipients)
charset = "utf-8"
body = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" '
body +='"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><html xmlns="http://www.w3.org/1999/xhtml">'
body +='<body style="font-size:12px;font-family:Verdana"><p>Adelaide UPS issue. Please find the detailed report in the attached file</p>'
body += "</body></html>"


message = MIMEMultipart()

message["From"] = sender_email
message['To'] = receiver_email
message['Subject'] = subject

plain_text = MIMEText(body, _subtype='plain', _charset='UTF-8')
message.attach(plain_text)
msg = message.as_string()

attachment = open(file,'rb')
obj = MIMEBase('application','octet-stream')
obj.set_payload((attachment).read())
encoders.encode_base64(obj)
obj.add_header('Content-Disposition',"attachment; filename= "+file)

message.attach(obj)
my_message = message.
my_message = message.as_string()
email_session = smtplib.SMTP(server,port)
if authenticate:
    email_session.starttls()
    email_session.login(username,password)

email_session.sendmail(sender_email,receiver_email,my_message)
email_session.quit()
print("YOUR MAIL HAS BEEN SENT SUCCESSFULLY")