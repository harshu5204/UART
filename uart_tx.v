module uart_tx(
    Clk,
    Rst_n,
    TxEn,
    TxData,
    TxDone,
    Tx,
    Tick,
    NBits
);

input Clk, Rst_n, TxEn, Tick;
input [3:0] NBits;
input [7:0] TxData;
output reg Tx;
output TxDone;

parameter IDLE = 1'b0, WRITE = 1'b1;
reg State, Next;
reg TxDone = 1'b0;
reg write_enable = 1'b0;
reg start_bit = 1'b1;
reg stop_bit = 1'b0;
reg [4:0] Bit = 5'b00000;
reg [1:0] counter = 2'b00;
reg [7:0] in_data = 8'b00000000;
reg [1:0] R_edge;
wire D_edge;

always @ (posedge Clk or negedge Rst_n)
begin
    if (!Rst_n) State <= IDLE;
    else State <= Next;
end

always @ (State or D_edge or TxData or TxDone)
begin
    case(State)
        IDLE: if(D_edge) Next = WRITE;
              else Next = IDLE;
        WRITE: if(TxDone) Next = IDLE;
               else Next = WRITE;
        default: Next = IDLE;
    endcase
end

always @ (State)
begin
    case (State)
        WRITE: write_enable <= 1'b1;
        IDLE: write_enable <= 1'b0;
    endcase
end

always @ (posedge Tick)
begin
    if (write_enable)
    begin
        counter <= counter+1;
        if(start_bit & !stop_bit)
        begin
            Tx <= 1'b0;
            in_data <= TxData;
        end
        if ((counter == 2'b11) & (start_bit))
        begin
            start_bit <= 1'b0;
            Tx <= in_data[0];
            in_data <= {1'b0, in_data[7:1]};
        end
        if ((counter == 2'b11) & (!start_bit) & (Bit < NBits-1))
        begin
            in_data <= {1'b0, in_data[7:1]};
            Bit <= Bit+1;
            Tx <= in_data[0];
            start_bit <= 1'b0;
            counter <= 2'b00;
        end
        if ((counter == 2'b11) & (Bit == NBits-1) & (!stop_bit))
        begin
            Tx <= 1'b1;
            counter <= 2'b00;
            stop_bit <= 1'b1;
        end
        if ((counter == 2'b11) & (Bit == NBits-1) & (stop_bit))
        begin
            Bit <= 4'b0000;
            TxDone <= 1'b1;
            counter <= 2'b00;
        end
    end
end

always @ (posedge Clk or negedge Rst_n)
begin
    if(!Rst_n) R_edge <= 2'b00;
    else R_edge <= {R_edge[0], TxEn};
end

assign D_edge = !R_edge[1] & R_edge[0];

endmodule
