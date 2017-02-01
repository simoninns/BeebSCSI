## Synopsis

BeebSCSI_ROM is the BBC Micro and Master source code ROM for the BeebSCSI project.

NOTE: This ROM is Beta - it might not even work for you!

## Motivation

Originally Acorn provided a SCSI solution based on 3 individual parts: The Acorn SCSI host adapter, the Adaptec ACB-4000 SCSI adapter and a physical MFM hard disc (a ‘Winchester drive’). Later, as part of the Domesday project (in 1986), this was extended to include the AIV SCSI Host Adapter (designed to be connected internally to a BBC Master Turbo) and the Philips VP415 LaserVision laser disc player with SCSI-1 support.

BeebSCSI 7 is a credit-card sized board that provides a single-chip implementation of the host adapter board (both original and AIV) using a modern CPLD (Complex Programmable Logic Device). In addition, an AVR Microcontroller provides a complete SCSI-1 emulation including the vendor specific video control commands of the VP415.

Rather than using a physical hard drive, BeebSCSI uses a single Micro SD card to provide up to >64Gbytes of storage with support for either 4 (ADFS) or 8 (VFS) virtual hard drives (or ‘LUNs’) per card. In addition, in the BBC Master, two BeebSCSI devices can be attached, one internal and one external, providing 12 SCSI LUNs (hard drive images) simultaneously.

## Installation

The BeebSCSI_ROM can be compiled using BeebASM and generates a ROM image for the BBC Micro and Master.

The ROM image is loaded either as a physical EPROM or by using a command such as:

*SRLOAD BSROM 8000 4

Please see http://www.domesday86.com for detailed documentation on BeebSCSI

## Author

BeebSCSI is written and maintained by Simon Inns.

## License

    BeebSCSI is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    BeebSCSI is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with BeebSCSI.  If not, see <http://www.gnu.org/licenses/>.