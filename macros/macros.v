`timescale 1ns/1ps
/* Clock Speeds */
`define    SYS_CLK_Freq             24 *(10**6)
`define    Standard_Mode_Freq       100*(10**3)
`define    FullSpeed_Mode_Freq      400*(10**3)
`define    Fast_Mode_Freq           1  *(10**6)  
`define    HighSpeed_Mode_Freq      3.2*(10**6)

`define    SYS_CLK_PER              (10**9)/(`SYS_CLK_Freq       )    
`define    Standard_Mode_PER        (10**9)/(`Standard_Mode_Freq )     
`define    FullSpeed_Mode_PER       (10**9)/(`FullSpeed_Mode_Freq)  
`define    Fast_Mode_PER            (10**9)/(`Fast_Mode_Freq     )    
`define    HighSpeed_Mode_PER       (10**9)/(`HighSpeed_Mode_Freq) 


/* Operation modes */
`define    Standard_Mode            2'b00 
`define    FullSpeed_Mode           2'b01 
`define    Fast_Mode                2'b10 
`define    HighSpeed_Mode           2'b11 

`define    I2C_write_operation      0 //data from master to slave
`define    I2C_read_operation       1 //data from slave to master

`define    I2C_7_bit_Addressing     0
`define    I2C_10_bit_Addressing    1
