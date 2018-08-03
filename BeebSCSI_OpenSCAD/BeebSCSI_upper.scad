/************************************************************************
	BeebSCSI_upper.scad
    
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

include <BeebSCSI_logo.scad>;

// Draw the upper case part (clearance is millimetres around the PCB)

// x = x offset from origin
// y = y offset from origin
// z = z offset from origin
// widthClearance = mm of clearance around the sides of the PCB
// lengthClearance = mm of clearance at the front of the PCB
// lowerCaseHeight = height of the lower case in mm (minimum is 15mm)
// includeLogo = true if logo should be included

// Note: Screw holes are designed for M3 6mm counter-sunk head screws

module upperCase(x, y, z,
    widthClearance, lengthClearance,
    lowerCaseHeight,
    includeLogo)
{
    // Height of the upper case
    height = 4;
    
    // Size of the PCB
    pcbLength = 65.5;
    pcbWidth = 51;
    
    // Logo grid and hole sizes
    logoGrid = 2.5;
    logoHole = 1.2;
    
    // Calculate total clearance
    widthClearance = widthClearance * 2;
    
    // Draw the top of the upper case
    translate([x, y, z]) {
        // Base
        difference() {
            cube([pcbLength + lengthClearance + 2, pcbWidth + widthClearance + 4, 2],
                center = false);
            
            // Add the BeebSCSI logo
            if (includeLogo) {
                translate([((pcbLength + lengthClearance) / 2) - ((19 * logoGrid) / 2),
                    ((pcbWidth + widthClearance + 4) / 2) - ((17 * logoGrid) / 2) + 1.3, 0])
                    rotate(a = 90, v=[0,0,1]) drawLogo(logoGrid, logoHole, logoHole, 2);
            }
        }
        
        // Left
        translate([0, 2, -2])
            cube([pcbLength + lengthClearance, 2, height], center = false);
    
        // Right
        translate([0, pcbWidth + widthClearance, -2])
            cube([pcbLength + lengthClearance, 2, height], center = false);

        // Front
        translate([pcbLength + lengthClearance - 2, 2, -2])
            cube([2, pcbWidth + widthClearance, height], center = false);

        // Draw the front screw supports (M3)
        translate([pcbLength, 2 + (widthClearance / 2), 2]) {
            // Draw the front screw holes
            translate([-3.75, 5.5, -lowerCaseHeight + 4.2]) {
                difference() {
                    cylinder(h = lowerCaseHeight - 4.2, r1 = 2.5, r2 = 3.5);
                    cylinder(h = lowerCaseHeight - 4.2, r = 1.5);
                }
            }
            
            translate([-3.75, 45.5, -lowerCaseHeight + 4.2]) {
                difference() {
                    cylinder(h = lowerCaseHeight - 4.2, r1 = 2.5, r2 = 3.5);
                    cylinder(h = lowerCaseHeight - 4.2, r = 1.5);
                }
            }
         }
        
    }
}

// Render (for testing)
//upperCase(0, 0, 0, 6, 6, 15, true);