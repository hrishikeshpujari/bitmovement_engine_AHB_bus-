
module ahb_bridge (mAHBIF.AHBM ahbm, sAHBIF.AHBS ahbs, bitmove_intf.bridge bridge);

  reg [31 : 0] state, state_d;
  reg h_sel, h_sel_d;
  reg h_write, h_write_d;
  reg [1  : 0] h_trans, h_trans_d;
  reg [2  : 0] h_size, h_size_d;
  reg [31 : 0] h_addr, h_addr_d;
  reg v, v_d, first_trans_d, first_trans;
  reg [31 : 0] pointer, pointer_d, ahbm_hRdata, ahbm_hRdata_d, next_pointer, next_pointer_d, pointer1, pointer1_d;
  reg [2  : 0] cnt, cnt_d, addr, addr_d;
  reg counter, counter_d;

  parameter ST_IDLE = 6'h00;

  always @( *) begin
    next_pointer_d = next_pointer;
    cnt_d = cnt;
    pointer_d = pointer;
    pointer1_d = pointer1;
    h_write_d = h_write;
    h_sel_d = h_sel;
    h_addr_d = h_addr;
    h_size_d = h_size;
    h_trans_d = h_trans;
    ahbm_hRdata_d = ahbm_hRdata;
    addr_d = addr;
    first_trans_d = first_trans;
    counter_d = counter;

    bridge.sSel = h_sel;
    bridge.sRW = h_write;
    //bridge.sAddr = h_addr[5 : 2];
    bridge.sAddr = h_addr;
    //bridge.sWdata = v ? ahbs.HWDATA : 0;
    bridge.sWdata = ahbm_hRdata;
    bridge.mHold = !ahbm.HGRANT;
    //bridge.mHold = 0;

    state_d = state;

    v_d = ahbs.HSEL ? 1 : 0;
    h_sel_d = ahbs.HSEL;
    h_addr_d = ahbs.HADDR;
    h_write_d = ahbs.HWRITE;

    bridge.mRdata = ahbm.HRDATA;
    ahbm.HWRITE = bridge.mRW;
    ahbm.HADDR = bridge.mReq ? {bridge.mAddr, 2'b00} : 0;
    ahbm.HWDATA = bridge.mWdata;
    ahbm.HTRANS = bridge.mReq ? 2'b10 : 2'b00;
    //ahbm.HBUSREQ = bridge.mReq;
    ahbm.HSIZE = 3'b010;
    ahbm.HBURST = 3'b000;

    pointer_d = first_trans ? ahbs.HWDATA : next_pointer;
    if (ahbm.HGRANT) begin
      case(state)
        ST_IDLE : begin
          state_d = 1;
        end
        1 : state_d = ahbs.HTRANS == 2 ? 2 : 1;
        2 : begin
          ahbm.HWRITE = 0;
          ahbm.HADDR = pointer_d;
          ahbm.HBUSREQ = 1;
          ahbm.HTRANS = 2'b10;
          ahbm.HSIZE = 3'b010;
          ahbm.HBURST = 3'b000;
          //pointer_d = pointer + 4;
          state_d = 3;
          counter_d = counter + 1;
        end
        3                                         : begin
          next_pointer_d = (cnt == 0) ? ahbm.HRDATA : next_pointer;
          pointer1_d = (cnt == 1) ? ahbs.HWDATA     : pointer1;
          if (cnt < 6) begin
            pointer_d = (cnt < 5) ? pointer + 4 : pointer;
            ahbm.HWRITE = 0;
            ahbm.HADDR = pointer_d;
            ahbm.HBUSREQ = 1;
            ahbm.HTRANS = 2'b10;
            cnt_d = cnt + 1;
            h_sel_d = (cnt >= 1) ? 1                 : 0;
            h_write_d = (cnt >= 1) ? 1               : 0;
            ahbm_hRdata_d = (cnt >= 1) ? ahbm.HRDATA : 0;
            h_addr_d = addr;
            addr_d = (cnt >= 1) ? addr + 1 : addr;
          end else begin
            h_sel_d = 0;
            h_write_d = 0;
            if (bridge.done) begin
              first_trans_d = 0;
              ahbs.HRDATA = next_pointer;
              cnt_d = 0;
              addr_d = 0;
              state_d = (next_pointer == 0) ? 4                   : 1;
              / / next_pointer_d = (next_pointer == 0) ? pointer1 : next_pointer;
            end else state_d = 3;
          end
        end
        4 : begin
          ahbm.HBUSREQ = 0;
        end
      endcase
    end

  end

  always @(posedge ahbs.HCLK or posedge ahbs.HRESET) begin
    if (ahbs.HRESET) begin
      state        <= ST_IDLE;
      h_sel        <= 0;
      h_addr       <= 0;
      h_write      <= 0;
      v            <= 0;
      pointer      <= 0;
      cnt          <= 0;
      h_size       <= 0;
      h_trans      <= 0;
      ahbm_hRdata  <= 0;
      addr         <= 0;
      next_pointer <= 0;
      first_trans  <= 1;
      pointer1     <= 0;
      counter      <= 0;
    end else begin
      state        <= #1 state_d;
      h_sel        <= #1 h_sel_d;
      h_addr       <= #1 h_addr_d;
      h_write      <= #1 h_write_d;
      v            <= #1 v_d;
      pointer      <= #1 pointer_d;
      cnt          <= #1 cnt_d;
      ahbm_hRdata  <= #1 ahbm_hRdata_d;
      addr         <= #1 addr_d;
      next_pointer <= #1 next_pointer_d;
      first_trans  <= #1 first_trans_d;
      pointer1     <= #1 pointer1_d;
      counter      <= #1 counter_d;
    end
  end
endmodule
