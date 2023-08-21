module Tri_State_Buffer (
 inout  wire inout_port ,
 input  wire enable_out ,
 input  wire TX_port    ,
 output wire RX_port
 );
 
 assign inout_port = enable_out ? TX_port : 1'bz ;
 
 assign RX_port    = inout_port ;

endmodule
