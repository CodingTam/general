import base64
import os
import subprocess
from email.utils import formatdate

# === CONFIG ===
sender = "your@email.com"
recipient = "recipient@example.com"
subject = "📊 Monthly Report Attached"
attachment_paths = ["/path/to/file1.pdf", "/path/to/file2.xlsx"]
zip_file = "/tmp/attachments.zip"
encoded_file = "/tmp/encoded_attachment.txt"

# === ZIP FILES ===
os.system(f"zip -j {zip_file} {' '.join(attachment_paths)}")

# === BASE64 ENCODE ===
with open(zip_file, "rb") as f_in, open(encoded_file, "w") as f_out:
    base64.encode(f_in, f_out)

# === MIME BOUNDARY ===
boundary = "MYBOUNDARY123"

# === HTML BODY WITH TABLE ===
html_body = f"""<html>
  <body>
    <h2 style='color:blue;'>Hello,</h2>
    <p>Please find the attached report for this month. Below is a summary:</p>
    <table border="1" cellpadding="6" cellspacing="0" style="border-collapse: collapse; font-family: Arial; font-size: 14px;">
      <tr style="background-color: #f2f2f2;"><th align="left">Date</th><td>July 01, 2022</td></tr>
      <tr><th align="left">Request Type</th><td>Data Extract</td></tr>
      <tr><th align="left">Total Records</th><td>0</td></tr>
    </table>
    <br><p>Regards,<br><b>Your Name</b></p>
  </body>
</html>"""

# === BUILD RAW EMAIL ===
with open(encoded_file, "r") as f:
    encoded_data = f.read()

email_content = f"""From: {sender}
To: {recipient}
Subject: {subject}
Date: {formatdate(localtime=True)}
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="{boundary}"

--{boundary}
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: 7bit

{html_body}

--{boundary}
Content-Type: application/zip; name="attachments.zip"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="attachments.zip"

{encoded_data}
--{boundary}--
"""

# === SEND MAIL USING sendmail ===
process = subprocess.Popen(["/usr/sbin/sendmail", "-t", "-oi"], stdin=subprocess.PIPE)
process.communicate(email_content.encode("utf-8"))

print("✅ Email sent successfully.")
