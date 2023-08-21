`include "../../macros/macros.v"
module I2C_tb (I2C_interface.TB pins);

 /* Internal Signals */
 int I ;
 logic [7:0] data_arr [5:0] ;

 /* Initial Block */
 initial
  begin
   reset();
   data_arr[0] = 15 ;
   data_arr[1] = 16 ;
   data_arr[2] = 33 ;
   write_operation(3,data_arr);
   #(`SYS_CLK_PER*5)
   $finish;
  end
  
 /* Tasks */
 task reset;
  begin
   force  pins.RST = 0 ;
   #(`SYS_CLK_PER)
   force  pins.RST = 1 ;
  end
 endtask
 
 task write_operation;
  input [7:0] n_bytes;
  input [7:0] data [5:0];
  begin
   pins.START = 1 ;
   pins.ADR_MOD = `I2C_7_bit_Addressing ;
   pins.RW_MOD  = `I2C_write_operation  ;
   pins.BPS = `HighSpeed_Mode ;
   pins.slave_addr = 10'h009 ;
   pins.num_bytes = n_bytes ;
   for(I = 0 ; I < n_bytes ; I = I+1)
    begin
      //#(`HighSpeed_Mode_PER*2); // I need a better condition here
      wait(!pins.data_vld);
      pins.tx_data = data[I] ;
      wait(pins.data_vld);
      if(pins.data_write==data[I])
       $display("Successful write operation byte %d",I);
      else
       $display("Failed write operation byte %d",I);
    end
  end
 endtask

endmodule
