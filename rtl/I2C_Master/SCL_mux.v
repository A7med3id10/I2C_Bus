module SCL_mux (
 input  wire in0, in1 ,
 input  wire sel,
 output wire out
);

 assign out = sel? in1 : in0 ;
 
endmodule