# Post my IP address to Mastodon

Since my server is running headless and yet its network is set
by DHCP, I need a way to get the IP address.  A quick and easy
way is to post it to a Mastodon instance.

## Instructions
Set up the script in an accessible location. Make sure it is 
executable.

Set up post_my_ip.service in /etc/systemd/system.  Check the
contents for correct location of the script.

Enable the service.

```
sudo systemctl enable post_my_ip.service
sudo systemctl start post_my_ip.service
sudo systemctl status post_my_ip.service
```

## Security and privacy
Since the IP address will likely be an internal one, there
should be no major security issue. Besides, who uses Mastodon?
