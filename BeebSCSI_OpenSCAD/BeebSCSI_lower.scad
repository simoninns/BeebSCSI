/************************************************************************
	BeebSCSI_lower.scad
    
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

// Draw the lower case part (widthClearance is millimetres around the PCB)

// x = x offset from origin
// y = y offset from origin
// z = z offset from origin
// widthClearance = mm of clearance around the sides of the PCB
// lengthClearance = mm of clearance at the front of the PCB
// height = height of the lower case in mm (minimum is 15mm)
// iSerial = include serial port true/false
// iPower = include power port true/false
// iUsb = include USB port true/false
// iVents = include vents in base (reduces printing time)

// Note: Screw holes are designed for M3 6mm counter-sunk head screws

module lowerCase(x, y, z,
    widthClearance, lengthClearance, height,
    iSerial, iPower, iUsb, iVents)
{
    // Size of the PCB (constants)
    pcbLength = 65.5;
    pcbWidth = 51;
    
    // Calculate total widthClearance
    widthClearance = widthClearance * 2;
    
    // Draw the base and walls of the lower case
    translate([x, y, z]) {
        // Base
        difference() {
            cube([pcbLength + lengthClearance, pcbWidth + widthClearance + 2, 2], center = false);
            
            if (iVents) {
                translate([8, 2 + (widthClearance / 2), 0])
                    cube([4, pcbWidth, 2], center = false);
                
                translate([18, 2 + (widthClearance / 2), 0])
                    cube([4, pcbWidth, 2], center = false);
                
                translate([28, 2 + (widthClearance / 2), 0])
                    cube([4, pcbWidth, 2], center = false);
                
                translate([38, 2 + (widthClearance / 2), 0])
                    cube([4, pcbWidth, 2], center = false);
                
                translate([48, 2 + (widthClearance / 2), 0])
                    cube([4, pcbWidth, 2], center = false);
            }
            
            // Draw the front screw holes
            translate([pcbLength, 2 + (widthClearance / 2), 0]) {
                translate([-3.75, 5.5, 0]) {
                    cylinder(h = 2, r1 = 3, r2 = 2);
                }
                
                translate([-3.75, 45.5, 0]) {
                    cylinder(h = 2, r1 = 3, r2 = 2);
                }
            }
        }
        
        // Left (USB and power connectors)
        difference() {
            cube([pcbLength + lengthClearance, 2, height], center = false);
            
            // Add a port for the power connector
            if (iPower) 
                translate([18, 0, 5.5]) cube([9, 2, 5], center = false);
            
            // Add a port for the USB connector
            if (iUsb) 
                translate([43.25, 0, 5.5]) cube([13, 2, 5], center = false);
        }
        
        // Right (Serial connector)
        difference() {
            translate([0, pcbWidth + widthClearance + 2, 0])
                cube([pcbLength + lengthClearance, 2, height], center = false);
            
            // Add a port for the serial connector
            if (iSerial)
                translate([31, pcbWidth + widthClearance + 2, 6])
                    cube([15, 2, 6], center = false);
        }
        
        // Front
        difference() {
            translate([pcbLength + lengthClearance, 0, 0]) cube([2, pcbWidth + widthClearance + 4,
                height], center = false);
            
            // Add a port for the SD card
            translate([pcbLength + lengthClearance, (widthClearance / 2) + 22.25, 8])
                cube([2, 12, 2], center = false);
            
            // Add stripe decorations
            translate([pcbLength + lengthClearance + 1.3, 21, 11])
                cube([0.7, pcbWidth + widthClearance - 21, 2], center = false);
            translate([pcbLength + lengthClearance + 1.3, 21, 8])
                cube([0.7, pcbWidth + widthClearance - 21, 2], center = false);
            translate([pcbLength + lengthClearance + 1.3, 21, 5])
                cube([0.7, pcbWidth + widthClearance - 21, 2], center = false);
            
            // Import the BeebSCSI logo text
            translate([pcbLength + lengthClearance + 1.65, 3, 3]) {
                rotate(a = 90, v=[1, 0, 0])
                rotate(a = 90, v=[0, 1, 0])
                scale(v = [0.4, 0.4, 1])
                linear_extrude(height = 0.7, center = true, convexity = 10)
                import (file = "BeebSCSI_text.dxf");
            }
        }
        
        // Rear support platform
        translate([0, 2 + (widthClearance / 2), 2]) {
            // Main support platform
            cube([8, pcbWidth, 2], center = false);
            
            // Draw the rear mounting studs
            translate([4, 5.5, 2]) {
                cylinder(h = 1.6, r = 1.45);
            }
            
            translate([4, 45.5, 2]) {
                cylinder(h = 1.6, r = 1.45);
            }
        }
        
        // Front support platform
        translate([pcbLength, 2 + (widthClearance / 2), 2]) {
            difference() {
                translate([-9, 0, 0]) {
                    cube([9, pcbWidth, 2], center = false);
                }
                
                // Draw the front screw holes
                translate([-3.75, 5.5, 0]) {
                    cylinder(h = 2, r = 1.75);
                }
                
                translate([-3.75, 45.5, 0]) {
                    cylinder(h = 2, r = 1.7);
                }
            }
        }
        
        // Add rear wall
        translate([0, 2, 2])
            cube([2, widthClearance / 2, 2], center = false);
        translate([0, 2 + pcbWidth + (widthClearance / 2), 2])
            cube([2, widthClearance / 2, 2], center = false);
        
        // If the PCB width clearance is greater than 2mm, add some additional
        // surface to enclose the back better
        if (widthClearance > 4) {
            translate([0, 2, 4])
                cube([2, (widthClearance / 2) - 2, height - 6], center = false);
            translate([0, 2 + pcbWidth + (widthClearance / 2) + 2, 4])
                cube([2, (widthClearance / 2) - 2, height - 6], center = false);
            
            translate([0, 4, 4 + height - 6])
                cube([2, (widthClearance / 2) - 4, 2], center = false);
            translate([0, 2 + pcbWidth + (widthClearance / 2) + 2, 4 + height - 6])
                cube([2, (widthClearance / 2) - 4, 2], center = false);
        }
    }    
}

// Render for testing
//lowerCase(0, 0, 0,
//    2, 2, 15,
//    true, true, true, true);