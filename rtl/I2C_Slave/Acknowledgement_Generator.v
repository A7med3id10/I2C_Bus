module Acknowledgement_Generator (
 output reg  SDA,
 output reg  done_ack, outing_ack ,
 input  wire CLK,                   // SCL is the Clock of this block
 input  wire RST,
 input  wire enable,
 input  wire Acknowledgement_Condition,
 input  wire Not_Acknowledgement_Condition
 );
 
 /* SDA from 1 To 0 ---> ACK   Through CLK Pulse */ 
 /* SDA from 1 To 1 ---> N_ACK Through CLK Pulse */ 
 
 always @ (posedge CLK , negedge RST)
  begin
   if(!RST)
    begin
     SDA  <= 1 ;
	 outing_ack<= 0 ;
	 done_ack <= 0 ;
	end
   else if (enable)
    begin
	 SDA <= (Acknowledgement_Condition & !Not_Acknowledgement_Condition)? 0 : 1 ;
	 outing_ack<= 1 ;
	 done_ack <= outing_ack;
	end
   else
    begin
	 SDA  <= 1 ;
	 outing_ack<= 0 ;
	 done_ack <= 0 ;
	end	
  end 

endmodule