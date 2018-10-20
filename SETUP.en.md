## Installlation

### Install needed pkgs
`opkg update`

`opkg install tor tor-geoip ipset`

### Add repository
`echo -e -n 'untrusted comment: OpenWRT usign key of unlocker repo\nRWSAkINO7cGce05420qPyQYWqp9zMSCMflH2CF+kth6s0EnJOS6WLnd+\n' > /tmp/unlocker-repo.pub && opkg-key add /tmp/unlocker-repo.pub`

`! grep -q 'unlocker_repo' /etc/opkg/customfeeds.conf && echo 'src/gz unlocker_repo http://repo.unlocker.xyz' >> /etc/opkg/customfeeds.conf`

### Install Unlocker
`opkg update`

`opkg install luci-app-unlocker`

## Example configuration with Tor as proxy

- Check "Enable Unlocker" checkbox
- Select appropriate proxy mode (Tor in our case)
- Select needed ip-lists and press "save and apply"
![image](https://gitlab.com/Nooblord/luci-app-unlocker/raw/master/screenshots/setup1.en.png)
- Go to  "Tor Configuration" tab and edit torrc according to example below and save form or just press "Make me Tor Config" button, after that ***restart Tor service*** with "Restart Tor" button
![image](https://gitlab.com/Nooblord/luci-app-unlocker/raw/master/screenshots/setup2.en.png)
- Press "save and apply", done!
- Check if plugin is working correctly and if not - check logs

## Known possible problems

- Unlocker works and there are no errors in log, but sites are still being blocked by ISP
It is possible that your provider tampers with DNS requests, in this case you need to install DNS-over-TLS or just try to change upstream DNS to 1.1.1.1 or 8.8.8.8.