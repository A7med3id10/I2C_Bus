module I2C_Master_TOP (
 I2C_interface.I2C_Master pins
 );
 
 wire i_sda,o_sda, SCL_sel;
 wire Start_Condition,Stop_Condition,Send_Data,wait_ack;
 wire ACK,N_ACK,ack_detected_new,ack_detected_old,take_ack;
 wire BUS_CLK,clk_div_en;
 wire [10:0] clk_div_ratio;
 
 assign clk_div_en = 1 ;
 
 Master_Control_FSM U0_Master_Control_FSM (
 .CLK(pins.CLK),
 .RST(pins.RST),
 .BCNT(pins.byte_cnt_reg),
 .clk_div_ratio(clk_div_ratio),
 .RESET(pins.config_reg[5]), 
 .ABORT(pins.config_reg[4]), 
 .TX_IE(pins.config_reg[3]), 
 .RX_IE(pins.config_reg[2] ), 
 .INT_CLR(pins.config_reg[1]), 
 .START(pins.config_reg[0]),
 .ACK_in(ACK),
 .N_ACK_in(N_ACK),
 .take_ack(take_ack),
 .wait_ack(wait_ack),
 .START_ACK_out(pins.start_ack),
 .BPS(pins.mode_reg[7:6]),          //bit per second --> determine SCL Speed
 .ADR_MOD(pins.mode_reg[5]), 
 .RW_MODE(pins.mode_reg[3]),
 .I2C_BUSY(pins.cmd_status_reg[7]), 
 .TX_DONE(pins.cmd_status_reg[6]), 
 .RX_DONE(pins.cmd_status_reg[5]), 
 .TX_ERR(pins.cmd_status_reg[4]), 
 .RX_ERR(pins.cmd_status_reg[3]), 
 .ABORT_ACK(pins.cmd_status_reg[2]),
 .o_int_n(pins.int_n),
 .Start_Condition(Start_Condition),
 .Send_Data(Send_Data),
 .Stop_Condition(Stop_Condition)
 );
 
 Bus_Control_FSM U0_Bus_Control_FSM (
 .SADR(pins.slave_addr_reg),
 .RW_MODE(pins.mode_reg[3]),
 .i_transmit_data(pins.transmit_data),
 .o_received_data(pins.received_data),
 .CLK(BUS_CLK),
 .RST(pins.RST),
 .Start_Condition(Start_Condition),
 .Send_Data(Send_Data),
 .wait_ack(wait_ack),
 .Stop_Condition(Stop_Condition), 
 .SCL_sel(SCL_sel),
 .SDA(o_sda) 
 );
 
 SCL_mux U0_SCL (
 .in0(BUS_CLK),
 .in1(1'b1),
 .sel(SCL_sel),
 .out(pins.SCL)
 );
 
 Clock_Divider U0_CLK_DIV (
 .I_ref_clk(pins.CLK),
 .I_rst_n(pins.RST),
 .I_clk_en(clk_div_en),
 .I_div_ratio(clk_div_ratio),
 .O_div_clk(BUS_CLK)
 );
 
 Tri_State_Buffer U0_BUF_SDA (
 .inout_port(pins.SDA), 
 .enable_out(!wait_ack),  
 .TX_port(o_sda),     
 .RX_port(i_sda)
 );
 
 Acknowledgement_Detector U0_Slave_Bus_SDA (
 .CLK(pins.CLK), 
 .RST(pins.RST),
 .wait_ack(wait_ack),
 .SDA(i_sda),
 .ACK(ACK), 
 .N_ACK(N_ACK),
 .ack_detected_new(ack_detected_new),
 .ack_detected_old(ack_detected_old),
 .BUS_CLK(BUS_CLK),
 .take_ack(take_ack)
  );

endmodule
