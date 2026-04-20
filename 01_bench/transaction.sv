class transaction;
    rand bit i_nickle;
    rand bit i_dime;
    rand bit i_quarter;
    
    constraint one_hot_coin {
        {i_nickle, i_dime, i_quarter} inside {3'b000, 3'b001, 3'b010, 3'b100};
    }

    function void print(string name="Trans");
        $display("[%0t] [%s] N:%b D:%b Q:%b", $time, name, i_nickle, i_dime, i_quarter);
    endfunction
endclass
