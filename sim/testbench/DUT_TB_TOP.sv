`include "../../macros/macros.v"
module DUT_TB_TOP;

 bit CLK ;
 /* Clocks generation */
 always #(`SYS_CLK_PER/2) CLK = ~ CLK ;
 
 /* Interface Instantiation */
 I2C_interface intrf (CLK) ;
 
 /* Test Bench Instantiation */
 I2C_tb test (intrf) ;
 
 /* Desgin Under Test Instantiation */
 I2C_Master_TOP I2C_Master_model (intrf);
 I2C_Slave_TOP I2C_Slave_model (intrf);
 CPU CPU_model (intrf);
 User_Module User_model (intrf);
 
endmodule
