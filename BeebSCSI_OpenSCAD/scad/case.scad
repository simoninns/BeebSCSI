/************************************************************************

	lower_case.scad
    
	BeebSCSI PCB 7_7 renderer
    BeebSCSI - BBC Micro SCSI Drive Emulator
    Copyright (C) 2020 Simon Inns
	
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

include <material.scad>

// Uses the BOSL library: https://github.com/revarbat/BOSL
include <BOSL/constants.scad>
use <BOSL/transforms.scad>
use <BOSL/shapes.scad>

// Draw the main body of the case
module render_lower_case(x, y, z, upper_case_height, height)
{
    // PCB is 51mm width, 65.5mm length
    wall_thickness = 2;
    spacing = 1;
    width = 51 + (2 * (wall_thickness + spacing));
    length = 65.5 + (2 * (wall_thickness + spacing));

    // Values to be added to cutouts to prevent rendering issues
    ncp1 = 0.01;
    ncp2 = 0.02;
    
    // Draw the case body
    material(2) difference() {
        move([x - wall_thickness - spacing, y - wall_thickness - spacing, z - wall_thickness]) {
            cuboid([length, width, height], chamfer = 1.5, center = 0, edges = EDGES_BOTTOM+EDGES_Z_RT);
        }
        
        move([x - wall_thickness - spacing, y - wall_thickness - spacing, z - wall_thickness]) {
            move([wall_thickness, wall_thickness, wall_thickness]) {
                cuboid([length - (wall_thickness * 2), width - (wall_thickness * 2), height], center = 0);
            }
        }

        // Add a slot for the SD card
        move([x, y, z]) {
            move([length - (wall_thickness * 2) - spacing - ncp1, 20, 5]) cuboid([wall_thickness + ncp2, 12, 2], center = 0);
        }

        // Provide access to the 1MHz bus connector
        move([x, y, z]) {
            move([-(wall_thickness + spacing) - ncp1, -(spacing) - ncp1, wall_thickness]) {
                cuboid([wall_thickness + ncp2, width - (wall_thickness * 2) + ncp2, height], center = 0);
            }
        }

        // Recess the logotype
        move([length - (wall_thickness * 2) + ncp1, 1.3, 3]) {
            rotate([90, 0, 90]) draw_logotype(0.38);
        }

        // Recess the case decoration
        if (global_print_type == "Multi") {
            draw_case_decoration();  
        }

        // Overhang rail
        move([-3 - ncp2, -3, height - 2]) {
            move([0, 2 + ncp1, -1.75]) {
                rotate([0, 0, 270]) right_triangle([1, length - 3 + ncp1, 1]);
            }
            move([0, 1 - ncp1, -2.25]) {
                cuboid([length - 3, 2, 0.5 + ncp1], center = 0);
            }

            move([length - 3, width - 2 - ncp1, -1.75]) {
                rotate([0, 0, 90]) right_triangle([1, length - 3 + ncp1, 1]);
            }
            move([0, width - 3 + ncp1, -2.25]) {
                cuboid([length - 3, 2, 0.5 + ncp1], center = 0);
            }
        }
    }

    // Draw the PCB standoffs
    material(2) move([x, y, z - height + wall_thickness]){
        // Draw back standoffs
        move ([4, 5.5, height - wall_thickness]) cyl(h = 1, r = 2.5, align = V_TOP);
        move ([4, 5.5 + 40, height - wall_thickness]) cyl(h = 1, r = 2.5, align = V_TOP);

        // PCB is 1.6mm thick; draw mounting studs
        move ([4, 5.5, height - wall_thickness]) cyl(h = 1 + 1.6, r = 1.45, align = V_TOP, fillet2 = 0.2);
        move ([4, 5.5 + 40, height - wall_thickness]) cyl(h = 1 + 1.6, r = 1.45, align = V_TOP, fillet2 = 0.2);

        // Draw front standoffs
        move ([4 + 57.75, 5.5, height - wall_thickness]) cyl(h = 1, r = 2.5, align = V_TOP);
        move ([4 + 57.75, 5.5 + 40, height - wall_thickness]) cyl(h = 1, r = 2.5, align = V_TOP);

        // Draw front standoff nubs to hold the PCB in place
        move ([4 + 57.75, 5.5, height - wall_thickness]) cyl(h = 1.3, r = 1.45, align = V_TOP, fillet2 = 0.5);
        move ([4 + 57.75, 5.5 + 40, height - wall_thickness]) cyl(h = 1.3, r = 1.45, align = V_TOP, fillet2 = 0.5);
    }

    // Add holders above the PCB
    material(2) {
        move([length - wall_thickness - spacing - 2, -spacing, 2 + 1.9]) {
            rotate([90, 0, 180]) right_triangle([8, 1.5, 9]);
        }

        move([length - wall_thickness - spacing - 2, -spacing + width - 4, 2 + 1.5 + 1.9]) {
            rotate([-90, 0, 180]) right_triangle([8, 1.5, 9]);
        }
    }

    // Draw the case decoration
    if (global_print_type == "Multi") {
        material(3) draw_case_decoration();
    }
}

// Note: Height should be >= 3
module render_upper_case(x, y, z, height, lower_case_height, standoff_height, print_position)
{
    // PCB is 51mm width, 65.5mm length
    wall_thickness = 2;
    spacing = 1; // Border around PCB
    width = 51 + (2 * (wall_thickness + spacing));
    length = 65.5 + (2 * (wall_thickness + spacing));
    lip_thickness = 1;
    lip_depth = 3;

    // Values to be added to cutouts to prevent rendering issues
    ncp1 = 0.01;
    ncp2 = 0.02;

    // Values set according to module parameters
    uplift = print_position == "No" ? standoff_height : 0;
    rotatedeg1 = print_position == "No" ? 0 : 180;
    ymove = print_position == "No" ? 0 : -10;
    zmove = print_position == "No" ? 0 : lower_case_height - 1;

    move([0, ymove, zmove]) rotate([0, rotatedeg1, rotatedeg1]) {
        move([x - wall_thickness - spacing, y - wall_thickness - spacing, z - wall_thickness + lower_case_height + uplift]) {
            material(2) difference() {
                // Render the lid
                cuboid([length, width, height], chamfer = 1.5, center = 0, edges = EDGES_TOP+EDGES_Z_RT);

                // Hollow it out to the correct wall thickness
                move([wall_thickness, wall_thickness, -(wall_thickness -1) - ncp1]) {
                    cuboid([length - (wall_thickness * 2), width - (wall_thickness * 2), height - wall_thickness + 1 + ncp2], center = 0);
                }
                
                // Provide access to the 1MHz bus connector
                move([0 - ncp1, wall_thickness - ncp1,  -wall_thickness - ncp1]) cuboid([wall_thickness + ncp2, width - (wall_thickness * 2) + ncp2, height + ncp2], center = 0);

                // Recess the logotype
                if (global_print_type == "Multi") {
                    // Use 1mm depth recess for multi-material
                    move([length - (wall_thickness * 2) - 20, 9, 2 + ncp1]) {
                        rotate([0, 0, 90]) draw_logotype(1,1);
                    }
                } else {
                    // Use 0.6mm depth for single material
                    move([length - (wall_thickness * 2) - 20, 9, 2.4 + ncp1]) {
                        rotate([0, 0, 90]) draw_logotype(1,0.6);
                    }
                }
            }

            // Draw the logotype
            if (global_print_type == "Multi") {
                material(3) move([length - (wall_thickness * 2) - 20, 9, 2 + ncp1]) {
                    rotate([0, 0, 90]) draw_logotype(1,1);
                }
            }
            
            // Add lip
            material(2) {
                move([wall_thickness -2, wall_thickness , -lip_depth]) {
                    difference() {
                        cuboid([length - (wall_thickness * 2) + 2, width - (wall_thickness * 2), height + lip_depth - wall_thickness], center = 0);

                        move([lip_thickness - 2, lip_thickness, -ncp1]) {
                                cuboid([length - ((lip_thickness + wall_thickness) * 2) + 5 + ncp1, width - ((lip_thickness + wall_thickness) * 2),
                                    height + lip_depth - wall_thickness + ncp2], center = 0);
                        }
                    }
                }

                move([wall_thickness + length - 5, wall_thickness, -0.5]) {
                    cuboid([1,width - (lip_thickness + wall_thickness) * 2 + 2, 1.5], center = 0);
                }

                // Overhang rail
                move([0, 2, -1.75]) {
                    rotate([0, 0, 270]) right_triangle([1, length - 4, 1]);
                }
                move([0, 1, -2.25]) {
                    cuboid([length - 4, 1, 0.5], center = 0);
                }

                move([length - 4, width - 2, -1.75]) {
                    rotate([0, 0, 90]) right_triangle([1, length - 4, 1]);
                }
                move([0, width - 2, -2.25]) {
                    cuboid([length - 4, 1, 0.5], center = 0);
                }
            }
        }
    }
}

// Draw the BeebSCSI logo using cylinders
module draw_logo(gridSize, rad, height)
{
    // Data for the logo (17x19)
    logoData = [
    [0,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,0], //  1
    [0,1,0,0,0,0,0,1,0,1,0,0,0,0,0,1,0], //  2
    [1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1], //  3
    [0,0,0,1,0,1,0,0,0,0,0,1,0,1,0,0,0], //  4
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
            if (logoData[row][pix] == 1) move([pix * gridSize, -row * gridSize, 0]) {
                cyl(h = height, r = rad, center = 0);
            }
        }
    }
}

// Draw the BeebSCSI logotype
module draw_logotype(scale_factor, height)
{
    scale(v = [scale_factor, scale_factor, 1])
    linear_extrude(height = height, center = false, convexity = 10)

    // Import the BeebSCSI logo text
    import (file = "BeebSCSI_text.dxf");
}

// Draw the lower case decoration
module draw_case_decoration()
{
    // PCB is 51mm width, 65.5mm length
    wall_thickness = 2;
    spacing = 1; // Border around PCB
    width = 51 + (2 * (wall_thickness + spacing));
    length = 65.5 + (2 * (wall_thickness + spacing));

    // Values to be added to cutouts to prevent rendering issues
    ncp1 = 0.01;
    ncp2 = 0.02;

    difference() {
        union() {
            // Upper right stripe
            move([0 - (wall_thickness + spacing) - ncp1, 17, 7 - ncp1]) {
                cuboid([length + ncp2, 37 + ncp1, 2], center = 0, chamfer = 1.5, edges = EDGE_BK_RT);
            }

            // Upper left stripe
            move([0 - (wall_thickness + spacing) - ncp1, 0 - (wall_thickness + spacing + ncp1), 7]) {
                cuboid([length + ncp2, 3, 2], center = 0, chamfer = 1.5, edges = EDGE_FR_RT);
            }

            // Lower right stripe
            move([0 - (wall_thickness + spacing) - ncp1, 17, 3]) {
                cuboid([length + ncp2, 37 + ncp1, 2 + ncp1], center = 0, chamfer = 1.5, edges = EDGE_BK_RT);
            }

            // Lower left stripe
            move([0 - (wall_thickness + spacing) - ncp1, 0 - (wall_thickness + spacing + ncp1), 3]) {
                cuboid([length + ncp2, 3, 2], center = 0, chamfer = 1.5, edges = EDGE_FR_RT);
            }
        }

        move([0 - wall_thickness - spacing - ncp2, 0 - spacing - (wall_thickness / 2), wall_thickness + ncp1]) {
            cuboid([length - 1 + ncp2, width - 2, 10], center = 0);
        }
    }
}

// Main case rendering module
module render_case(x, y, z, standoff_height, show_lower_case, show_upper_case, print_position)
{
    upper_case_height = 3;
    lower_case_height = 16;

    if (show_upper_case == "Yes") render_upper_case(x, y, z, upper_case_height, lower_case_height, standoff_height, print_position);
    if (show_lower_case == "Yes") render_lower_case(x, y, z, upper_case_height, lower_case_height);
}