import tb_pkg::*;
//------------------------------------------------------------------------------------------------
// Section 0
// We will use the Randomizer to generate random constrained stimuli.
//------------------------------------------------------------------------------------------------
class RANDOMIZER;
    // Task 2: Modify this class so that we can randomize 
    randc opcode op;
    randc logic[7:0] operand_1;
    randc logic[7:0] operand_2;

    constraint constraint_ADD { if (op == ADD) operand_1 + operand_2 <= 8'hff; } // ------------------- Added constraint to avoid overflow in ADD

    constraint constraint_SUB { if (op == SUB) operand_1 - operand_2 >= 0; } // ------------------- Added constraint to avoid negative results in SUB

    constraint constraint_MUL { if (op == MUL) operand_1 * operand_2 <= 8'hff; } // ------------------- Added constraint to avoid overflow in MUL

    constraint constraint_DIV { if (op == DIV) operand_2 != 0; } // ------------------- Added constraint to avoid division by zero in DIV

    constraint constraint_MOD { if (op == MOD) operand_2 != 0; } // ------------------- Added constraint to avoid division by zero in MOD
endclass


module simple_alu_tb;

    //------------------------------------------------------------------------------
    // Section 1
    // TB internal signals
    //------------------------------------------------------------------------------    
    logic           tb_clock;
    logic           tb_reset_n;
    logic           tb_start_bit;
    logic [7:0]    tb_operand_1;
    logic [7:0]    tb_operand_2;
    logic [7:0]    tb_result;
    logic [7:0]     tb_max_count;
    opcode          tb_opcode;
    

    //------------------------------------------------------------------------------
    // Section 2
    // Initialize signals
    //------------------------------------------------------------------------------    
    initial begin
        tb_clock = 0;
        tb_reset_n = 0;
        tb_start_bit = 0;
        tb_operand_1 = 0;
        tb_operand_2 = 0;
        tb_max_count = 0;
    end

    //------------------------------------------------------------------------------
    // Section 3
    // Instantiation of mysterybox DUT (Design Under Test)(The thing we want to look at :)
    //------------------------------------------------------------------------------
    simple_alu DUT (
        .clock(tb_clock),
        .reset_n(tb_reset_n),
        .start(tb_start_bit),
        .a(tb_operand_1),
        .b(tb_operand_2),
        .c(tb_result),
        .mode_select(tb_opcode)
    );
    RANDOMIZER randy = new();
    //------------------------------------------------------------------------------
    // Section 4
    // Clock generator.
    //------------------------------------------------------------------------------
    initial begin
        forever begin
            tb_clock = #5ns ~tb_clock;
        end
    end

    //------------------------------------------------------------------------------
    // Section 5
    // Task to generate Reset simulus
    //------------------------------------------------------------------------------
    task automatic reset(int delay, int length);
        $display("%0t reset():            Starting delay=%0d length=%0d",$time(), delay, length);
        //Repeat doing nothing for the clock delay
        repeat(delay) @(posedge tb_clock);

        tb_reset_n <= 0;
        $display("%0t reset():            Reset activated",$time());
        // Min 1 clock that reset bit is active. Use a do while loop for that!
        do begin
            @(posedge tb_clock);
        end while (--length > 0);
        tb_reset_n <= 1;
        $display("%0t reset():            Reset released",$time());
    endtask


    //------------------------------------------------------------------------------
    // Section 6
    // Task to generate start bit simulus
    //------------------------------------------------------------------------------
    task automatic start_bit(int delay, int length);
        $display("%0t start_bit():        Starting delay=%0d length=%0d",$time(), delay, length);
        // Min 1 clock synchronize start bit 
        do begin
            @(posedge tb_clock);
        end while (--delay > 0);
        tb_start_bit <= 1;
        $display("%0t start_bit():        Start bit activated ",$time());
        // Min 1 clock that start bit is active
        do begin
            @(posedge tb_clock);
        end while (--length > 0);
        tb_start_bit <= 0;
        $display("%0t start_bit():        Start bit released ",$time());
    endtask

    //------------------------------------------------------------------------------
    // Section 7
    // Task to simplify generation of signals.
    //------------------------------------------------------------------------------
   

    task automatic do_math(int a,int b,opcode code);
        if(randy.randomize() with {
            operand_1 inside {0,1,2,4,8,16,32,64,128,255};
            operand_2 inside {0,1,2,4,8,16,32,64,128,255};
            op inside {ADD, SUB, MUL, DIV, MOD};
        }) // -------------------- fixed constraint syntax
            $display("Randomization done! :D");
        else 
           $error("Failed to randomize :(");
        $display("%0t do_math:   Opcode:%0s     First number=%0d Second Value=%0d",$time(),code.name(), a, b);

        if (code == ADD)
            if (a + b > 8'hFF)
                $display("Test Result ADD = %0d", a + b);
            else
                $display("Test Result ADD fine");

        @(posedge tb_clock);
        tb_start_bit <= 1;
        tb_operand_1 <= a;
        tb_operand_2 <= b;
        tb_opcode<= code;
        @(posedge tb_clock);
        tb_operand_1 <= '0;
        tb_operand_2 <= '0;
        tb_start_bit <= 0;
    endtask



    //------------------------------------------------------------------------------
    // Section 8
    // Functional coverage definitions. Expand on this!!!
    //------------------------------------------------------------------------------
    
    covergroup basic_fcov @(negedge tb_clock);
        reset:coverpoint tb_reset_n{
            bins reset = { 0 };
            bins run=    { 1 };
        }
        // ---------------------------------- start
        tb_opcode_cp: coverpoint tb_opcode {
            bins add = { ADD };
            bins sub = { SUB };
            bins mul = { MUL };
            bins div = { DIV };
            bins mod = { MOD };
        }
        tb_operand_1: coverpoint tb_operand_1 {
            bins lower_half = { [0:127] };  
            bins upper_half = { [128:$] };  
            bins data_bin[] = { 0, 1, 2, 4, 8, 16, 32, 64, 128, 255 }; 
        }
        tb_operand_2: coverpoint tb_operand_2 {
            bins lower_half = { [0:127] };  
            bins upper_half = { [128:$] }; 
            bins data_bin[] = { 0, 1, 2, 4, 8, 16, 32, 64, 128, 255 };  
        }
        tb_operand_c: coverpoint tb_result {
            bins lower_half = { [0:127] };  
            bins upper_half = { [128:$] };  
            bins data_bin[] = { 0, 1, 2, 4, 8, 16, 32, 64, 128, 255 }; 
        }
        cross_operand_1: cross tb_operand_1,  tb_opcode_cp;
        cross_operand_2: cross tb_operand_2,  tb_opcode_cp;
        cross_operand_c: cross tb_operand_c,  tb_opcode_cp {
            ignore_bins impossible_mod_255 = binsof(tb_operand_c) intersect {255} && binsof(tb_opcode_cp.mod); // ------------------- Ignore impossible case
        }

        // --------------------------------- stop
    //Task 3: Expand our coverage...

    

    //Task 5: Add some crosses aswell to get some granularity going!
    endgroup: basic_fcov

    basic_fcov coverage_instance;




    //------------------------------------------------------------------------------
    // Section 9
    // Task 4: Now change your test case , and the number of times you run it so that your input stim
    //Here we will start our meat and potatoes of the test.
    //------------------------------------------------------------------------------
    task test_case();
        reset(.delay(0), .length(2));
        
        do_math(1, 2, ADD); // ------------------------- We kept the original values here for reference
        reset(.delay(10), .length(2));

        for (opcode op = ADD; op <= MOD; op = opcode'(op + 1)) begin // ---------------- loop through all opcodes
            
            repeat(10)
                do_math(randy.operand_1, randy.operand_2, op);

            

        end

        repeat(10) // -------------------------- 10 times because of 10 different special values
            do_math(0, randy.operand_2, ADD); // --------------------- so the result hits all the special values

        repeat(10) // -------------------------- 10 times because of 10 different special values
            do_math(randy.operand_1, 0, SUB);

        repeat(10) // -------------------------- 10 times because of 10 different special values
            do_math(1, randy.operand_2, MUL);
        
        repeat(10) // -------------------------- 10 times because of 10 different special values
            do_math(randy.operand_1, 1, DIV);

        repeat(10) // -------------------------- 10 times because of 10 different special values
            do_math(randy.operand_1, 255, MOD);

        reset(.delay(10), .length(2));
    
        // Task 1: The DUT is causing this assertion to be hit...
        assert (tb_result == 0) 
            $display ("Output reset");
        else
            $error("Reset doesn't clear output!");
            
        

    endtask

    //------------------------------------------------------------------------------
    // Section 10
    // Start test case from time 0
    //------------------------------------------------------------------------------
    initial begin
        // Here we can call our tests. Start by initializing our coverage!
        coverage_instance = new();
        
        //Uncomment this to try randomizing internal randomizable variables.
        //if(randy.randomize())
        //    $display("Randomization done! :D");
        //else 
        //    $error("Failed to randomize :(");
        $display("*****************************************************");
        $display("Starting Tests");
        $display("*****************************************************");
        test_case();
        $display("*****************************************************");
        $display("Tests Finished!");
        $display("*****************************************************");

        $stop;
    end

endmodule
