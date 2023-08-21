module Bus_Control_FSM (
 input  wire       CLK,RST,
 input  wire [9:0] SADR,
 input  wire [7:0] i_transmit_data,
 input  wire       RW_MODE,
 input  wire       Start_Condition,Stop_Condition,
 input  wire       Send_Data,
 output reg  [7:0] o_received_data,
 output reg        wait_ack,
 output reg        SCL_sel,
 output reg        SDA
 );
 
 /* This block is responsible for transmission of Bytes */
 
 reg [7:0] transmission_byte ;
 reg [3:0] i  ;
 
 // Take care that Send_Data , Stop_Condition Signals will change very fast ---> write_trigger to solve it
 // trigger is used to stretch Send_Data in bit 0, Stop_Condition in bit 1 signals across bus CLK pulse 
 reg [1:0] trigger ;
 always@(posedge CLK, negedge RST, posedge Send_Data, posedge Stop_Condition)
  begin
   if(!RST)
    trigger <= 0 ;
   else if(Send_Data || Stop_Condition)
    trigger[0] <= Send_Data ;
	  trigger[1] <= Stop_Condition ;
  end
 
 
 /* Moore FSM One-hot encoding */
 typedef enum logic [5:0] {
  IDLE               = 6'b000001 ,
  START_TRANSMISSION = 6'b000010 ,
	SEND_ADDRESS       = 6'b000100 ,
	WAIT_ACK           = 6'b001000 ,
	SEND_DATA          = 6'b010000 ,
	END_TRANSACTION    = 6'b100000 
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
  
 /* up-counter for bits transmission */
 always @ (posedge CLK , negedge RST)
  begin
   if(!RST)
    i <= 0 ;
   else
    begin
	   case(current_state)
	    SEND_ADDRESS: i <= (i!=7)? i+1 : 0 ;
	    SEND_DATA:    i <= (i!=7)? i+1 : 0 ;
	   endcase
	  end
  end
 
 /* Next State Block */
 always @ (*)
  begin
   case(current_state)
    IDLE:               next_state = (!Start_Condition)? IDLE : START_TRANSMISSION ;
	
    START_TRANSMISSION: next_state = SEND_ADDRESS ;
	
    SEND_ADDRESS:       next_state = (i!=7) ? SEND_ADDRESS : WAIT_ACK ;
	
	WAIT_ACK:           
	 begin
	  case(trigger)
	  2'b01:   next_state = SEND_DATA ;
	  2'b10:   next_state = END_TRANSACTION ;
	  default: next_state = WAIT_ACK ;
	  endcase
	 end
									 
    SEND_DATA:          next_state = (i!=7) ? SEND_DATA : WAIT_ACK ;
	
    END_TRANSACTION:    next_state = IDLE ;
   endcase
  end
  
 /* Outputs Block */
 always @ (*)
  begin
   SCL_sel = 1 ;
   SDA = 1 ;
   wait_ack = 0 ;
   transmission_byte = 0 ;
   o_received_data   = 0 ;
   case(current_state)
    IDLE:
	 begin
	  SCL_sel = 1 ;
      SDA = 1 ;
	 end
	 
    START_TRANSMISSION:
     begin
	  SCL_sel = 1 ;
      SDA = 0 ; // From 1 To 0
	  transmission_byte = {SADR[6:0],RW_MODE} ;
	 end
	 
    SEND_ADDRESS: 
     begin
	  transmission_byte = {SADR[6:0],RW_MODE} ;
	  SCL_sel = 0 ; 
      SDA = transmission_byte[7-i] ;
     end
	 
    WAIT_ACK:
     begin
	    SCL_sel = 0 ; 
	    //SDA = 0 ;
	    wait_ack = 1 ;
	    transmission_byte = i_transmit_data ;
     end
	 
    SEND_DATA:
     begin
	    transmission_byte = i_transmit_data ;
	    SCL_sel = 0 ; 
      SDA = transmission_byte[7-i] ;
     end
	 
    END_TRANSACTION:  
     begin
	    SCL_sel = 1 ;
      SDA = 1 ;  // From 0 To 1
     end	
   endcase
  end
 
endmodule
