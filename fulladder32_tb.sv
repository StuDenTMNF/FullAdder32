`timescale 1ns/1ns

module fulladder32_tb;
    // Объявление тестовых сигналов
    logic [31:0] a_i, b_i;
    logic        carry_i;
    logic [31:0] sum_o;
    logic        carry_o;
    
    // Ожидаемые значения (для проверки)
    logic [31:0] expected_sum;
    logic        expected_carry;
    
    // Сумматор для тестирования
    fulladder32 dut (
        .a_i(a_i),
        .b_i(b_i),
        .carry_i(carry_i),
        .sum_o(sum_o),
        .carry_o(carry_o)
    );
    
    initial begin
        // Инициализация
        $dumpfile("dump.vcd");
        $dumpvars(0, fulladder32_tb);
        
        // Тест 1: Нулевые входы
        a_i = 0; b_i = 0; carry_i = 0;
        expected_sum = 0; expected_carry = 0;
        #10;
        check_results("Test 1: Zero inputs");
        
        // Тест 2: Сложение с переносом
        a_i = 32'h0000_0001; 
        b_i = 32'h0000_0001; 
        carry_i = 1;
        expected_sum = 3; 
        expected_carry = 0;
        #10;
        check_results("Test 2: 1+1+carry");
        
        // Тест 3: Максимальные значения без переполнения
        a_i = 32'h7FFF_FFFF; 
        b_i = 32'h7FFF_FFFF; 
        carry_i = 0;
        expected_sum = 32'hFFFF_FFFE;
        expected_carry = 0;
        #10;
        check_results("Test 3: Max no overflow");
        
        // Тест 4: Переполнение
        a_i = 32'hFFFF_FFFF; 
        b_i = 32'hFFFF_FFFF; 
        carry_i = 0;
        expected_sum = 32'hFFFF_FFFE;
        expected_carry = 1;
        #10;
        check_results("Test 4: Full overflow");
        
        // Тест 5: Случайные значения
        for (int i = 0; i < 5; i++) begin
            a_i = $urandom();
            b_i = $urandom();
            carry_i = $random() % 2;
            {expected_carry, expected_sum} = a_i + b_i + carry_i;
            #10;
            check_results($sformatf("Test 5.%0d: Random", i));
        end
        
        // Тест 6: Цепной перенос
        a_i = 32'h1111_1111; 
        b_i = 32'h1111_1111; 
        carry_i = 0;
        expected_sum = 32'h2222_2222;
        expected_carry = 0;
        #10;
        check_results("Test 6: Chain carry");
        
        // Тест 7: Граничный случай (32-й бит)
        a_i = 32'h8000_0000; 
        b_i = 32'h8000_0000; 
        carry_i = 0;
        expected_sum = 0;
        expected_carry = 1;
        #10;
        check_results("Test 7: MSB addition");
        
        $display("All tests completed!");
        $finish;
    end
    
    // Автоматическая проверка результатов
    task check_results(input string test_name);
        if (sum_o !== expected_sum || carry_o !== expected_carry) begin
            $error("%s FAILED", test_name);
            $display("  Inputs:  a_i=%h b_i=%h carry_i=%b", a_i, b_i, carry_i);
            $display("  Outputs: sum_o=%h (exp: %h) carry_o=%b (exp: %b)",
                    sum_o, expected_sum, carry_o, expected_carry);
            $display("  Difference: %d", expected_sum - sum_o);
            $fatal(1);
        end
        else begin
            $display("%s PASSED", test_name);
        end
    endtask
endmodule