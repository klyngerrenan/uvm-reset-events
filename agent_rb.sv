class agent_rb extends uvm_agent;
    
    typedef uvm_sequencer#(transaction_rb) sequencer;
    sequencer  sqr;
    driver_rb   drv;
    monitor_rb  mon;

    event pre_set;

    uvm_analysis_port #(transaction_rb) agt_req_port;

    `uvm_component_utils(agent_rb)

    function new(string name = "agent_rb", uvm_component parent = null);
        super.new(name, parent);
        agt_req_port  = new("agt_req_port", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon = monitor_rb::type_id::create("mon", this);
        sqr = sequencer::type_id::create("sqr", this);
        drv = driver_rb::type_id::create("drv", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        mon.req_port.connect(agt_req_port);
        drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
	        @(pre_set)
	        sqr.stop_sequences();
	        ->drv.reset_driver;
    	end
    endtask 
endclass: agent_rb