# Email my IP

When running a headless test server on a DHCP network, we want
the server to report its IP address so we'll know how to contact
it.  Follow these instructions so the server will email its IP.

## Steps
1. Install ssmtp and mailutils.
2. Set up the mail sending backend (I use Hostinger).
3. Install the email_my_ip.sh script.
4. Install the email_my_ip.service file on /etc/systemd/system.
5. Enable email_my_ip.service.

```
systemctl enable email_my_ip.service
systemctl start email_my_ip.service
```
