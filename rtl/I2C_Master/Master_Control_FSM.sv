`include "../../macros/macros.v"
module Master_Control_FSM (
 input  wire        CLK,RST,
 input  wire [7:0]  BCNT,
 input  wire        RESET, 
 input  wire        ABORT, 
 input  wire        TX_IE, 
 input  wire        RX_IE, 
 input  wire        INT_CLR, 
 input  wire        START,
 input  wire        ACK_in,N_ACK_in,take_ack,wait_ack,
 //input  wire        send_done,
 input  wire        ADR_MOD, 
 input  wire        RW_MODE,
 input  wire [1:0]  BPS,                    // Bit Per Second
  
 output reg  [10:0] clk_div_ratio,
 //output reg         clk_div_en,
 output reg         START_ACK_out,
 output reg         Send_Data,
 //output reg         READ_ACK_out,
 output reg         I2C_BUSY, 
 output reg         TX_DONE, 
 output reg         RX_DONE, 
 output reg         TX_ERR, 
 output reg         RX_ERR, 
 output reg         ABORT_ACK,
 output reg         o_int_n,
 output reg         Start_Condition,Stop_Condition
 );
 
 reg [7:0]  byte_counter  ;
 reg transaction_complete ;
 reg incr_counter, end_counter ;
 
 
 /* Moore FSM One-hot encoding */
 typedef enum logic [7:0] {
     IDLE                = 8'b00000001 ,
     START_COMMUNICATION = 8'b00000010 ,
     COUNT_BYTES         = 8'b00000100 ,
	WRITE_DATA          = 8'b00001000 ,
	WAIT_ACK            = 8'b00010000 ,
	READ_DATA           = 8'b00100000 ,
	SEND_ACK            = 8'b01000000 ,
	END_TRANSACTION     = 8'b10000000
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
  
 /* Next State Block */
 always @ (*)
  begin
   case(current_state)
    IDLE:
     begin
	  next_state = (!START)? IDLE : START_COMMUNICATION ;
	 end
	 
    START_COMMUNICATION:
     begin
	  case({ACK_in,N_ACK_in})
	   2'b10:
	    begin
		case(RW_MODE)
	     `I2C_write_operation: next_state = !take_ack? START_COMMUNICATION : WRITE_DATA ;
          `I2C_read_operation : next_state = !take_ack? START_COMMUNICATION :READ_DATA  ;
	     endcase 
	    end
	   2'b01:   next_state = !take_ack? START_COMMUNICATION : IDLE ;
	   default: next_state = START_COMMUNICATION ;
	  endcase
	end
   
    WRITE_DATA:
     begin
	  next_state = (!wait_ack)? WRITE_DATA : COUNT_BYTES ;
	end
    
    COUNT_BYTES:
     begin
	 next_state = WAIT_ACK ;
	end
	 
	WAIT_ACK:                // put enable signal here ... take_ack
     begin
      case({ ACK_in  , N_ACK_in } )
	   2'b10:   next_state = !take_ack? WAIT_ACK :
                              ((byte_counter)==BCNT)? END_TRANSACTION : WRITE_DATA ;
	   2'b01:   next_state = !take_ack? WAIT_ACK : IDLE ;
	   default: next_state = WAIT_ACK ;
	 endcase
	 end
	 
    END_TRANSACTION:
     begin
	  next_state = IDLE ;
	 end
   endcase
  end
 
 /* Outputs Block */
 always @(*)
  begin
   START_ACK_out   = 0 ;
   //READ_ACK_out    = 0 ;
   Start_Condition = 0 ;
   Stop_Condition  = 0 ;
   transaction_complete = 0 ;
   incr_counter  = 0 ; 
   end_counter   = 0 ;
   I2C_BUSY  = 0 ; 
   TX_DONE   = 0 ; 
   RX_DONE   = 0 ; 
   TX_ERR    = 0 ; 
   RX_ERR    = 0 ; 
   ABORT_ACK = 0 ;
   o_int_n   = 1 ;
   Send_Data = 0 ;
   //clk_div_en = 1 ;
   clk_div_ratio = 0 ;
   
   case(BPS)
   `Standard_Mode:  clk_div_ratio = `SYS_CLK_Freq/(`Standard_Mode_Freq)   ;
   `FullSpeed_Mode: clk_div_ratio = `SYS_CLK_Freq/(`FullSpeed_Mode_Freq)  ;
   `Fast_Mode:      clk_div_ratio = `SYS_CLK_Freq/(`Fast_Mode_Freq)       ;
   `HighSpeed_Mode: clk_div_ratio = `SYS_CLK_Freq/(`HighSpeed_Mode_Freq)  ;
   endcase
   
   case(current_state)
    START_COMMUNICATION:
     begin
	  Start_Condition = 1 ;
	  START_ACK_out   = ACK_in ;
	 end
	 
    COUNT_BYTES:
     begin
	  incr_counter = 1 ;
	 end
	
    WRITE_DATA:
     begin
        Send_Data    = 1 ;
	 end
	 
	// SEND_ACK:
     // begin
	 // end
	 
    END_TRANSACTION:
     begin
	  Stop_Condition = 1 ;
	  end_counter = 1 ;
	 end
	 
	default:
	 begin
	  START_ACK_out   = 0 ;
      //READ_ACK_out    = 0 ;
      Start_Condition = 0 ;
      Stop_Condition  = 0 ;
      transaction_complete = 0 ;
      incr_counter  = 0 ; 
      end_counter   = 0 ;
      I2C_BUSY  = 0 ; 
      TX_DONE   = 0 ; 
      RX_DONE   = 0 ; 
      TX_ERR    = 0 ; 
      RX_ERR    = 0 ; 
      ABORT_ACK = 0 ;
      o_int_n   = 1 ;
	  Send_Data = 0 ;
	  //clk_div_en = 1 ;
	 end
   endcase
  end

endmodule
