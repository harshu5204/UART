module uart_baud(
    Clk,
    Rst_n,
    Tick,
    BaudRate
);

input Clk;
input Rst_n;
input [15:0] BaudRate;
output Tick;
reg [15:0] baudRateReg = 16'd0; // Initialize to 0

always @(posedge Clk or negedge Rst_n)
begin
    if (!Rst_n) baudRateReg <= 16'd0;
    else if (Tick) baudRateReg <= 16'd0;
    else baudRateReg <= baudRateReg + 1'b1;
end

assign Tick = (baudRateReg == BaudRate);

endmodule
