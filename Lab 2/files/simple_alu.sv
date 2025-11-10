import tb_pkg::*;


module simple_alu(
    input  logic            clock,      
    input  logic            reset_n,
    input  logic            start,
    input  logic[7:0]      a,
    input  logic[7:0]      b,
    input  opcode           mode_select,       
    output logic[7:0]      c
    );

    //Internal Logic
    logic [7:0] internal_result,n_internal_result;


//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//Sequential Logic
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
    always_ff @(posedge clock or negedge reset_n) begin
        // Asynchronous reset
        if(~reset_n) begin
<<<<<<< HEAD
            
=======
            internal_result <= '0;
>>>>>>> fcb6e9c36ca378a9c1e194402ca71982e22cf3c6
        end
        else begin
            internal_result <= n_internal_result;
        end
 
    end

//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//Combinational logic
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

    always_comb begin
    
        c <= internal_result;
<<<<<<< HEAD
        case (mode_select)

            //ADD
            ADD:  begin 
                n_internal_result <= a+b;
                
            end
            //SUB
            SUB:  begin 
                n_internal_result <= a-b;                      
            end
            //MUL
            MUL:  begin 
                n_internal_result <= a*b;
            end
            //DIV
            DIV:  begin 
                n_internal_result <= a/b;                        
            end
            //MOD
            MOD:  begin 
                n_internal_result <= a%b;
            end

        endcase
=======
        if (start) begin // -------------------------- added start detection
            case (mode_select)

                //ADD
                ADD:  begin 
                    n_internal_result <= a+b;
                    
                end
                //SUB
                SUB:  begin 
                    n_internal_result <= a-b;                      
                end
                //MUL
                MUL:  begin 
                    n_internal_result <= a*b;
                end
                //DIV
                DIV:  begin 
                    n_internal_result <= a/b;                        
                end
                //MOD
                MOD:  begin 
                    n_internal_result <= a%b;
                end

            endcase
        end 
        else begin
            n_internal_result <= internal_result; // ------------- hold value when not started. otherwise the value goes to x again after the reset is released
        end
>>>>>>> fcb6e9c36ca378a9c1e194402ca71982e22cf3c6
    end



endmodule