class driver;
    transaction trans;
    mailbox #(transaction) gen2drv;
    virtual vending_if vif;

    function new(virtual vending_if vif, mailbox #(transaction) gen2drv);
        this.vif = vif;
        this.gen2drv = gen2drv;
    endfunction

    task drive_pins(transaction t);
        @(posedge vif.i_clk);
        vif.i_nickle  <= t.i_nickle;
        vif.i_dime    <= t.i_dime;
        vif.i_quarter <= t.i_quarter;
                
        @(posedge vif.i_clk);
        // drop button
        vif.i_nickle  <= 1'b0;
        vif.i_dime    <= 1'b0;
        vif.i_quarter <= 1'b0;
    endtask

    task checker_task(input bit [2:0] exp_data); // Sửa cú pháp task
        if(vif.o_soda == 1'b1 && vif.o_change == exp_data)
            $display("[%0t] PASSED: Soda=1, Change=%b", $time, vif.o_change);
        else 
            // Sửa lại đúng tên tín hiệu o_soda và o_change
            $display("[%0t] FAILED: Soda=%b, actual_data=%b, expect_data=%b", $time, vif.o_soda, vif.o_change, exp_data);
    endtask

    task run(); 
        $display("[%0t] [DRIVER] Driver bat dau run Mailbox...", $time);
        forever begin
            gen2drv.get(trans);
            $display("[%0t] [DRIVER] Nhan duoc Trans ngau nhien: N:%b D:%b Q:%b", $time, trans.i_nickle, trans.i_dime, trans.i_quarter);
            drive_pins(trans);
            repeat(2) @(posedge vif.i_clk);
        end 
    endtask
endclass
