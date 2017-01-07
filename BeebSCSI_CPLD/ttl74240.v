`timescale 1ns / 1ps
/************************************************************************
	 ttl74240.v

	 TTL 74240 logic for BeebSCSI
    BeebSCSI - BBC Micro SCSI Drive Emulator
    Copyright (C) 2016 Simon Inns

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
module ttl74240(
	input [7:0] A,
	input nOE,
	output [7:0] Y
	);

	// The 74LS240 buffer IC is not clocked, so here we have to use combinational
	// logic to emulate it.
	
	// Since this module is buried we can't high-Z, so instead we set
	// the output to zero (we have to rely on the databus bidirectional control)
	assign Y = (~nOE) ? ~A : 8'b0;

endmodule
