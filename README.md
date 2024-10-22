# arch-i3-config
My i3wm config for Arch Linux. Although it is tailored for my personal use and I actually use it as a form of documentation to optimize my setup, feel free to use it as a template or rough guide for your own setup.


## My `pacstrap` during the installation
```bash
pacstrap -K /mnt base base-devel linux-zen linux-zen-headers linux-firmware mesa efibootmgr iwd dhcpcd intel-ucode man-db man-pages texinfo reflector
```

## After installation
### User accounts
Many sources on the internet, including the [arch wiki](https://wiki.archlinux.org/title/General_recommendations) cautiously warns about the security risks of using the root account for a prolonged periods of time. As a fresh install of Arch Linux leaves you with a root account only, it is imperative to create a regular user account for yourself that you can use in a day-to-day basis.

Create a new user account with a respective home directory (`-m`) and set the default shell to `bash` for now:
```bash
useradd -m -s /bin/bash username
passwd username
```

From this point on, reboot the system and log in as the newly created user.

### Network settings -- Wi-Fi
My setup uses bare-bone configuration with `iwd` for Wi-Fi, accompanied with `dhcpcd` for DHCP. `NetworkManager` is not used. Every Wi-Fi network is saved in a dedicated file in the `/var/lib/iwd` directory. Home and personal networks are saved in `essid.psk` files, where `essid` is the network name. However, e.g. eduroam and similar WPA2 Enterprise networks are saved in `essid.8021x` files and they are need to be manually configured before using them. Depending on the EAP method and EAP Phase 2 method, the configuration file may vary. Consult the [`iwd` wiki](https://wiki.archlinux.org/title/Iwd) for more information.

Usually, the configuration file for WPA2 Enterprise networks looks like this:
```bash
[Security]
EAP-Method=TTLS
EAP-Identity=anonymous@your_email.org
EAP-TTLS-CACert=/etc/ca-certificates/trust-source/myCA.p11-kit
EAP-TTLS-ServerDomainMask=domain.something.org
EAP-TTLS-Phase2-Method=Tunneled-PAP
EAP-TTLS-Phase2-Identity=your_user@your_email.org

[Settings]
AutoConnect=true
```

After the correct setup of the configuration file, connect to a Wi-Fi network using `iwd`:
```bash
sudo iwctl
[iwd]# station wlan0 connect SSID
```

### Optional setup: Certificates
Arch uses the `p11-kit` toolkit from Fedora to handle certificates. Certificates are usually stored in the `/etc/ca-certificates/trust-source/` directory in the `.p11-kit` format. Downloaded certificates can be trusted **system-wide** by running the `trust` command as

```bash
sudo trust anchor --store /path/to/certificate.crt
```

Here, the file with the `.crt` extension could store either PEM or DER encoded certificates, but the extension itself is not important, it could be anything. Certificates sometimes can be found with a `.pem` extension.

### Installation of basic packages
First, update the Arch mirror list using `reflector`. This command will save the 5 most recent mirrors with the highest download speed, using the HTTPS protocol, and from the specified countries. The list will be saved to `/etc/pacman.d/mirrorlist`. Yes, `reflector` is deemed as an overkill for for this task by some people, but I don't really give a shit.
```bash
sudo reflector --save /etc/pacman.d/mirrorlist --sort rate --protocol https --latest 5 --country 'something1,something2,etc'
```

```bash
sudo pacman -Syyu git nano zsh alacritty picom dunst i3 i3status lightdm lightdm-gtk-greeter pulseaudio pulseaudio-alsa pulseaudio-bluetooth bluez bluez-utils
```

For Pulse+ALSA (e.g. for Steam support), optionally install these (`pacman` may not find them, **TODO:** look into this):
```bash
sudo pacman -Syyu lib32-libpulse lib32-alsa-plugins
```

### Setting up `i3lock` with a custom script