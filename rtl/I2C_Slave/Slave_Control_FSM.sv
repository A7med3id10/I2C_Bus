`include "../../macros/macros.v"
module Slave_Control_FSM (
 input  wire       CLK,                      // System Clock
 input  wire       RST, 
 input  wire       SCL, 
 input  wire       Start_Condition,
 input  wire       Stop_Condition, done_ack ,
 //input  wire       ACK_IN,
 //input  wire       N_ACK_IN,
 input  wire [9:0] Slave_Address, 
 input  wire       done_receiving,
 input  wire [7:0] received_byte, 
 input  wire [7:0] data_in ,      
 output reg  [7:0] data_out ,               // This remains 0 all throughout and is only updated when data_vld is high.
 output reg        byte_receiver_enable,
 output reg        ACK_Gen_enable,
 output reg        ACK_OUT,
 output reg        N_ACK_OUT,
 output reg        data_vld ,
 output reg        r_w 
 );
 
 reg read_operation, write_operation ;
  
 reg [7:0]  byte_counter  ;
 reg incr_counter, end_counter ;
 /* Byte Counter to count data bytes to be read or written for the I2C transaction */
 always @ (posedge CLK, negedge RST)
  begin
   if(!RST)
    begin
     byte_counter <= 0 ;
	  end
   else if(incr_counter)
    begin
	   byte_counter <= byte_counter + 1 ;
	  end
   else if(end_counter)
    begin
	   byte_counter <= 0 ;
	  end
  end


  /* Moore FSM One-hot encoding */
 typedef enum logic [5:0] {
  IDLE            = 6'b000001 ,
  Receive_Byte    = 6'b000010 ,
  SEND_ACK        = 6'b000100 ,
  Send_Byte       = 6'b001000 ,
  WAIT_ACK        = 6'b010000 
  } states_t;
 states_t current_state, next_state ;

 /* Current State Block */		
 always @ (posedge CLK, negedge RST)
  begin
   if(!RST)
    current_state <= IDLE ;
   else
    current_state <= next_state ;
  end
   
   
 /* Next State Block */
 always@(*)
  begin
   case(current_state)
    IDLE: next_state = (!Start_Condition)? IDLE : Receive_Byte ;
	  Receive_Byte: next_state = (Stop_Condition)? IDLE :
 	                           (!done_receiving)? Receive_Byte :
                               (|byte_counter)? SEND_ACK :                      // if byte_counter is 0, so the byte is address
							   (Slave_Address[6:0]!=received_byte[7:1])? IDLE : SEND_ACK ;
	//Check_Address: next_state = (Slave_Address[6:0]!=received_byte[7:1])? IDLE : SEND_ACK ;
	SEND_ACK: next_state = (!done_ack)? SEND_ACK :
                           (write_operation)? Receive_Byte :
	                       (read_operation)?  Send_Byte : IDLE ;
   endcase
  end
  
  
 /* Outputs Block */
 always@(posedge CLK, negedge RST)
  begin
   if(!RST)
    begin
	   read_operation  <= 0 ;
	   write_operation <= 0 ;
	   r_w <= 0 ;
	  end
   else if ( (~|byte_counter) && done_receiving )
    begin
	   r_w <= received_byte[0] ;
	   read_operation  <=(received_byte[0]==`I2C_read_operation) ? 1 : 0 ;
	   write_operation <=(received_byte[0]==`I2C_write_operation)? 1 : 0 ;
	  end
  end
  
 always@(*)
  begin
   byte_receiver_enable = 0 ;
   ACK_Gen_enable       = 0 ;
   ACK_OUT              = 0 ;
   N_ACK_OUT            = 0 ;
   incr_counter         = 0 ;
   end_counter          = 0 ;
   data_out             = 0 ;
   data_vld             = 0 ;
   
   case(current_state) 
    IDLE:
	   begin
	    end_counter = 1 ;
	   end
	 
	Receive_Byte:  
     begin
	    byte_receiver_enable = 1 ;
     end
	 
	SEND_ACK:   
   begin
	  ACK_Gen_enable = 1 ;
	  ACK_OUT = 1 ;
	  incr_counter = done_ack ;
	  data_out = received_byte ;
	  data_vld = byte_counter > 0 ;
   end
	 
    default: 
     begin
	    byte_receiver_enable = 0 ;
	    ACK_Gen_enable       = 0 ;
      ACK_OUT              = 0 ;
      N_ACK_OUT            = 0 ;
      incr_counter         = 0 ;
      end_counter          = 0 ;
	    data_out             = 0 ;
	    data_vld             = 0 ;
     end	 
   endcase
  end
 
endmodule
