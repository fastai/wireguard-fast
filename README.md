# wireguard-fast

> Simplified installation of a [WireGuard](https://www.wireguard.com/) server for Ubuntu (tested on Ubuntu 20.04; should work on 18.04 as well

*NB: If you're not comfortable using a terminal, you might prefer to use [tailscale](https://tailscale.com/) instead of wireguard-fast. tailscale provides similar functionality through a GUI, and doesn't require setting up a server. The downsides of tailscale are that it costs $10/person/month if you want more than one person using your VPN, and it doesn't let you use the VPN for accessing the internet (e.g. to access media that's not available in your area), although they may add that functionality in the future.*

WireGuard is a Virtual Private Network (VPN) system which is new, fast, and claims to be secure. Unfortunately, it's also rather complex to install, and the documentation is highly technical. That's why we've prepared this script and step-by-step guide. If you're not comfortable using a terminal, you might prefer to use [tailscale](https://tailscale.com/), which provides similar functionality through a GUI, and doesn't require setting up a server. The downsides of tailscale are that it costs $10/person/month if you want more than one person using your VPN, and it doesn't let you use the VPN for accessing the internet (e.g. to access media that's not available in your area), although they may add that functionality in the future.

This script will set up a WireGuard server, and will also create client configurations for as many clients as you want. Each device that will connect will need a separate configuration. Note that client devices will be able to see each other on the VPN, as well as the server. Before using wireguard-fast, you'll need to have a Linux server. To setup a Linux (Ubuntu) server, you can use [fastsetup](https://github.com/fastai/fastsetup/).

You'll need to login to your server. If your username is "ubuntu", and your IP address is "1.2.3.4", you login to your server with:

    ssh ubuntu@1.2.3.4

To install, run:

```bash
git clone https://github.com/fastai/wireguard-fast.git
cd wireguard-fast
sudo ./wireguard-fast.sh
```

During installation, you will need to answer three questions, discussed below.

## Questions during installation

### Use VPN for *all* internet traffic? [y/n]

If this VPN is just so that the clients can see each other and the server, respond **n**. If you want *all* traffic to route via the VPN (e.g. to change your apparent location, or to increase privacy and security), respond **y**.

### \# of clients? \[Betwen 1 and 253]

Each device that will need to connect to your VPN is a *client*, and needs a separate configuration file. There's no real downside to creating more client configuration files than you end up using, so err on the high side when answering this question. (E.g. if you're just planning to use this yourself for watching foreign media, you might later find friends and family members wanting to use it too...)

### Server hostname/IP?

This is the host name or IP address that you are installing the server on. The default is to use the current public IP address, by getting the output from the [ifconfig.me] service. If your server IP is not static, you'll need to use dynamic DNS to get a host name that you can connect to, and you should enter the host name here instead of the IP address.

Generally, it's better to use a hostname than an IP if possible, since if you later need to move your VPN server, you can always just update DNS to point the hostname at the new IP, instead of having the update all client configuration files on all devices.

## Connecting clients

The server will be running as soon as the script is complete. It will print something like this to confirm the server is running:

```
interface: wg0
  public key: XXXXX
  private key: (hidden)
  listening port: 51820
```

...and will finally print:
```
Done. clients.tgz contains your client configuration files.
To add clients in the future run:
   sudo ./add-client.sh NUMBER
where NUMBER is the client number to create, which must be larger than 11
```

The server will also be automatically run on reboot, and will reconnect automatically if there are any network issues.

In directory you run the script, you will find a `clients.zip` file. This contains the client configuration files you requested. We'll copy this over to your PC. First, disconnect from your server, by pressing <kbd>Ctrl</kbd>D<kbd></kbd>, or typing `exit`. Now, at your PC's terminal, copy the `clients.zip` file by typing:

    scp ubuntu@1.2.3.4:wireguard-fast/clients.zip ./

You can now unzip this file on your PC. It contains a folder with the conf files you requested. Give one to each person/device that needs to connect, and keep a list somewhere of which numbered config you give to which client, so if you need to remove or re-assign it later, you know who is who. On each device, the user will need to install the WireGuard software from [here](https://www.wireguard.com/install/), and will then follow the directions below.

### Windows

1. Click Start, then type "wireguard" and press enter (or click the WireGuard icon)
1. Click "Add Tunnel" (or press <kbd>Ctrl</kbd><kbd>O</kbd>
1. Choose your config file
1. Click *Activate*

### Mac

I don't have a Mac to test with, so I'm copying the directions from [Mullvad](https://mullvad.net/en/help/wireguard-macos-app/):

1. Click on the WireGuard icon located in your desktop's top menu bar.
1. In the drop-down menu, select Import tunnel(s) from file...
1. Navigate to your Download folder and select the configuration file.
1. Click Import.
1. Click Allow if you get a pop-up saying "'WireGuard' would like to Add VPN Configurations."
1. Click on the WireGuard icon located in your desktop's top menu bar.
1. In the drop-down menu, select the server that you just imported
1. A checkmark will appear next to it. That's it!

## More advanced topics

### Adding new clients

To add new clients later, run the command that you copied at the end of installation, incrementing the last number (`7`, in this case) by one each time you run it:

    sudo SERVER=54.213.232.25 SUBNET=10.42.42.0/24 ./add-client.sh 7
    
You'll find the new client conf file created in the `clients` directory. You can either send the file, or use `cat` to display its contents and copy that. e.g.

```bash
$ cat clients/7.conf

[Interface]
PrivateKey = +NrpspR++zR509u71WEPKpqoOw5+1p5z8HpS4Vyrw2k=
Address = 10.42.42.7/24
[Peer]
PublicKey = VwSJ06TopxpF2Dvlj4ZUDUqwVeHuwZpLDQSvvJtCo3s=
Endpoint = 54.213.232.25:51820
AllowedIPs = 10.42.42.0/24
PersistentKeepalive = 15
```

### Changing client type

You can enable and disable your device from routing all internet traffic, or have different settings for different devices. This is a sample client config which does *not* route all internet traffic:

```
[Interface]
PrivateKey = key_goes_here
Address = 10.42.42.2/24

[Peer]
PublicKey = pub_goes_here
AllowedIPs = 10.42.42.0/24
Endpoint = name.or.ip.here:51820
PersistentKeepalive = 15
```

To change this to route all internet traffic, make these two changes:

- In the `[Interface]` section, add the line `DNS = 1.1.1.1, 1.0.0.1`
- In the `[Peer]` section, change `AllowedIPs` from `10.42.42.0/24` to `0.0.0.0/0`.

Here's the result after making those changes:

```
[Interface]
PrivateKey = key_goes_here
Address = 10.42.42.2/24
DNS = 1.1.1.1, 1.0.0.1

[Peer]
PublicKey = pub_goes_here
AllowedIPs = 0.0.0.0/0
Endpoint = name.or.ip.here:51820
PersistentKeepalive = 15
```
