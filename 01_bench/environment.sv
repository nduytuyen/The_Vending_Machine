class environment;
    
    generator gen ; 
    driver drv    ;
    mailbox #(transaction) gen2drv;
    
    virtual vending_if vif;
    
    function new(virtual vending_if vif);
        this.vif = vif               ; 
	gen2drv = new()              ;
        gen     = new(gen2drv)       ; 
	drv     = new(vif, gen2drv)  ;
    endfunction
    
    task start_driver();
        fork
            drv.run();
        join_none
    endtask

endclass
