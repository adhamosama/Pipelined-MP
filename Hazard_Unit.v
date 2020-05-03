`timescale 1ns / 1ps

module Hazard_Unit(StallF, StallD, BranchD, ForwardAD, ForwardBD, FlushE, ForwardAE, ForwardBE,
						 MemtoRegE, RegWriteE, RegWriteM, RegWriteW, RsD, RtD, RsE, RtE, WriteRegE,
						 WriteRegM, WriteRegW, MemtoRegM);

input BranchD, MemtoRegE, MemtoRegM, RegWriteE, RegWriteM, RegWriteW;
input [4:0] WriteRegE, WriteRegM, WriteRegW, RsD, RtD, RsE, RtE;
output StallF, StallD, FlushE;
output [1:0] ForwardAD, ForwardBD, ForwardAE, ForwardBE;

reg [1:0] ForwardAD, ForwardBD, ForwardAE, ForwardBE;
reg StallF, StallD, FlushE, lwstall, branchstall;

always @ ( BranchD or RsD or RtD or RsE or RtE or 
			  MemtoRegE or RegWriteE or RegWriteM or MemtoRegM or
			  RegWriteW or  WriteRegE or WriteRegM or WriteRegW)
//always
begin

	// Forwarding Data Hazards for Rs
	// Priority is given to the Memory stage because it has more recent data
	// Allow forwarding if Rs in Execute stage matches The reg to write in in the memory stage
	if (RsE != 0 && RsE == WriteRegM && RegWriteM )
		ForwardAE <= 2'b10;
	else if ( RsE != 0 && RsE == WriteRegW && RegWriteW )
		ForwardAE <= 2'b01;
	else
		ForwardAE <= 2'b00;

	// Forwarding Data Hazards for Rt
	//same logic for Rs
	if (RtE != 0 && RtE == WriteRegM && RegWriteM )
		ForwardBE <= 2'b10;
	else if ( RtE != 0 && RtE == WriteRegW && RegWriteW )
		ForwardBE <= 2'b01;
	else
		ForwardBE <= 2'b00;

	// Solving Data Hazards by Stalling the Pipeline
	lwstall = ( (RsD == RtE) || (RtD == RtE) ) && MemtoRegE;
	
	// Solving Control Hazard by Stalling
	// TODO check if EM are right instead of DE
	branchstall = BranchD && RegWriteE && (WriteRegE == RsD || WriteRegE == RtD)
					|| BranchD && MemtoRegM && (WriteRegM == RsD || WriteRegM == RtD);
					
	// stall and flush if we any stall is taken
	StallF <= lwstall || branchstall;
	StallD <= lwstall || branchstall;
	FlushE <= lwstall || branchstall;
	
	// Forwarding in case of Control Hazard to the decode 
	ForwardAD = (RsD != 0) && (RsD == WriteRegM) && RegWriteM;
	ForwardBD = (RtD != 0) && (RtD == WriteRegM) && RegWriteM;

end
	
	
endmodule
