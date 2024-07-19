module uart_main(
Clk ,
Rst_n ,
Tx ,
TxData ,
RxData ,
);



input Clk ;
input Rst_n ;
input [7:0] TxData ;
output Tx ;
output [7:0] RxData ;

wire RxDone ;
wire TxDone ;
wire tick ;
wire TxEn ;
wire RxEn ;
wire [3:0] NBits ;
wire [15:0] BaudRate ;
reg Rx ;

assign RxEn = 1'b1;
assign TxEn = 1'b1;

assign BaudRate = 2'd2;

assign NBits = 4'b1000;

always@(posedge tick)
Rx <= Tx;
uart_rx RX(.Clk(Clk) ,.Rst_n(Rst_n) ,.RxEn(RxEn) ,.RxData(RxData) ,.RxDone(RxDone) ,.Rx(Rx) ,.Tick(tick) ,.NBits(NBits));

uart_tx TX(.Clk(Clk) ,.Rst_n(Rst_n) ,.TxEn(TxEn) ,.TxData(TxData) ,.TxDone(TxDone) ,.Tick(tick) ,.NBits(NBits),.Tx(Tx));

uart_baud BAUDGEN(.Clk(Clk) ,.Rst_n(Rst_n) ,.Tick(tick) ,.BaudRate(BaudRate));

endmodule

