/************************************************************************
	BeebSCSI_logo.scad
    
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

// Draw the BeebSCSI logo using cylinders
module drawLogo(gridSize, rad1, rad2, height)
{
    // Data for the logo (17x19)
    logoData = [
    [0,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,0], //  1
    [0,1,0,0,0,0,0,1,0,1,0,0,0,0,0,1,0], //  2
    [1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1], //  3
    [0,0,0,1,1,1,0,0,0,0,0,1,1,1,0,0,0], //  4
    [1,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,1], //  5
    [0,1,0,0,0,0,0,1,0,1,0,0,0,0,0,1,0], //  6
    [1,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0,1], //  7
    [0,1,0,1,0,0,0,0,0,0,0,0,0,1,0,0,0], //  8
    [1,0,1,0,1,0,1,0,1,0,1,0,1,0,0,0,1], //  9
    [0,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0], // 10
    [1,0,1,0,1,0,1,0,0,0,0,0,0,0,0,0,1], // 11
    [0,1,0,1,0,1,0,1,0,0,0,0,0,0,0,0,0], // 12
    [1,0,1,0,1,0,1,0,1,0,0,0,0,0,0,0,1], // 13
    [0,0,0,1,0,1,0,1,0,1,0,0,0,0,0,0,0], // 14
    [1,0,0,0,1,0,1,0,1,0,1,0,0,0,0,0,1], // 15
    [0,0,0,0,0,1,0,1,0,1,0,1,0,0,0,0,0], // 16
    [1,0,0,0,0,0,1,0,1,0,1,0,1,0,0,0,1], // 17
    [0,1,0,0,0,0,0,1,0,1,0,1,0,1,0,1,0], // 18
    [0,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,0]  // 19
    ];
    
    // Render the data
    for (row = [0:18]) {
        for (pix = [0:16]) {
            if (logoData[row][pix] == 1) translate([pix * gridSize, -row * gridSize, 0])
                cylinder(h = height, r1 = rad1, r2 = rad2);
        }
    }
}

// Only for testing
//drawLogo(2, 1, 2, 2);