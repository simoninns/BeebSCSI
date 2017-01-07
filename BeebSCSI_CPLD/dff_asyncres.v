`timescale 1ns / 1ps
/************************************************************************
	 dff_asyncres.v

	 D-Type flip-flop with async reset for BeebSCSI
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
module dff_asyncres(
	input D,
	input CLK,
	input nCLR,
	output reg Q
	);

	always @ (posedge CLK or negedge nCLR)
	begin
		if (~nCLR) Q <= 1'b0;
		else Q <= D;
	end

endmodule
