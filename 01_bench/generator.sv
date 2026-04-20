class generator;
    transaction trans;
    mailbox #(transaction) gen2drv;
    
    function new(mailbox #(transaction) gen2drv); 
        this.gen2drv = gen2drv;
    endfunction
    
    task run_randomize(int count); // Sửa cú pháp task
        $display("The time that we want to count (randomize)  is: %0d", count); // Sửa typo display
        repeat(count) begin
            trans = new();
            if(!trans.randomize()) $fatal("The transaction is error");
            trans.print("test_random");
            gen2drv.put(trans);
            #1;
        end
    endtask // Không dùng end nữa

    task run_directed(string type_coin); // Sửa cú pháp task
        trans = new();
        // Sửa thành toán tử gán (=) và sửa tên biến i_nickle
        trans.i_nickle  = 1'b0;        
        trans.i_dime    = 1'b0;
        trans.i_quarter = 1'b0;
        $display("The transaction have been drived to 0"); // Sửa typo

        if(type_coin == "5")  trans.i_nickle  = 1'b1; // Chú ý bạn dư dấu cách ở chữ "5 "
        if(type_coin == "10") trans.i_dime    = 1'b1;
        if(type_coin == "25") trans.i_quarter = 1'b1;

        trans.print("test_direct");
        gen2drv.put(trans);
        $display("Put the transaction is done"); // Sửa typo
    endtask 

endclass
