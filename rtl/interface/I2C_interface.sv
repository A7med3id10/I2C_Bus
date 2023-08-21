interface I2C_interface (input logic CLK, RST);
 /* Configuration inputs */
 logic RESET,ABORT,TX_IE,RX_IE,INT_CLR,START,ADR_MOD,RW_MOD;
 logic [1:0] BPS;
 logic [9:0] slave_addr;            
 logic [7:0] num_bytes;        
 logic [7:0] tx_data;
 
 /* CPU -> Master */
 logic [9:0] slave_addr_reg;            
 logic [7:0] byte_cnt_reg;
 logic [7:0] transmit_data;
 logic [5:0] config_reg;
 logic [7:0] mode_reg;
 
 /* Master -> CPU */
 logic [7:0] cmd_status_reg;
 logic       start_ack;
 logic       int_n;
 logic       transmit_data_requested;
 logic       received_data_valid;
 logic [7:0] received_data;
 
 /* I2C Bus */
 wire       SCL,SDA;        
 
 /* User -> Slave */
 logic       stretch_on;  
 logic [9:0] Slave_Address;  
 logic [7:0] data_read;      
 
 /* Slave -> User */
 logic [7:0] data_write;
 logic       start;
 logic       stop;
 logic       data_vld;
 logic       r_w;
 
 modport CPU (
  input  CLK, RST,
  input  RESET,ABORT,TX_IE,RX_IE,INT_CLR,START,ADR_MOD,RW_MOD,
  input  BPS,slave_addr,num_bytes,tx_data,
  output slave_addr_reg,byte_cnt_reg,transmit_data,config_reg,mode_reg,   
  input  cmd_status_reg,start_ack,int_n,transmit_data_requested,received_data_valid,received_data
 );
 
 modport I2C_Master (
  input  CLK, RST,
  input  slave_addr_reg,byte_cnt_reg,transmit_data,config_reg,mode_reg,   
  output cmd_status_reg,start_ack,int_n,transmit_data_requested,received_data_valid,received_data,
  inout  SCL,SDA
 );
 
 modport I2C_Slave (
  input  CLK, RST,
  input  stretch_on ,Slave_Address,data_read, 
  output data_write,start,stop,data_vld,r_w,
  inout  SCL,SDA
 );
 
 modport User_Module (
  input  CLK, RST,
  output stretch_on ,Slave_Address,data_read,data_write, 
  input  start,stop,data_vld,r_w
 );
 
 /*clocking cb @ (posedge CLK)
  output RESET,ABORT,TX_IE,RX_IE,INT_CLR,START,ADR_MOD,RW_MOD,
  output BPS,slave_addr,num_bytes,tx_data,
 endclocking*/
 
 modport TB (
  output   RST,
  output   RESET,ABORT,TX_IE,RX_IE,INT_CLR,START,ADR_MOD,RW_MOD,
  output   BPS,slave_addr,num_bytes,tx_data,
  input    data_write,start,stop,data_vld,r_w
 );
 
endinterface
