/************************************************************************
	BeebSCSI77_pcb.scad
    
	BeebSCSI PCB 7_7 renderer
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

// Render the BeebSCSI 7_7 PCB and connector clearances
module renderPcb(x, y, z)
{
    translate([x, y, z]) {
        // Draw the PCB and subtract the mounting holes (3mm)
        difference() {
            cube([65.5, 51, 1.6], center = false);
            mountingHole(4, 5.5, 0, 1.6, 1.5);
            mountingHole(4, 45.5, 0, 1.6, 1.5);

            mountingHole(61.75, 5.5, 0, 1.6, 1.5);
            mountingHole(61.75, 45.5, 0, 1.6, 1.5);
        }

        // Draw the SD card holder
        translate([59.5, 20.25, 1.6,]) cube([5.5, 11, 4], center = false);

        // Draw the SD card
        translate([59.5, 20.75, 1.6+2.9,]) cube([14, 10, 1], center = false);

        // Draw the power connector (right angle)
        translate([18.5, 0, 1.6,]) cube([8, 9, 4], center = false);

        // Draw the USB connector (right angle)
        translate([43.25, 0, 1.6,]) cube([13, 9, 4], center = false);

        // Draw the serial connector (right angle)
        translate([31, 41, 1.6,]) cube([15, 10, 5], center = false);

        // Draw the 1 MHz bus connector (right angle)
        translate([1, 0, 1.6,]) cube([9, 51, 9], center = false);
        
        // Draw the status LED
        translate([26, 48.5, 1.6,]) cube([2, 1, 1], center = false);
    }
}

// PCB mounting holes
module mountingHole(x, y, z, height, radius)
{
    // Render the hole
    translate([x, y, z]) {
        cylinder(h = height, r = radius);
    }
}

// Render the PCB (for module testing)
//renderPcb(0, 0, 0);