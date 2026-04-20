module vending_machine (
    input  logic       i_clk,
    input  logic       i_rst_n,
    input  logic       i_nickle,
    input  logic       i_dime,
    input  logic       i_quarter,
    output logic       o_soda,
    output logic [2:0] o_change
);
    typedef enum logic [3:0] {
        IDLE = 4'd0, H_5  = 4'd1, H_10 = 4'd2, H_15 = 4'd3,
        D_20 = 4'd4, D_25 = 4'd5, D_30 = 4'd6, D_35 = 4'd7, D_40 = 4'd8
    } state_e;

    state_e current_state, next_state;
   
    // BLOCK1: COMBITIONAL LOGIC 
    always @(*) begin
        next_state = current_state;
        case (current_state)
            IDLE: if(i_nickle) next_state=H_5 ; else if(i_dime) next_state=H_10; else if(i_quarter) next_state=D_25;
            H_5:  if(i_nickle) next_state=H_10; else if(i_dime) next_state=H_15; else if(i_quarter) next_state=D_30;
            H_10: if(i_nickle) next_state=H_15; else if(i_dime) next_state=D_20; else if(i_quarter) next_state=D_35;
            H_15: if(i_nickle) next_state=D_20; else if(i_dime) next_state=D_25; else if(i_quarter) next_state=D_40;
            D_20, D_25, D_30, D_35, D_40: next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    // BLOCK2: SEQUENCIAL LOGIC
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) current_state <= IDLE;
        else          current_state <= next_state;
    end

    // BLOCK3: COMBITIONAL LOGIC 
    always @(*) begin
        o_soda = 1'b0; o_change = 3'b000;
        case (current_state)
            D_20:    begin o_soda = 1'b1; o_change = 3'b000; end
            D_25:    begin o_soda = 1'b1; o_change = 3'b001; end
            D_30:    begin o_soda = 1'b1; o_change = 3'b010; end
            D_35:    begin o_soda = 1'b1; o_change = 3'b011; end
            D_40:    begin o_soda = 1'b1; o_change = 3'b100; end
            default: begin o_soda = 1'b0; o_change = 3'b000; end
        endcase
    end
endmodule
