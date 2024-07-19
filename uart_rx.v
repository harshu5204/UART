module uart_rx(
    Clk,
    Rst_n,
    RxEn,
    RxData,
    RxDone,
    Rx,
    Tick,
    NBits
);

input Clk, Rst_n, RxEn, Rx, Tick;
input [3:0] NBits;
output RxDone;
output [7:0] RxData;

parameter IDLE = 1'b0, READ = 1'b1;
reg [1:0] State, Next;
reg read_enable = 1'b1;
reg start_bit = 1'b1;
reg RxDone = 1'b0;
reg [4:0] Bit = 5'b00000;
reg [1:0] counter = 2'b00;
reg [7:0] Read_data = 8'b00000000;
reg [7:0] RxData;

always @ (posedge Clk or negedge Rst_n)
    if (!Rst_n) State <= IDLE;
    else State <= Next;

always @ (State or Rx or RxEn or RxDone)
begin
    case(State)
        IDLE: if(!Rx & RxEn) Next = READ;
        READ: if(RxDone) Next = IDLE;
        default: Next = IDLE;
    endcase
end

always @ (State or RxDone)
begin
    case (State)
        READ: read_enable <= 1'b1;
        IDLE: read_enable <= 1'b0;
    endcase
end

always @ (posedge Tick)
begin
    if (read_enable)
    begin
        RxDone <= 1'b0;
        counter <= counter+1;
        if ((counter == 2'b11) & (start_bit))
        begin
            start_bit <= 1'b0;
            counter <= 2'b00;
        end
        if ((counter == 2'b11) & (!start_bit) & (Bit < NBits-1))
        begin
            Bit <= Bit+1;
            Read_data <= {Rx, Read_data[7:1]};
            counter <= 2'b00;
        end
        if ((counter == 2'b11) & (Bit == NBits-1) & (Rx))
        begin
            Bit <= 4'b0000;
            RxDone <= 1'b1;
            counter <= 2'b00;
            start_bit <= 1'b1;
        end
    end
end

always @ (posedge Clk)
begin
    if (NBits == 4'b1000) RxData <= Read_data;
    else if (NBits == 4'b0111) RxData <= {1'b0, Read_data[7:1]};
    else if (NBits == 4'b0110) RxData <= {1'b0, 1'b0, Read_data[7:2]};
end

endmodule
