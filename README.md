## Synopsis

BeebSCSI is a Micro SD Card based SCSI storage emulation for the Acorn 8-bit range of microcomputers including the Acorn BBC Model B (with ADFS) and the BBC Master 128.

Please see http://www.domesday86.com for detailed documentation on BeebSCSI

The project is divided into several sections:

BeebSCSI_AVR - This is the AT90USB1287 microcontroller firmware (written in GCC)

BeebSCSI_CPLD - This is the Xilinx XC9572XL CPLD firmware (written in ISE Verilog)

BeebSCSI_Eagle - This folder contains the EagleCAD schematics and PCB designs

BeebSCSI_ROM - This folder contains the 6502 assembly code for the BeebSCSI ROM

BeebSCSI_Utils - This folder contains BBC BASIC utilities for BeebSCSI


## Motivation

Originally Acorn provided a SCSI solution based on 3 individual parts: The Acorn SCSI host adapter, the Adaptec ACB-4000 SCSI adapter and a physical MFM hard disc (a ‘Winchester drive’). Later, as part of the Domesday project (in 1986), this was extended to include the AIV SCSI Host Adapter (designed to be connected internally to a BBC Master Turbo) and the Philips VP415 LaserVision laser disc player with SCSI-1 support.

BeebSCSI 7 is a credit-card sized board that provides a single-chip implementation of the host adapter board (both original and AIV) using a modern CPLD (Complex Programmable Logic Device). In addition, an AVR Microcontroller provides a complete SCSI-1 emulation including the vendor specific video control commands of the VP415.

Rather than using a physical hard drive, BeebSCSI uses a single Micro SD card to provide up to >64Gbytes of storage with support for either 4 (ADFS) or 8 (VFS) virtual hard drives (or ‘LUNs’) per card. In addition, in the BBC Master, two BeebSCSI devices can be attached, one internal and one external, providing 12 SCSI LUNs (hard drive images) simultaneously.

## Installation

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