//------------------------------------------------------------------------------
// tb_env class
//
// This class represents the environment of the TB (Test Bench) which is
// composed by the different agents and the scoreboard
// The environment is initialized by getting the TB configuration from the UVM
// database and then creating all the components
//
// The environment connects the monitor analysis ports of the agents to the
// scoreboard
//
//------------------------------------------------------------------------------
class tb_env extends uvm_env;
    `uvm_component_utils(tb_env)

    // TB configuration object with all setup for the TB environment
    top_config   m_top_config;
    // clock instance with clock uVC.
    clock_agent  m_clock_agent;
    // reset instance with reset uVC.
    reset_agent  m_reset_agent;
    // execution_stage instance with execution_stage uVC.
    execution_stage_input_agent m_execution_stage_input_agent;
    execution_stage_output_agent m_execution_stage_output_agent;

    // decode_stage instance with decode_stage uVC.
    decode_stage_input_agent m_decode_stage_input_agent;
    // scoreboard scoreboard.
    scoreboard   m_scoreboard;

    //------------------------------------------------------------------------------
    // Creates and initializes an instance of this class using the normal
    // constructor arguments for uvm_component.
    //------------------------------------------------------------------------------
    function new (string name = "tb_env" , uvm_component parent = null);
        super.new(name,parent);
        // Get TOP TB configuration from UVM DB
        if ((uvm_config_db #(top_config)::get(null, "tb_top", "top_config", m_top_config))==0) begin
            `uvm_fatal(get_name(),"Cannot find <top_config> TB configuration!")
        end
    endfunction : new

    //------------------------------------------------------------------------------
    // Build all the components in the TB environment
    //------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // Build all TB VC's
        uvm_config_db #(clock_config)::set(this,"m_clock_agent*","config", m_top_config.m_clock_config);
        m_clock_agent = clock_agent::type_id::create("m_clock_agent",this);
        uvm_config_db #(reset_config)::set(this,"m_reset_agent*","config", m_top_config.m_reset_config);
        m_reset_agent = reset_agent::type_id::create("m_reset_agent",this);

        uvm_config_db #(execution_stage_input_config)::set(this,"m_execution_stage_input_agent*","config", m_top_config.m_execution_stage_input_config);
        m_execution_stage_input_agent = execution_stage_input_agent::type_id::create("m_execution_stage_input_agent",this);

        uvm_config_db #(execution_stage_output_config)::set(this,"m_execution_stage_output_agent*","config", m_top_config.m_execution_stage_output_config);
        m_execution_stage_output_agent = execution_stage_output_agent::type_id::create("m_execution_stage_output_agent",this);

        uvm_config_db #(decode_stage_input_config)::set(this,"m_decode_stage_input_agent*","config", m_top_config.m_decode_stage_input_config);
        m_decode_stage_input_agent = decode_stage_input_agent::type_id::create("m_decode_stage_input_agent",this);

        // Build scoreboard components
        m_scoreboard = scoreboard::type_id::create("m_scoreboard",this);
    endfunction : build_phase

    //------------------------------------------------------------------------------
    // This function is used to connection the uVC monitor analysis ports to the scoreboard
    //------------------------------------------------------------------------------
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        // Making all connection all analysis ports to scoreboard
        m_reset_agent.m_monitor.m_analysis_port.connect(m_scoreboard.m_reset_ap);
        // connect execution_stage monitor to scoreboard
        m_execution_stage_input_agent.m_monitor.m_analysis_port.connect(m_scoreboard.m_execution_stage_input_ap);
        m_execution_stage_output_agent.m_monitor.m_analysis_port.connect(m_scoreboard.m_execution_stage_output_ap);
        // connect decode_stage monitor to scoreboard
        m_decode_stage_input_agent.m_monitor.m_analysis_port.connect(m_scoreboard.m_decode_stage_input_ap);
    endfunction : connect_phase

endclass : tb_env
