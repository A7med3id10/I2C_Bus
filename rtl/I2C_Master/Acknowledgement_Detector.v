module Acknowledgement_Detector (
 input  wire CLK, RST,
 input  wire wait_ack,    // Like an enable signal for the block
 input  wire SDA,BUS_CLK,
 output reg  ACK, N_ACK, 
 output wire ack_detected_new,
 output wire take_ack,
 output reg  ack_detected_old
 );
 
 /* The purpose of this block is to detect acknowledge signal */
 /* SDA from 1 To 0 ---> ACK   Through SCL Clock Pulse */ 
 /* SDA from 1 To 1 ---> N_ACK Through SCL Clock Pulse */ 
 
 always @ (posedge CLK, negedge RST)
  begin
   if(!RST)
    begin
	 ACK   <= 0 ;
	 N_ACK <= 0 ;
	end
   else if(wait_ack)
    begin
	 ACK   <= (!SDA)? 1 : 0 ;
	 N_ACK <= (SDA) ? 1 : 0 ;
	end
   else
    begin
	 ACK   <= 0 ;
	 N_ACK <= 0 ;
	end
  end
  
 assign ack_detected_new = ACK || N_ACK ;

 always @ (posedge BUS_CLK, negedge RST)
  begin
	if(!RST)
	 ack_detected_old <= 0 ;
	else
	 ack_detected_old <= ack_detected_new ;
  end

  assign take_ack = ack_detected_old  ;


endmodule
