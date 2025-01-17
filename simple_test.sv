class simple_test extends uvm_test;
  env env_h;
  sequence_in seq;
  sequence_rb seq_rb;
  bit reset, flag;
  int count_tr_reset;

  `uvm_component_utils(simple_test)

  function new(string name, uvm_component parent = null);
    super.new(name, parent);
    count_tr_reset = 2000;
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env_h = env::type_id::create("env_h", this);
    seq = sequence_in::type_id::create("seq", this);
    seq_rb = sequence_rb::type_id::create("seq_rb", this);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    env_h.mst.mon.count_tr_reset = count_tr_reset;
    
    fork
      forever begin
        fork
            seq_rb.start(env_h.mst_rb.sqr);
            begin 
                if (reset) begin 
                    repeat(3000) seq.start(env_h.mst.sqr);
                    phase.drop_objection(this);
                end

                if (!reset) begin 
                    repeat(count_tr_reset) seq.start(env_h.mst.sqr);
                    reset = 1;
                end
            end
        join
      end
      forever begin
        @(negedge env_h.mst_rb.drv.vif.rst);
        ->env_h.mst_rb.pre_set;
        ->env_h.mst.drv.reset_driver;
        ->env_h.sb.rfm.reset_refmod;
        $display("JUMP",);
      end
    join
  endtask

endclass
