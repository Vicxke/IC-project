//------------------------------------------------------------------------------
// SERIAL_DATA uVC sequence driver 
//
// The driver generates serial data according to the configuration of the
// serial_data_config object and activates the start bit when specified.
// The driver can generate parity bits if parity_enable is set.
// 
//  The configuration of the serial interface is provided via the
//  serial_data_config object.
//
//------------------------------------------------------------------------------
class serial_data_driver extends uvm_driver #(serial_data_seq_item);
    `uvm_component_param_utils(serial_data_driver)

    // SERIAL_DATA uVC configuration object.
    serial_data_config  m_config;

    //------------------------------------------------------------------------------
    // The constructor for the component.
    //------------------------------------------------------------------------------
    function new(string name, uvm_component parent = null);
        super.new(name, parent);
        if (!uvm_config_db #(serial_data_config)::get(this,"","serial_data_config", m_config)) begin
            `uvm_fatal(get_name(),"Cannot find the VC configuration!")
        end
    endfunction

    //------------------------------------------------------------------------------
    // FUNCTION: build
    // The build phase for the component.
    //------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction : build_phase

    //------------------------------------------------------------------------------
    // FUNCTION: run_phase
    // The run phase for the component.
    // - Main loop
    // -  Wait for sequence item.
    // -  Perform the requested action
    // -  Send a response back.
    //------------------------------------------------------------------------------
    virtual task run_phase(uvm_phase phase);
        serial_data_seq_item seq_item;

        // Reset signals
        m_config.m_vif.start_bit <= 0;
        m_config.m_vif.serial_data <= 0;

        
        forever begin
            // Wait for sequence item
            seq_item_port.get(seq_item);
            `uvm_info(get_name(),$sformatf("Start serial interface transaction. Delay start bit=%0d  Start bit length=%0d  Serial data=%08b", seq_item.start_bit_delay, seq_item.start_bit_length, seq_item.serial_data),UVM_HIGH)
            
            @(posedge m_config.m_vif.clk); // wait for clock edge before starting transmission after reset signal is 1

            fork
                begin
                    for (int i = 0; i < $bits(seq_item.serial_data); i++) begin // seq_item.start_bit_delay = 7
                        
                        m_config.m_vif.serial_data <= seq_item.serial_data[i];
                        
                        @(posedge m_config.m_vif.clk);
                        `uvm_info(get_name(),$sformatf("Serial data Test=%0d",  m_config.m_vif.serial_data),UVM_HIGH);

                    end
                end

                begin
                    repeat (seq_item.start_bit_delay) begin
                        @(posedge m_config.m_vif.clk);
                    end

                    m_config.m_vif.start_bit <= 1;
                    
                    repeat (seq_item.start_bit_length) begin
                        @(posedge m_config.m_vif.clk);
                    end
                    m_config.m_vif.start_bit <= 0;

                end
            join
            
            // for (int i = 0; i <= seq_item.start_bit_delay; i++) begin // seq_item.start_bit_delay = 7
                
            //     if(i == 0) begin
            //         m_config.m_vif.start_bit <= 1;
            //     end else if (i == 1) begin
            //         m_config.m_vif.start_bit <= 0;
            //     end
            //     m_config.m_vif.serial_data <= seq_item.serial_data[i];
                
            //     @(posedge m_config.m_vif.clk);
            //     `uvm_info(get_name(),$sformatf("Serial data Test=%0d",  m_config.m_vif.serial_data),UVM_HIGH);

            // end

            m_config.m_vif.serial_data <= 0; // reset serial data after sending all bits

            seq_item_port.put(seq_item); // send response back.
        end
    endtask : run_phase
endclass : serial_data_driver
