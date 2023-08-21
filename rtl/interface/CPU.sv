module CPU (
 I2C_interface.CPU pins
 );
 
 always @ (posedge pins.CLK , negedge pins.RST)
  begin
   if(!pins.RST)
    begin
	 pins.slave_addr_reg <= 0 ; 
	 pins.byte_cnt_reg <= 0 ;   
	 pins.transmit_data <= 0 ;
	 pins.config_reg <= 0 ;       
	 pins.mode_reg <= 0 ;        
	end
   else
    begin
	 pins.slave_addr_reg <= pins.slave_addr ; 
	 pins.byte_cnt_reg <= pins.num_bytes ;   
	 pins.transmit_data <= pins.tx_data ;
	 pins.config_reg <= {pins.RESET, pins.ABORT, pins.TX_IE, pins.RX_IE, pins.INT_CLR, pins.START} ;       
	 pins.mode_reg <= {pins.BPS[1], pins.BPS[0], pins.ADR_MOD, 0, pins.RW_MOD, 0, 0, 0} ;        
	end
  end
  
endmodule
