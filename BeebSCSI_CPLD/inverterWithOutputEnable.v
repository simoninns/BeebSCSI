`timescale 1ns / 1ps
/************************************************************************
	 inverterWithOutputEnable.v

	 Inverter with output enable for BeebSCSI
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
module inverterWithOutputEnable(
    input [7:0] D,
    input OE,
	 input nInvertFlag,
    output [7:0] Q
    );

	// If we are connected to the external bus D should be inverted, if connected
	// to the internal bus D should not be inverted
	wire [7:0] data;
	assign data = (nInvertFlag) ? D : ~D;

	// If output is enabled, Q = data otherwise Q = 0.
	// If output is disabled we should high-Z, but since the module
	// is buried we have to rely on the bidirectional control to implement
	// high-Z
	assign Q = (OE) ? data : 8'b0;

endmodule
