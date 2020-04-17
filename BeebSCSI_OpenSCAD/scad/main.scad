/************************************************************************

	main.scad
    
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

include <pcb77.scad>
include <case.scad>

// Rendering quality
$fn=10;

// Render the PCB?
show_PCB = "Yes"; // [Yes, No]

// Render the lower case?
show_lower_case = "Yes"; // [Yes, No]

// Render the upper case?
show_upper_case = "Yes"; // [Yes, No]

// Position the upper case for printing?
print_position = "No"; // [No, Yes]

// Stand-off height of the upper case
standoff_height_upper = 0; // [0, 10, 20, 30, 40]

// Stand-off height of the PCB case
standoff_height_pcb = 0; // [0, 10, 20, 30, 40]

// Choose materials to render (0 = all)
material_choice = 0; // [0, 1, 2, 3, 4, 5]

// Single or multi-material
print_type = "Multi"; // [Multi, Single]

// Main function
global_current_material = material_choice;
global_print_type = print_type;

// Render the PCB
if (show_PCB == "Yes") render_pcb(0, 0, 1 + standoff_height_pcb);

// Render the case
render_case(0, 0, 0, standoff_height_upper, show_lower_case, show_upper_case, print_position);