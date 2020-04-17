/************************************************************************

	material.scad
    
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

module material(material_number)
{
    if ((global_current_material == 0 || global_current_material == 1) && material_number == 1) {
        color("black") children();
    }

    if ((global_current_material == 0 || global_current_material == 2) && material_number == 2) {
        color("white") children();
    }

    if ((global_current_material == 0 || global_current_material == 3) && material_number == 3) {
        color("blue") children();
    }

    if ((global_current_material == 0 || global_current_material == 4) && material_number == 4) {
        color("green") children();
    }

    if ((global_current_material == 0 || global_current_material == 5) && material_number == 5) {
        color("red") children();
    }

    if (material_number < 1 || material_number > 5) {
        color("purple") children();
    }
}