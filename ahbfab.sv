module ahbfab (mAHBIF.AHBMfab tbmstr, sAHBIF.AHBSfab memslave,
		mAHBIF.AHBMfab lcdmstr, sAHBIF.AHBSfab lcdslv,
		mAHBIF.AHBMfab bm0_m, sAHBIF.AHBSfab bm0_s,
    		mAHBIF.AHBMfab bm1_m, sAHBIF.AHBSfab bm1_s,
    		mAHBIF.AHBMfab bm2_m, sAHBIF.AHBSfab bm2_s,
    		mAHBIF.AHBMfab bm3_m, sAHBIF.AHBSfab bm3_s,
    		mAHBIF.AHBMfab bm4_m, sAHBIF.AHBSfab bm4_s,
    		mAHBIF.AHBMfab bm5_m, sAHBIF.AHBSfab bm5_s,
    		mAHBIF.AHBMfab bm6_m, sAHBIF.AHBSfab bm6_s,
    		mAHBIF.AHBMfab bm7_m, sAHBIF.AHBSfab bm7_s);

reg [31:0] addr0,addr0_d,addr1,addr1_d,
	   addr2,addr2_d,addr3,addr3_d,
	   addr4,addr4_d,addr5,addr5_d,
	   addr6,addr6_d,addr7,addr7_d;
reg [31:0] tb_hwaddr,tb_hwaddr_d;
reg [2:0] state, state_d;
reg [2:0] cnt,cnt_d;

assign tbmstr.HGRANT		= tbmstr.HBUSREQ ? 1 : 0;

always @ (*) begin
  state_d		= state;
  addr0_d		= addr0;
  addr1_d		= addr1;
  addr2_d		= addr2;
  addr3_d		= addr3;
  addr4_d		= addr4;
  addr5_d		= addr5;
  addr6_d		= addr6;
  addr7_d		= addr7;
  cnt_d			= cnt;
  tb_hwaddr_d		= tb_hwaddr;

  tb_hwaddr_d		= tbmstr.HADDR;  

  case(state)
    0: begin
    state_d = (tbmstr.HTRANS == 2) ? 1 : 0;   
    end
    1: begin
      case(tb_hwaddr)
	32'hff4e_1014: begin
	  addr0_d = tbmstr.HWDATA;
	end
	32'hff4e_1034: begin
	  addr1_d = tbmstr.HWDATA;
	end
	//32'hff4e_1054: begin
	//  addr2_d = tbmstr.HWDATA;
	//end
	//32'hff4e_1074: begin
	//  addr3_d = tbmstr.HWDATA;
	//end
	//32'hff4e_1094: begin
	//  addr4_d = tbmstr.HWDATA;
	//end
	//32'hff4e_1114: begin
	//  addr5_d = tbmstr.HWDATA;
	//end
	//32'hff4e_1134: begin
	//  addr6_d = tbmstr.HWDATA;
	//end
	//32'hff4e_1154: begin
	//  addr7_d = tbmstr.HWDATA;
	//end
      endcase
      if(tbmstr.HTRANS == 0) begin 
	state_d = 2;
      end else state_d = 1; 
    end
    2: begin
       bm0_s.HWDATA = addr0;
       bm1_s.HWDATA = addr1;
       bm0_m.HGRANT = 0;
       bm1_m.HGRANT = 0;
       state_d = 3;
    end
    3:begin
      //if(!tbmstr.HBUSREQ) begin
        bm0_m.HGRANT = 1;
        bm1_m.HGRANT = 0;
	
        if(bm0_s.HRDATA == 0) begin
          //bm0_m.HGRANT = 0;
          state_d = 4;
        end
        memslave.HWRITE 		= bm0_m.HWRITE;
        memslave.HWDATA 		= bm0_m.HWDATA;
        memslave.HADDR 		= bm0_m.HADDR;
        memslave.HSEL 		= bm0_m.HBUSREQ;
        memslave.HREADYin 	= bm0_m.HBUSREQ;
        memslave.HTRANS 		= bm0_m.HTRANS;
        memslave.HSIZE 		= bm0_m.HSIZE;
        memslave.HBURST 		= bm0_m.HBURST;
        tbmstr.HRDATA 		= bm0_s.HRDATA;
        bm0_s.HTRANS 		= tbmstr.HTRANS;
        bm0_m.HRDATA 		= memslave.HRDATA;
      //end else bm0_m.HGRANT = 0;
            //bm2_s.HWDATA = addr2;
      //bm3_s.HWDATA = addr3;
      //bm4_s.HWDATA = addr4;
      //bm5_s.HWDATA = addr5;
      //bm6_s.HWDATA = addr6;
      //bm7_s.HWDATA = addr7;
    end
    4: begin
      bm0_m.HGRANT = 0;
      state_d = 6;
    end
    5: begin
      //if(!tbmstr.HBUSREQ) begin
        bm1_m.HGRANT = 1;
        bm0_m.HGRANT = 0;
        //if(bm1_s.HRDATA == 0) begin
        //  bm1_m.HGRANT = 0;
        //  state_d = 4;
        //end
        memslave.HWRITE 		= bm1_m.HWRITE;
        memslave.HWDATA 		= bm1_m.HWDATA;
        memslave.HADDR 		= bm1_m.HADDR;
        memslave.HSEL 		= bm1_m.HBUSREQ;
        memslave.HREADYin 	= bm1_m.HBUSREQ;
        memslave.HTRANS 		= bm1_m.HTRANS;
        memslave.HSIZE 		= bm1_m.HSIZE;
        memslave.HBURST 		= bm1_m.HBURST;
        tbmstr.HRDATA 		= bm1_s.HRDATA;
        bm1_s.HTRANS 		= tbmstr.HTRANS;
        bm1_m.HRDATA 		= memslave.HRDATA;
          state_d = 5;
      //end else bm1_m.HGRANT = 0;
    end
    6: begin
    end
  endcase
end

always @(posedge tbmstr.HCLK or posedge tbmstr.HRESET) begin
  if(tbmstr.HRESET) begin
    state		<= 0;
    addr0		<= 0;
    addr1		<= 0;
    addr2		<= 0;
    addr3		<= 0;
    addr4		<= 0;
    addr5		<= 0;
    addr6		<= 0;
    addr7		<= 0;
    bm0_s.HADDR		<= 0;
    bm0_s.HSEL		<= 0;
    bm0_s.HWRITE	<= 0;
    bm0_m.HGRANT	<= 0;
    bm1_m.HGRANT	<= 0;
    bm1_s.HADDR		<= 0;
    bm1_s.HSEL		<= 0;
    bm1_s.HWRITE	<= 0;
    bm0_s.HWDATA	<= 0;
    bm1_s.HWDATA	<= 0;
    cnt			<= 0;
    tb_hwaddr		<= 0;
  end else begin
    state		<= #1 state_d;
    addr0		<= #1 addr0_d;
    addr1		<= #1 addr1_d;
    addr2		<= #1 addr2_d;
    addr3		<= #1 addr3_d;
    addr4		<= #1 addr4_d;
    addr5		<= #1 addr5_d;
    addr6		<= #1 addr6_d;
    addr7		<= #1 addr7_d;
    cnt			<= #1 cnt_d;
    tb_hwaddr		<= #1 tb_hwaddr_d;
  end
end
endmodule : ahbfab
