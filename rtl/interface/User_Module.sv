module User_Module (
 I2C_interface.User_Module pins
 );
 
 assign pins.Slave_Address = 10'h009 ;
 assign pins.stretch_on = 0 ;
 assign pins.data_read = 0 ;

endmodule
