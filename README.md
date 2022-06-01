# Introducing Airgap OS

Airgap OS is a live amnesic operating system that prevent network communication.
It is designed for security purposes.

Here are some typical use-cases where Airgap OS may be useful:

* handling highly confidential data,
* using and storing PKI root private key,
* handling information in covert operations abroad,
* storing cryptocurrency cold wallet keys.

## Features

* Debian bullseye based Linux with MATE Desktop.
* x86-64 architecture (open an issue if you need another one).
* LibreOffice, VLC, GIMP and other usual tools.
* Only 1G of RAM required.
* [Keepass2](https://keepass.info/).
* [steghide](http://steghide.sourceforge.net/).
* [GnuPG2](https://gnupg.org/) with graphical interface.
* [age](https://github.com/FiloSottile/age).
* [crypt0](https://github.com/piotrcki/crypt0) and [sign0](https://github.com/piotrcki/sign0) for long term data protection.
* [xca](https://hohnstaedt.de/xca/) and [OpenSSL](https://www.openssl.org) for PKI management.
* Smartcard support.
* [Yubikey](https://www.yubico.com/) related softwares. 

# Getting started: download the ISO

[Download the ISO from the release section of this repository](https://github.com/piotrcki/airgap-os/releases) and burn it to a DVD or a flashdrive.

The default password is `changeme` and the default keyboard layout is QWERTY.

# Security

The security model of Airgap OS should prevent the vast majority of cyberattacks, including those involving 0days.

## Integrity

Software integrity only relies on the integrity of the build environment, Debian and the content of this repository.

Integrity references can be found in `/usr/share/Airgap-OS-integrity.txt`.

## Security features

Airgap OS have the following security properties.

* There is no way to communicate with the OS through IP protocols coming from outside.
* Unprivileged software cannot communicate with the outside world through IP protocols.

## Security limitations

Here are some known security limitations.

* In the event of malicious physical access to the used device, a lot of scary shit can happen. 
* Firmwares may have their own network stacks that are out of control from the OS. This can be solved by physically removing or neutralizing network hardware.
* A privileged malware may enable networking again. This can be solved by physically removing or neutralizing network hardware or by disabling them in pre-boot environment.
* A privileged malware may alter the ISO image. This can be solved by using a read-only storage.
* An unprivileged malware could use a covert channel to communicate with attackers. The range of such channels is usually short.
* Data could leak through various side channels, like [TEMPEST](https://www.youtube.com/watch?v=BpNP9b3aIfY).
* I have no ways to protect my build environment from 3 letters actors. Build the ISO yourself to avoid this issue. :-)

# Build

Install `deboostrap` and run `./build.sh` as root.
You may want to use the provided `Dockerfile` to create a build environment.
When building in a Docker container, run it with `--privileged=true` in order to allow internal mounts.
