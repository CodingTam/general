import os
import subprocess
import tempfile

# === CONFIG ===
sender = "your@email.com"
recipient = "recipient@example.com"
subject = "📊 Monthly Report Attached"
attachment_paths = ["/path/to/file1.pdf", "/path/to/file2.xlsx"]

# === Step 1: Zip attachments ===
zip_path = "/tmp/attachments.zip"
os.system(f"zip -j {zip_path} {' '.join(attachment_paths)}")

# === Step 2: Create HTML body with a table ===
html_body = """
<html>
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
</html>
"""

# === Step 3: Write HTML to a temp file ===
with tempfile.NamedTemporaryFile(delete=False, mode="w", suffix=".html") as tmp_body_file:
    tmp_body_file.write(html_body)
    body_file_path = tmp_body_file.name

# === Step 4: Send using mailx with MIME and attachment ===
# Use the `-a` option to attach files and `-s` for subject
# `-a` works on modern mailx (Heirloom or BSD-compatible)
command = f"""mailx -a {zip_path} -s "{subject}" -r "{sender}" -a "Content-Type: text/html" {recipient} < {body_file_path}"""

result = subprocess.run(command, shell=True)

# === Cleanup ===
os.remove(zip_path)
os.remove(body_file_path)

if result.returncode == 0:
    print("✅ Email sent successfully with mailx.")
else:
    print("❌ Failed to send email.")
