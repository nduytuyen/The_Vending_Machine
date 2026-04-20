`define FINISH 40_000

`include "01_bench/vending_if.sv"
`include "01_bench/transaction.sv"
`include "01_bench/generator.sv"
`include "01_bench/driver.sv"
`include "01_bench/environment.sv"

module tbench;
    logic i_clk;
    logic i_reset;
    
    initial begin
        i_clk = 0;
        forever #5 i_clk = ~i_clk;
    end

    initial begin
        i_reset = 0;   
        #100 i_reset = 1;
    end

    // set Interface
    vending_if vif(i_clk, i_reset);
    environment env;
    
    // connect DUT
    vending_machine dut (
        .i_clk(vif.i_clk),
        .i_rst_n(vif.i_rst_n),
        .i_nickle(vif.i_nickle),
        .i_dime(vif.i_dime),
        .i_quarter(vif.i_quarter),
        .o_soda(vif.o_soda),
        .o_change(vif.o_change)
    );
    
    initial begin: proc_dump_shm
       $shm_open("wave.shm");
       $shm_probe(dut, "AS");
    end
    
       // Run Test Flow
    initial begin
        vif.i_nickle = 0;
        vif.i_dime = 0;
        vif.i_quarter = 0;

        wait(i_reset == 1); 
        #10;
        env = new(vif);
        $display("\n--- START SIMULATION ---");
    
        env.start_driver(); // Driver chạy ngầm
        
        // =========================================================
        // PHA 1: DIRECTED TESTS - Quét cạn các trạng thái (D_20 -> D_40)
        // =========================================================

        // Case 1: Nạp 10c + 10c = 20c -> Trạng thái D_20 (Thối 0c - 3'b000)
        $display("\n[TEST CASE 1] Target: 20c (State D_20)");
        env.gen.run_directed("10");
        repeat(4) @(posedge vif.i_clk); // Luôn phải có delay giữa các lần nạp xu
        env.gen.run_directed("10");
        
        wait(vif.o_soda == 1'b1);
        env.drv.checker_task(3'b000);
        repeat(5) @(posedge vif.i_clk); // Đợi FSM reset về IDLE an toàn

        // Case 2: Nạp thẳng 25c = 25c -> Trạng thái D_25 (Thối 5c - 3'b001)
        $display("\n[TEST CASE 2] Target: 25c (State D_25)");
        env.gen.run_directed("25");
        
        wait(vif.o_soda == 1'b1);
        env.drv.checker_task(3'b001);
        repeat(5) @(posedge vif.i_clk);

        // Case 3: Nạp 5c + 25c = 30c -> Trạng thái D_30 (Thối 10c - 3'b010)
        $display("\n[TEST CASE 3] Target: 30c (State D_30)");
        env.gen.run_directed("5");
        repeat(4) @(posedge vif.i_clk);
        env.gen.run_directed("25");
        
        wait(vif.o_soda == 1'b1);
        env.drv.checker_task(3'b010);
        repeat(5) @(posedge vif.i_clk);

        // Case 4: Nạp 10c + 25c = 35c -> Trạng thái D_35 (Thối 15c - 3'b011)
        $display("\n[TEST CASE 4] Target: 35c (State D_35)");
        env.gen.run_directed("10");
        repeat(4) @(posedge vif.i_clk);
        env.gen.run_directed("25");
        
        wait(vif.o_soda == 1'b1);
        env.drv.checker_task(3'b011);
        repeat(5) @(posedge vif.i_clk);

        // Case 5: Nạp 5c + 10c + 25c = 40c -> Trạng thái trần D_40 (Thối 20c - 3'b100)
        $display("\n[TEST CASE 5] Target: 40c (Max State D_40)");
        env.gen.run_directed("5");
        repeat(4) @(posedge vif.i_clk);
        env.gen.run_directed("10");
        repeat(4) @(posedge vif.i_clk);
        env.gen.run_directed("25");
        
        wait(vif.o_soda == 1'b1);
        env.drv.checker_task(3'b100);
        
        // =========================================================
        // PHA 2: RANDOM TESTS - Stress Test hệ thống
        // =========================================================
        $display("\n[RANDOM PHASE] Running 20 random transactions...");
        repeat(8) @(posedge vif.i_clk);
        
        // Tăng số lượng test ngẫu nhiên lên 20 để "tra tấn" hệ thống
        env.gen.run_randomize(20); 
        
        // Chờ một khoảng thời gian đủ dài để Driver lấy hết 20 transactions từ Mailbox ra chạy
        repeat(80) @(posedge vif.i_clk); 

        $display("\n--- SIMULATION FINISHED ---");
        $finish; 
    end

    initial begin // check time out
        #`FINISH;
        $display("TIMEOUT!");
        $finish;
    end
endmodule
