module Start_Stop_Detector (
 input  wire CLK,
 input  wire RST,
 input  wire SDA,
 input  wire SCL,
 output reg  Start_Condition,
 output reg  Stop_Condition 
 );
 
 /* The purpose of this block is to detect Start/Stop Conditions */
 /* SDA from 1 To 0 [- trans] while SCL is 1  ---> Start Condition  */ 
 /* SDA from 0 To 1 [+ trans] while SCL is 1 --->  Stop Condition   */
 
 reg [1:0] pulse_new, pulse_old ;          // bit1 for SDA , bit0 for SCL
 wire pos_pulse, neg_pulse, const_scl ;
 
 always @ (posedge CLK, negedge RST)
  begin
   if(!RST)
    begin
	 pulse_new <= 2'b10 ;
	 pulse_old <= 2'b10 ;
	end
   else
    begin
	 pulse_new <= {SDA,SCL} ;
	 pulse_old <= pulse_new ;
	 
	end
  end
 
 assign pos_pulse =  pulse_new[1] & !pulse_old[1] ;
 
 assign neg_pulse = !pulse_new[1] &  pulse_old[1] ;
 
 assign const_scl =  pulse_new[0] &  pulse_old[0] ;
 
 always @ (posedge CLK, negedge RST)
  begin
   if(!RST)
    begin
	 Start_Condition <= 0 ;
	 Stop_Condition  <= 0 ;
	end
   else
    begin
	 Start_Condition <= const_scl & neg_pulse ;
	 Stop_Condition  <= const_scl & pos_pulse ;
	end
  end
 
endmodule
