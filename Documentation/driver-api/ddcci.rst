.. SPDX-License-Identifier: GPL-2.0-or-later

==============
DDC/CI
==============

1. Introduction
===============
DDC/CI is a control protocol for monitor settings supported by most
monitors since about 2005. It is based on ACCESS.bus (an early USB predecessor).
This could be used to create drivers that communicate with the DDCCI component,
see ddcci-backlight for an example.

2. sysfs interface
==================
Each detected DDC/CI device gets a directory in /sys/bus/ddcci/devices.
The main device on a bus is named ddcci[I2C bus number].
Internal dependent devices are named ddcci[I2C bus number]i[hex address]
External dependent devices are named ddcci[I2C bus number]e[hex address]
There the following files export information about the device:

- capabilities

The full ACCESS.bus capabilities string. It contains the protocol,
type and model of the device, a list of all supported command
codes, etc. See the ACCESS.bus spec for more information.

- idProt

ACCESS.bus protocol supported by the device. Usually "monitor".

- idType

ACCESS.bus device subtype. Usually "LCD" or "CRT".

- idModel

ACCESS.bus device model identifier. Usually a shortened form of the
device model name.

- idVendor

ACCESS.bus device vendor identifier. Empty if the Identification command
is not supported.

- idModule

ACCESS.bus device module identifier. Empty if the Identification command
is not supported.

- idSerial

32 bit device number. A fixed serial number if it's positive, a temporary
serial number if negative and zero if the
Identification command is not supported.

- modalias

A combined identifier for driver selection. It has the form:
ddcci:<idProt>-<idType>-<idModel>-<idVendor>-<idModule>.
All non-alphanumeric characters (including whitespace) in the model,
vendor or module parts are replaced by underscores to prevent issues
with software like systemd-udevd.

3. Character device interface
=============================
For each DDC/CI device a character device in
/dev/bus/ddcci/[I2C bus number]/ is created,
127 devices are assigned in total.

The main device on the bus is named display.

Internal dependent devices are named i[hex address]

External dependent devices are named e[hex address]

These character devices can be used to issue commands to a DDC/CI device
more easily than over i2c-dev devices. They should be opened unbuffered.
To send a command just write the command byte and the arguments with a
single write() operation. The length byte and checksum are automatically
calculated.

To read a response use read() with a buffer big enough for the expected answer.

NOTE: The maximum length of a DDC/CI message is 32 bytes.

4. ddcci-backlight (monitor backlight driver)
=============================================
[This is not specific to the DDC/CI backlight driver, if you already dealt with
backlight drivers, skip over this.]

For each monitor that supports accessing the Backlight Level White
or the Luminance property, a backlight device of type "raw" named like the
corresponding ddcci device is created. You can find them in /sys/class/backlight/.
For convenience a symlink "ddcci_backlight" on the device associated with the
display connector in /sys/class/drm/ to the backlight device is created, as
long as the graphics driver allows to make this association.

5. Limitations
==============

-Dependent devices (sub devices using DDC/CI directly wired to the monitor,
like  Calibration devices, IR remotes, etc.) aren't automatically detected.
You can force detection of external dependent devices by writing
"ddcci-dependent [address]" into /sys/bus/i2c/i2c-?/new_device.

There is no direct synchronization if you manually change the luminance
with the buttons on your monitor, as this can only be realized through polling
and some monitors close their OSD every time a DDC/CI command is received.

Monitor hotplugging is not detected. You need to detach/reattach the I2C driver
or reload the module.

6. Debugging
============
Both drivers use the dynamic debugging feature of the Linux kernel.
To get detailed debugging messages, set the dyndbg module parameter.
If you want to enable debugging permanently across reboots, create a file
/etc/modprobe.d/ddcci.conf containing lines like the following before loading the modules:

options ddcci dyndbg
options ddcci-backlight dyndbg

7. Origin
============
This driver originally came from Christoph Grenz in DKMS form here:
https://gitlab.com/ddcci-driver-linux/ddcci-driver-linux
with multiple backups available on the wayback machine. It also
inlcudes a example program for the usage of this driver in
userland.
