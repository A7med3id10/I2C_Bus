module Byte_Receiver (
 input  wire       SDA,
 input  wire       CLK,                // SCL is the Clock of this block
 input  wire       RST,
 input  wire       enable,
 output reg  [7:0] received_byte,
 output wire       done_receiving
 );
 
 /* An I2C output data is usually send out from bit 7 to 0 (MSB to LSB)   */
 /* In case of Sending Address (MSB to LSB) of Address then Read/Write bit */
 
 reg [3:0] i ;
 
 always @ (posedge CLK , negedge RST)
  begin
   if(!RST)
    begin
     received_byte <= 0 ;
	   i <= 0 ;
	  end
   else if(enable)
    begin
     received_byte[7-i] <= SDA ;
	   i <= i+1 ;
	  end
   else 
    begin
     received_byte <= 0 ;
	   i <= 0 ;
	  end
  end
  
 assign done_receiving = (i==7) & !CLK ;

endmodule
