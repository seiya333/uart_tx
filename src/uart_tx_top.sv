`default_nettype none
module uart_top(
    input wire CLK,
    input wire RST,
    output wire TX
);
    typedef enum {
        STATE_SEND,
        STATE_WAIT,
        STATE_FIN
    } state_type;
    state_type  tx_state, tx_next_state;

    logic [7:0] tx_data_in;
    logic start;
    logic tx_flag;
    logic tx_active;

    uart_tx #(
        .clk_divide(234) // 27,000,000 (27Mhz) / 115200 Baud rate
    ) uart_tx_inst (
        .CLK(CLK),
        .START(start),
        .TX_DATA_IN(tx_data_in),
        .RST(RST),
        .RX_CHECK(1'b0), // Assuming RX_CHECK is not used in this context
        .TX(TX),
        .TX_ACTIVE(tx_active),
        .TX_FLAG(tx_flag)
    );

    assign tx_data_in = 8'h41; // Example data to send

    always_comb begin
        tx_next_state = tx_state;
        start = 1'b0;
        if(tx_state == STATE_SEND) begin
            tx_next_state = STATE_WAIT; // Move to wait state after sending
            start = 1'b1; // Trigger transmission
        end else if(tx_state == STATE_WAIT) begin
            if(~tx_active) begin
                tx_next_state = STATE_FIN; // Move to finish state when transmission is not active
            end
        end
    end

    always_ff @(posedge CLK) begin
        if (RST) begin
            tx_state <= STATE_SEND; // Reset to initial state
        end else begin
            tx_state <= tx_next_state;
        end
    end
endmodule