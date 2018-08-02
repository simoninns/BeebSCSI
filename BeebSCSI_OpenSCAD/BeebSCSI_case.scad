/************************************************************************
	BeebSCSI_case.scad
    
	BeebSCSI 3D Printable case design
    BeebSCSI - BBC Micro SCSI Drive Emulator
    Copyright (C) 2018 Simon Inns
	
    This file is part of BeebSCSI.
    
    BeebSCSI is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.
    
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    
    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
	
    Email: simon.inns@gmail.com
    
************************************************************************/

// Select the rendering accuracy for development or printing
//$fn = 20; // Uncomment for producing STL files
$fn = 10; // Uncomment for development

// Include modules
include <BeebSCSI77_pcb.scad>;
include <BeebSCSI_lower.scad>;
include <BeebSCSI_upper.scad>;

// Choose options:

// Include the PCB model?
includePcb = true;

// 0 = Render the whole case
// 1 = Render the whole case with the upper case lifted
// 2 = Render the just the lower case part (use this for preparing STL files)
// 3 = Render the just the upper case part
// 4 = Render the just the upper case part (use this for preparing STL files)
renderOption = 1;

// Port access options (only for right-angle connectors):

// Include a port for the serial connector?
includeSerialPort = false;

// Include a port for the power connector?
includePowerPort = false;

// Include a port for the USB connector?
includeUsbPort = false;

// Include the BeebSCSI logo on the upper case?
includeLogo = true;

// Height of the lower case part in mm (minimum is 15mm to clear the IDC connector)
// Note: the upper case will add 2 mm more height to the lower case
lowerCaseHeight = 15;

// PCB width clearance in mm (changes width of case)
// 1mm is the minimum
// 2mm is recommended maximum if using right-angle connector ports
// 4mm is recommended for internal connection of right-angle connectors
pcbWidthClearance = 2;

// PCB length clearance in mm (changes length of case)
// 1mm is the minimum
// 4mm is the maximum (otherwise the SD card will not protrude)
pcbLengthClearance = 2;

// No options below this line -----------------------------------------------------

// 0 = Render the whole case
if (renderOption == 0) {
    // Render the FR4 PCB (1.6mm board thickness)
    if (includePcb) renderPcb(0, pcbWidthClearance + 2, 4);
    lowerCase(0, 0, 0,
        pcbWidthClearance, pcbLengthClearance,
        lowerCaseHeight,
        includeSerialPort, includePowerPort, includeUsbPort);
    upperCase(0, 0, lowerCaseHeight, pcbWidthClearance, pcbLengthClearance,
        lowerCaseHeight);
}

// 1 = Render the whole case with the upper case lifted
if (renderOption == 1) {
    // Render the FR4 PCB (1.6mm board thickness)
    if (includePcb) renderPcb(0, pcbWidthClearance + 2, 4);
    lowerCase(0, 0, 0,
        pcbWidthClearance, pcbLengthClearance,
        lowerCaseHeight,
        includeSerialPort, includePowerPort, includeUsbPort);
    upperCase(0, 0, lowerCaseHeight + 50, pcbWidthClearance, pcbLengthClearance,
        lowerCaseHeight, includeLogo);
}

// 2 = Render the just the lower case part (use this for preparing STL files)
if (renderOption == 2) {
    // Render the FR4 PCB (1.6mm board thickness)
    if (includePcb) renderPcb(0, pcbWidthClearance + 2, 4);
    lowerCase(0, 0, 0,
        pcbWidthClearance, pcbLengthClearance,
        lowerCaseHeight,
        includeSerialPort, includePowerPort, includeUsbPort);
}

// 3 = Render the just the upper case part
if (renderOption == 3) {
    // Render the FR4 PCB (1.6mm board thickness)
    if (includePcb) renderPcb(0, pcbWidthClearance + 2, 4);
    upperCase(0, 0, 0, pcbWidthClearance, pcbLengthClearance,
        lowerCaseHeight, includeLogo);
}

// 4 = Render the just the upper case part (use this for preparing STL files)
// This option places the upper case part flat on the origin
if (renderOption == 4) {
    // Render the FR4 PCB (1.6mm board thickness)
    if (includePcb) renderPcb(0, pcbWidthClearance + 2, 4);
    rotate(a = 180, v = [1, 0, 0]) translate([0, 0, -2])
        upperCase(0, 0, 0, pcbWidthClearance, pcbLengthClearance,
            lowerCaseHeight, includeLogo);
}

