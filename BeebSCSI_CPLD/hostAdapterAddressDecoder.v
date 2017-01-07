`timescale 1ns / 1ps
/************************************************************************
	 hostAdapterAddressDecoder.v

	 Host adapter address decoder for BeebSCSI
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
module hostAdapterAddressDecoder(
	input [7:0] bbc_ADDRESS,
	input cleanPGFC,
	input n1MHZE,
	input nRW,
	
	output nFC40RD,
	output nFC41RD,
	output nFC40WR,
	output nFC42WR,
	output nFC43WR,
	output nFC44WR
	);

	// The 74LS138 dual 4-bit decoder IC is not clocked, so here we have to
	// use combinational logic to emulate it.  The 74LS138 uses negative logic
	// on the outputs.
	assign nFC40RD = ((bbc_ADDRESS == 8'h40) & ~nRW & ~n1MHZE & cleanPGFC) ? 1'b0 : 1'b1;
	assign nFC41RD = ((bbc_ADDRESS == 8'h41) & ~nRW & ~n1MHZE & cleanPGFC) ? 1'b0 : 1'b1;
	
	assign nFC40WR = ((bbc_ADDRESS == 8'h40) & nRW & ~n1MHZE & cleanPGFC) ? 1'b0 : 1'b1;
	assign nFC42WR = ((bbc_ADDRESS == 8'h42) & nRW & ~n1MHZE & cleanPGFC) ? 1'b0 : 1'b1;
	assign nFC43WR = ((bbc_ADDRESS == 8'h43) & nRW & ~n1MHZE & cleanPGFC) ? 1'b0 : 1'b1;
	assign nFC44WR = ((bbc_ADDRESS == 8'h44) & nRW & ~n1MHZE & cleanPGFC) ? 1'b0 : 1'b1;

endmodule
