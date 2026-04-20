interface vending_if(input logic i_clk, input logic i_rst_n);
    logic i_nickle, i_dime, i_quarter, o_soda;
    logic [2:0] o_change;
endinterface
