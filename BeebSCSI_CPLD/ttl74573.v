`timescale 1ns / 1ps
/************************************************************************
	 ttl74573.v

	 TTL 74573 logic implementation for BeebSCSI
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
module ttl74573(
	input [7:0] D,
	input LE,
	
	output reg [7:0] Q
	);

	// Note: We can't support output enable here since the module is buried
	// we have to rely on the databus bidirectional control for high-Z state

	initial begin
		Q <= 8'b0;
	end

	// Latch on the negative edge of LE (i.e. High-to-Low transition)
	always @ (negedge LE)
	begin
		if (!LE) Q <= D;
	end

endmodule
