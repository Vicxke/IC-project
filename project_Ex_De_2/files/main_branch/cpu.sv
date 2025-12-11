
/*
Changelog: 
- (Sky) 2025-04-19: Add PC MUX ports   
- (Sky) 2025-04-23: Add Decode Stage ports   
- (Sky) 2025-05-05: Instantiate branch prediction buffer module   
- (Sky) 2025-05-13: Add prediction mechanism to fetch_stage   
- (Sky) 2025-05-15: Add squash signal following JAL, and ID stage MUX for inserting NOP 
- (Sky) 2025-05-16: Add define FPGA_SYN. In order to transmit program code from uart to prg memory 
- (Sky) 2025-05-20: Add a 2.5 second timer to avoid unknown program length problem. Fix latches. 
- (Sky) 2025-05-22: Add forwarding to decode stage for branch resolution. Add squash after JALR NOP
- (Sky) 2025-05-26: Half clock frequency for timing violation on FPGA. Add reset delay module.
- (Sky) 2025-05-27: Replace clk dividor with clk wizard mmcm
- (Sky) 2025-06-05: Change UART packing order
*/

`timescale 1ns / 1ps

import common::*;
//`define FPGA_SYN //for onboard FPGA validation

module cpu(
    input clk_100M,
    input reset,    //from switch, active high
    input uart_tx,
    output exception_LED
);

    logic [31:0] program_mem_address;
    logic [31:0] program_mem_address_cpu; //for switching control from uart to cpu
    logic        program_mem_write_enable_uart;
    logic        next_program_mem_write_enable_uart;
    logic program_mem_write_enable;      //no overwriting of initialized program memory   
    logic [31:0] program_mem_write_data ; //nothing can change the instruction memory content
    logic [31:0] program_mem_read_data;
    
    logic [5:0] decode_reg_rd_id;
    logic [31:0] decode_data1;
    logic [31:0] decode_data2;
    logic [31:0] decode_immediate_data;
    control_type decode_control;
    

    logic select_target_pc;
    logic actual_taken;
    logic [31:0] calculated_target_pc;

    logic [31:0] execute_alu_data;
    control_type execute_control;
    logic [31:0] execute_memory_data;
    
    logic [31:0] memory_memory_data;
    logic [31:0] memory_alu_data;
    control_type memory_control;
    
    logic [5:0] wb_reg_rd_id;
    logic [31:0] wb_result;
    logic wb_write_back_en;    
    
    if_id_type if_id_reg;
    id_ex_type id_ex_reg;
    ex_mem_type ex_mem_reg;
    mem_wb_type mem_wb_reg;

   
    /* change by Soumya Biswas
    adding logic for new module
    **/
    if_id_type if_id_reg_next;
    control_type control_hdu;
    logic [2:0] forward_data,forward_data2;
    logic [31:0] mux_data1;
    logic [31:0] mux_data2;
    logic [31:0] exe_immediate;
    logic [5:0] reg_rd_exe;
    logic exception_flag_mem;
    logic squash_after_J, squash_for_wrong_pdctn, squash_after_JALR; 
    logic [31:0] mux_if_id_instruction_data; 
    logic resolve, predict_taken;
    logic if_compflg,id_compflg,hdu_compflg,ex_compflg;
    logic [4:0] rs1_id,rs2_id;
    logic clk;
    logic reset_n;
 
   `ifdef FPGA_SYN
    logic rstn_async;
    logic io_data_valid;
    logic [7:0] io_data_packet;
    assign rstn_async = ~reset;

    clk_wiz_0 inst_clk_wiz_0
   (
    // Clock out ports
    .clk_out1(clk),     // output clk_out1
    // Status and control signals
    .resetn(rstn_async), // input resetn
   // Clock in ports
    .clk_in1(clk_100M)      // input clk_in1
    );

    sync_rstn inst_sync_rstn(
        //inputs
        .clk(clk), 
        .rstn(rstn_async), 
        .gated(1'b1), 
        .scan_sel(1'b0), 
        //outputs
        .rstn_sync(reset_n), 
        .rstn_ok()
         );


    uart i_uart_rx(
        //inputs
        .clk(clk),
        .reset_n(reset_n),
        .io_rx(uart_tx),
        //outputs
        .io_data_valid(io_data_valid),
        .io_data_packet(io_data_packet) 
    );

    //Writing binary code into program memory
    logic uart_done; //transmission of program done
    logic [10:0] counter_wr_prgmem; //0~1023
    logic [10:0] next_counter_wr_prgmem; //0~1023
    logic [28:0] counter_8sec; //count for 8 seconds, then start program execution
    logic [28:0] next_counter_8sec; //count for 8 seconds, then start program execution
    logic [23:0] mem_tmp_buffer, next_mem_tmp_buffer;
    logic [31:0] next_program_mem_write_data;
    
    always_ff @(posedge clk) begin
        if (!reset_n) begin
            counter_wr_prgmem    <= 0;
            counter_8sec       <= 0;
            mem_tmp_buffer       <= 0;
            program_mem_write_data <= 0;
            program_mem_write_enable_uart <= 0;
        end
        else begin
            counter_wr_prgmem   <= next_counter_wr_prgmem;    
            counter_8sec      <= next_counter_8sec;
           mem_tmp_buffer      <= next_mem_tmp_buffer;
            program_mem_write_data <= next_program_mem_write_data;
            program_mem_write_enable_uart <= next_program_mem_write_enable_uart;
        end
    end

    always_comb begin
        if(io_data_valid == 1)  
            next_counter_wr_prgmem = counter_wr_prgmem + 1; 
        else if(counter_wr_prgmem == 11'd1024 )
            next_counter_wr_prgmem = 11'd1024;  //transmission over
        else
            next_counter_wr_prgmem = counter_wr_prgmem;    
    end

    always_comb begin
        if(counter_8sec == 29'd400000000)
            next_counter_8sec = 29'd400000000;
        else
            next_counter_8sec = counter_8sec + 1;
    end

    always_comb begin
        next_program_mem_write_data   = program_mem_write_data;
        next_mem_tmp_buffer           = mem_tmp_buffer;
        next_program_mem_write_enable_uart = 0;
        if(io_data_valid)   begin
            case(counter_wr_prgmem % 4) 
            0:  begin
                //next_mem_tmp_buffer[7:0] = io_data_packet;
                next_mem_tmp_buffer[31:24] = io_data_packet;
            end
            1:  begin
                //next_mem_tmp_buffer[15:8] = io_data_packet;
                next_mem_tmp_buffer[23:16] = io_data_packet;
            end    
            2: begin
                //next_mem_tmp_buffer[23:16] = io_data_packet;
                next_mem_tmp_buffer[15:8] = io_data_packet;
            end
            3: begin
                //next_program_mem_write_data = {io_data_packet, mem_tmp_buffer[23:0]};
                next_program_mem_write_data = {mem_tmp_buffer[31:8],io_data_packet};
                next_program_mem_write_enable_uart = 1;
            end
            endcase
        end
    end

    assign uart_done = (counter_8sec == 29'd400000000)? 1'd1 : 1'd0; // 8 seconds for FPGA
    `else
        assign clk = clk_100M;
        assign reset_n = ~reset;
        logic uart_done = 1; //initialize to 1 for pure simulation
        logic [10:0] counter_wr_prgmem = 0; //initialize for pure simulation
    `endif 
   
    always_ff @(posedge clk) begin
        if (!reset_n) begin
            if_id_reg <= '0;
            id_ex_reg <= '0;
            ex_mem_reg <= '0;
            mem_wb_reg <= '0;
        end
        else if(!uart_done) begin
            if_id_reg <= '0;
            id_ex_reg <= '0;
            ex_mem_reg <= '0;
            mem_wb_reg <= '0;
        end
        else begin
            if_id_reg.pc <= if_id_reg_next.pc;
            if_id_reg.instruction <= if_id_reg_next.instruction;
            if_id_reg.compflg <= if_id_reg_next.compflg;
            
            id_ex_reg.reg_rd_id <= reg_rd_exe;
            id_ex_reg.data1 <= mux_data1;
            id_ex_reg.data2 <= mux_data2;
            id_ex_reg.immediate_data <= exe_immediate;
            id_ex_reg.control <= control_hdu;
            id_ex_reg.compflg <= hdu_compflg;
            
            ex_mem_reg.reg_rd_id <= id_ex_reg.reg_rd_id;
            ex_mem_reg.control <= execute_control;
 //           ex_mem_reg.control <= id_ex_reg.control;
            ex_mem_reg.alu_data <= execute_alu_data;
            ex_mem_reg.memory_data <= execute_memory_data;
            ex_mem_reg.compflg <= ex_compflg;
            
            mem_wb_reg.reg_rd_id <= ex_mem_reg.reg_rd_id;
            mem_wb_reg.memory_data <= memory_memory_data;
            mem_wb_reg.alu_data <= memory_alu_data;
            mem_wb_reg.control <= memory_control;
        end
    end


    program_memory inst_mem(
        .clk(clk),        
        .byte_address(program_mem_address),
        .write_enable(program_mem_write_enable),
        .write_data(program_mem_write_data),
        .pc_addr_exception_flag(),
        .read_data(program_mem_read_data)
    );
   //MUX to select who has control over PC 
    assign program_mem_address = (uart_done == 0)? (counter_wr_prgmem[9:0] == 0)? 32'd0 :
                                 {22'd0, counter_wr_prgmem[9:0]} - 1 : 
                                 program_mem_address_cpu;

    assign program_mem_write_enable = (uart_done == 0)? program_mem_write_enable_uart : 1'b0;
    
    fetch_stage inst_fetch_stage(
        .clk(clk), 
        .reset_n(reset_n),
        .uart_done(uart_done),
        .forward_data(forward_data),
        .forward_data2(forward_data2),
        .predict_taken(predict_taken),
        .select_target_pc(select_target_pc),  //J-type is also taken into account
        .calculated_target_pc(calculated_target_pc),
        .data(program_mem_read_data),    //this is used to decode for B type and JAL, JALR
        .address(program_mem_address_cpu),
        .squash_for_wrong_pdctn(squash_for_wrong_pdctn),
        .compflg(if_compflg)
    );
    
    gshare_predictor inst_gshare_predictor(
    //inputs
    .clk(clk),           
    .reset_n(reset_n),       
    .branch_pc(program_mem_address),     
    .resolve(resolve),    
    .actual_taken(select_target_pc), // 1 == branch was actually taken
    //output
    .predict_taken(predict_taken) 
    );
 /*   
    branch_prediction_buffer inst_branch_prediction_buffer(
    //inputs
    .clk(clk),
    .rst_n(reset_n),         
    .byte_address(program_mem_address), 
    .resolve(resolve),       
    .actual_taken(select_target_pc),  // 1 if branch was taken, 0 if not
    //output
    .predict_taken(predict_taken)  //prediction for current PC branching
    );
 */   
    decode_stage inst_decode_stage(
        .clk(clk), 
        .reset_n(reset_n),    
        .instruction(if_id_reg.instruction),
        .pc(if_id_reg.pc),
        .compflg(if_id_reg.compflg),
        .write_en(wb_write_back_en),
        .write_id(wb_reg_rd_id),        
        .write_data(wb_result),
        .mux_data1(mux_data1),
        .mux_data2(mux_data2),
        .reg_rd_id(decode_reg_rd_id),
        .read_data1(decode_data1),
        .read_data2(decode_data2),
        .immediate_data(decode_immediate_data),
        .control_signals(decode_control),
        .select_target_pc(select_target_pc),    //J-type is also taken into account
        .resolve(resolve),                      //only high for B-type
        .calculated_target_pc(calculated_target_pc),
        .squash_after_J(squash_after_J), //sqaush from ID following a sequeatially fetched Jump
        .squash_after_JALR(squash_after_JALR),
        .compflg_out(id_compflg),
        .rs1_id(rs1_id),
        .rs2_id(rs2_id)
    );
    assign  mux_if_id_instruction_data = (squash_after_J || squash_for_wrong_pdctn || squash_after_JALR)? 
                                         32'b00000000000000000000000000010011 :
                                         program_mem_read_data; 
    
    /*change by Soumya Biswas 
    adding hazard detection and forward mux unit
    **/
    hazard_detection_unit inst_hazard_detection_unit(
        .clk(clk), 
        .reset_n(reset_n),
        .read1_id(rs1_id),
        .read2_id(rs2_id),
        .rd_mem(ex_mem_reg.reg_rd_id),
        .rd_ex(id_ex_reg.reg_rd_id),
        .rd_wb(wb_reg_rd_id),
        .control_id(decode_control),
        .control_ex(execute_control),
        .control_mem(memory_control),
        .control_out(control_hdu),
        .forward_data(forward_data),
        .forward_data2(forward_data2)
    );
 
    forward_mux inst_forward_mux(
    .clk(clk),
    .reset_n(reset_n),
    .forward_data(forward_data),
    .forward_data2(forward_data2),
    .decode_data1(decode_data1),
    .decode_data2(decode_data2),
    .compflg_id(id_compflg),
    .decode_immediate(decode_immediate_data),
    .exe_out(execute_alu_data),
    .mem_alu_out(memory_alu_data),
    .mem_mem_out(memory_memory_data),
    .wb_out(wb_result),
    .reg_rd_id(decode_reg_rd_id),
    .reg_rd_exe(reg_rd_exe),
    .mux_data1(mux_data1),
    .mux_data2(mux_data2),
    .exe_immediate(exe_immediate),
    .compflg_out(hdu_compflg)
    );
   
    execute_stage inst_execute_stage(
        .clk(clk), 
        .reset_n(reset_n),
        .data1(id_ex_reg.data1),
        .data2(id_ex_reg.data2),
        .immediate_data(id_ex_reg.immediate_data),
        .control_in(id_ex_reg.control),
        .compflg_in(id_ex_reg.compflg),
        .program_counter(if_id_reg.pc),
        .control_out(execute_control),
        .alu_data(execute_alu_data),
        .memory_data(execute_memory_data),
        .compflg_out(ex_compflg)          
    );
    
    
    mem_stage inst_mem_stage(
        .clk(clk), 
        .reset_n(reset_n),
        .alu_data_in(ex_mem_reg.alu_data),
        .memory_data_in(ex_mem_reg.memory_data),
        .control_in(ex_mem_reg.control),
        .compflg(ex_mem_reg.compflg),
        .control_out(memory_control),
        .memory_data_out(memory_memory_data),
        .alu_data_out(memory_alu_data),
        .exception_flag(exception_flag_mem) //added exception flag for mem stage. change by soumya

    );
    always_comb begin
        if((forward_data==3'b111)||(forward_data2==3'b111))
        begin
            if_id_reg_next.pc <= if_id_reg.pc;
            if_id_reg_next.instruction <= if_id_reg.instruction;
            if_id_reg_next.compflg <= if_id_reg.compflg;
        end
        else
        begin
            if_id_reg_next.pc <= program_mem_address;
            if_id_reg_next.instruction <= mux_if_id_instruction_data;
            if_id_reg_next.compflg <= if_compflg;
            
        end
    end

    assign wb_reg_rd_id = mem_wb_reg.reg_rd_id;
    assign wb_write_back_en = mem_wb_reg.control.reg_write;
    assign wb_result = mem_wb_reg.control.mem_read ? mem_wb_reg.memory_data : mem_wb_reg.alu_data;
    
endmodule