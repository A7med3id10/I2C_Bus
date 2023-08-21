module I2C_Slave_TOP (
 I2C_interface.I2C_Slave pins
 );
 
 /* Internal Signals */
 wire i_sda , o_sda ;
 wire ACK_Gen_enable, done_ack, outing_ack  ;
 wire Acknowledgement_Condition , Not_Acknowledgement_Condition ;
 wire byte_receiver_enable , done_receiving ; 
 wire [7:0] received_byte ;
 
 
 /* Modules Instantiations */
 
 Slave_Control_FSM U0_Slave_CTRL (
 .CLK(pins.CLK),
 .RST(pins.RST),
 .SCL(pins.SCL),
 .Start_Condition(pins.start),
 .Stop_Condition(pins.stop),
 .Slave_Address(pins.Slave_Address), 
 .done_receiving(done_receiving),
 .received_byte(received_byte), 
 .data_in(pins.data_read) , 
 .data_out(pins.data_write) ,
 .byte_receiver_enable(byte_receiver_enable),
 .ACK_Gen_enable(ACK_Gen_enable),
 .done_ack(done_ack),
 .ACK_OUT(Acknowledgement_Condition),
 .N_ACK_OUT(Not_Acknowledgement_Condition),
 .data_vld(pins.data_vld),
 .r_w(pins.r_w)
 );
 
 Tri_State_Buffer U0_BUF_SDA (
 .inout_port(pins.SDA), 
 .enable_out(outing_ack && !done_ack),  
 .TX_port(o_sda),     
 .RX_port(i_sda)
 );
 
 Byte_Receiver U0_Byte_RX (
 .SDA(i_sda),
 .CLK(pins.SCL),           
 .RST(pins.RST),
 .enable(byte_receiver_enable),
 .received_byte(received_byte),
 .done_receiving(done_receiving)
 );
 
 Start_Stop_Detector U0_STR_STP_Detc (
 .CLK(pins.CLK),
 .RST(pins.RST),
 .SDA(i_sda),
 .SCL(pins.SCL),
 .Start_Condition(pins.start),
 .Stop_Condition(pins.stop) 
 );

 Acknowledgement_Generator U0_ACK_GEN (
 .SDA(o_sda),
 .done_ack(done_ack),
 .outing_ack(outing_ack),
 .CLK(pins.SCL),                 
 .RST(pins.RST),
 .enable(ACK_Gen_enable),
 .Acknowledgement_Condition(Acknowledgement_Condition),
 .Not_Acknowledgement_Condition(Not_Acknowledgement_Condition) 
 );
 
endmodule
