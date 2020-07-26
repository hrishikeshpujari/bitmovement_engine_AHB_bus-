module bitmove (bitmove_intf.bm bm);

typedef struct packed {
	reg [31:0] sl;
        } source_lower;

typedef struct packed {
	reg [4:0] sh;
	reg [26:0] len;
	} byte_len;

typedef struct packed {
	reg [1:0] unused;
	reg [29:0] mem_addr;
	reg [4:0] offset;
	} m_addr;
	
typedef struct packed {
    reg [28:0] reserved;
    reg  error;
    reg  busy;
	reg starting;
    } flags;
    
typedef struct packed {
	reg [21:0] reserve;
	reg [4:0] comp;
	}L;
	
typedef struct packed {
    reg [31:0] higher;
    reg [31:0] lower;
    } mod;
    
typedef enum [2:0]{
	starting,
	initiate,
	read_int,
	read,
	modify,
	write
} state_variables;

typedef enum [2:0] {
	ideal,
	adjust,
	alignleft,
	alignright
     }write_variables;

write_variables write_next_state, write_curr_state;
state_variables next_state, curr_state;
source_lower sa,sa_d, da, da_d;
byte_len l1,l1_d,l2,l2_d;
m_addr des,des_d;
m_addr source,source_d;
flags f1_d,f1;
L length_d,length;
mod data_mod3_d,data_mod3,data_mod4_d,data_mod4;

     
reg sel_d,sel;
reg [4:0] len1_d,len1;
reg [1:0] cnt_d,cnt, cnt1_d,cnt1;
reg [1:0] count_d,count;
reg [3:0][31:0] fifo;
reg [31:2] mAddr1_d, mAddr1;
reg [31:0] data_mod_d, data_mod,data_mod1_d,data_mod1,data_mod2_d,data_mod2;
reg Ssel_d,Ssel;
reg [31:0] mask1_d,mask1,mask2_d,mask2; 
reg [31:0] temp;


assign bm.errSeen = 0;
assign bm.sRdata = 0;
assign bm.mBurst = 0;
assign bm.busy = 0;

always @(*) begin
		next_state = curr_state;
		write_next_state = write_curr_state;
		sa_d = sa;
		des_d = des;
		l2_d = l2;
		l1_d = l1;
		f1_d = f1;
		bm.done = 0;
		data_mod_d = data_mod;
		data_mod1_d = data_mod1;
		data_mod2_d = data_mod2;
		data_mod3_d = data_mod3;
		data_mod4_d = data_mod4;
		temp = 32'hffff_ffff;
		bm.mReq = 0;
		bm.mRW = 0;	
		bm.mAddr = 0;
		bm.mWdata = 0;
		da_d = da;
		sel_d = sel;
		Ssel_d = Ssel;
		length_d = length;
		cnt1_d = cnt1;
		cnt_d = cnt;
		mask1_d = mask1;
		mask2_d = mask2;
		source_d =source;
		mAddr1_d = mAddr1;
		count_d = count;
		case (curr_state)
		
	starting: begin
        bm.done = 0;
		if ((bm.sSel == 1) && (bm.sRW == 1)) begin
			if (bm.sAddr == 3'd0) begin
				sa_d = bm.sWdata; 
			end else if(bm.sAddr == 3'd1) begin
                l1_d = bm.sWdata;
			end else if(bm.sAddr == 3'd2) begin
                da_d = bm.sWdata;
            end else if(bm.sAddr == 3'd3) begin
                l2_d = bm.sWdata;
            end else if(bm.sAddr == 3'd4) begin
                f1_d = bm.sWdata;
            end else next_state = curr_state;
		end 
		else if (f1.starting == 1) next_state = initiate;
        else next_state = curr_state;
        
        sel_d = 0;
        Ssel_d = 0;
        len1_d = 0;
        length_d = 0;
        data_mod_d = 0;
        data_mod1_d = 0;
        data_mod2_d =0;
        data_mod3_d = 0;
        data_mod4_d = 0;
        cnt1_d = 0;
        cnt_d = 0;
        mask1_d = 0;
        mask2_d = 0;
	end
	
	initiate: begin
        f1_d = 0;
		source_d = {l1.sh,sa.sl};
		des_d = {l2.sh,da.sl};
		length_d = (l1.len + des_d.offset);
		next_state = read_int;
    end
	
	read_int: begin 
        if(bm.mHold == 1'b0) begin 
            bm.mReq = 1;
            bm.mRW = 0;
            bm.mAddr = source.mem_addr;
            mAddr1_d = source.mem_addr + 1;
            next_state = read;
            count_d = 3;
            cnt_d =0;
        end 
        else begin 
            next_state = read_int;
        end 
	end 
	
	read: begin	
        if(bm.mHold == 1'b0) begin 
        if(count > 0) begin
            bm.mReq = 1;
            bm.mRW = 0;
            bm.mAddr = mAddr1;
            mAddr1_d = mAddr1 + 1;
            data_mod_d = bm.mRdata;
            cnt_d = cnt + 1;
            next_state = read;
            count_d = count -1;
        end
        else begin
            data_mod_d =  bm.mRdata;	
            mAddr1_d = mAddr1;
            if(sel == 0) begin
                bm.mReq = 1;
                bm.mRW = 0;
                bm.mAddr = des.mem_addr;
                des_d.mem_addr = des.mem_addr ;
                mAddr1_d = mAddr1;
                next_state = modify;
            end
            else if ((sel == 1) && (length <= 27'd32))begin
                mask1_d = temp << length;
                mask2_d = ~(temp << length);
                bm.mReq = 1;
                bm.mRW = 0;
                bm.mAddr = des.mem_addr;
                des_d.mem_addr = des.mem_addr ;
                next_state = write;
                if (write_curr_state == ideal) begin 
                    cnt1_d = cnt1 - 2'd1;
                    Ssel_d = 1;
                end
                else cnt1_d = cnt1 - 2'd1;
                        
                sel_d = 1;
            end
            else begin
                bm.mReq = 1;
                bm.mRW = 1;
                bm.mAddr = des.mem_addr;
                des_d.mem_addr = des.mem_addr + 1;
                next_state = write;
                sel_d = 0;
            end     
        end
        end 
        else begin
            next_state = read;
        end 
	end
	
	modify: begin
        if(bm.mHold == 1'b0) begin 
        data_mod1_d =  bm.mRdata;
        data_mod2_d = data_mod1_d << (5'd31 + 1 - des.offset);
		bm.mReq = 1;
		bm.mRW = 1;
		bm.mAddr = des.mem_addr;
        des_d.mem_addr = des.mem_addr + 1;
        next_state = write;
        if ((des.offset == source.offset) && (des.offset == 0))begin 
            write_next_state = ideal;
            cnt1_d = cnt1 + 2'd1;
            data_mod4_d = {fifo[cnt1 + 2'd1], fifo[cnt1]};
        end
        else begin
            write_next_state = adjust;
            data_mod3_d = {fifo[cnt1 + 2'd1], fifo[cnt1]} >>source.offset;
        end 
        
        if(length < 27'd32) begin
            mask1_d = temp << length;
            mask2_d = ~(temp << length);
        end
        else begin
            mask1_d = 0;
            mask2_d = temp;
        end 
        end 
        else begin 
            next_state = modify;
        end 
	end
	
	write: begin
        if(bm.mHold == 1'b0) begin 
        case(write_curr_state)
        
			ideal: begin
                if (length > 27'd32) begin
                    bm.mWdata = data_mod4.lower;
                    length_d = length - 27'd32;
                    if((cnt1 ) == cnt) begin
                        bm.mReq = 1;
                        bm.mRW = 0;
                        bm.mAddr = mAddr1;
                        mAddr1_d = mAddr1 + 1;
                        des_d.mem_addr = des.mem_addr;
                        next_state = read;
                        sel_d = 1;
                        data_mod4_d = {fifo[cnt1 + 2'd1], fifo[cnt1]};
                        count_d = 3;
                        cnt1_d = cnt1 + 1;
                        cnt_d = cnt + 1;
                    end
                    else if(length_d <= 27'd32) begin
                        bm.mReq = 1;
                        bm.mRW = 0;
                        bm.mAddr = des.mem_addr;
                        mAddr1_d = mAddr1;
                        des_d.mem_addr = des.mem_addr;
                        sel_d = 1;
                        data_mod4_d = {fifo[cnt1 + 2'd1], fifo[cnt1]};
                        cnt1_d = cnt1;
                    end
                    else begin
                        bm.mReq = 1;
                        bm.mRW = 1;
                        bm.mAddr = des.mem_addr;
                        des_d.mem_addr = des.mem_addr + 1;
                        data_mod4_d = {fifo[cnt1 + 2'd1], fifo[cnt1]};
                        cnt1_d = cnt1 + 1;
                        sel_d = 0;
                    end 
                end
                else if(sel == 1) begin
                    data_mod1_d = bm.mRdata;
                    if (Ssel == 1) data_mod4_d = data_mod4;
                    else data_mod4_d = {fifo[cnt1 + 2'd1], fifo[cnt1]};
                    sel_d = 0;
                    bm.mReq = 1;
                    bm.mRW = 1;
                    bm.mAddr = des.mem_addr;
                    des_d.mem_addr = des.mem_addr;
                        
                    if(length < 27'd32) begin
                        mask1_d = temp << length;
                        mask2_d = ~(temp << length);
                    end
                    else begin
                        mask1_d = 0;
                        mask2_d = temp;
                        end            
                end 
                else begin
                    data_mod1_d = (data_mod1 & mask1) + (data_mod4.lower & mask2);
                    bm.mWdata = data_mod1_d;
                    bm.done = 1;
                    next_state = starting;
                    bm.mReq = 0;
                end 
            end
            
            adjust : begin
            next_state = curr_state;
                    if(length > 27'd32) begin
                        data_mod2_d = {data_mod3.lower,data_mod2} >> (5'd31 + 1 - des.offset);
                        bm.mWdata =  data_mod2_d;
                        length_d = length - 27'd32;
                        if((length - 27'd32) > 27'd32) begin
                            bm.mReq = 1;
                            bm.mRW = 1;
                            bm.mAddr = des.mem_addr;
                            des_d.mem_addr = des.mem_addr + 1;
                            sel_d = 0;
                            cnt1_d = cnt1 + 1;
                        end
                        else begin
                            bm.mReq = 1;
                            bm.mRW = 0;
                            bm.mAddr = des.mem_addr;
                            des_d.mem_addr = des.mem_addr;
                            sel_d = 1;
                            cnt1_d = cnt1;
                        end 
            
                    if(source.offset > des.offset) begin
                        data_mod4_d = {fifo[cnt1 + 2'd2],fifo[cnt1 + 2'd1]} >> (source.offset - des.offset);
                        write_next_state = alignleft;
                    end
                    else if (source.offset < des.offset) begin
                        data_mod4_d = {fifo[cnt1 + 2'd1],fifo[cnt1]} << (des.offset - source.offset);
                        write_next_state = alignright;
                    end
                    else begin
                        write_next_state = ideal;
                        data_mod4_d = {fifo[cnt1 + 2'd2],fifo[cnt1 + 2'd1]};
                        cnt1_d = cnt1 + 2'd2;
                    end
                end
                else begin
                        data_mod2_d = {data_mod3.lower,data_mod2} >> (5'd31 + 1 - des.offset);
                        data_mod1_d = (data_mod1 & mask1) + (data_mod2_d & mask2);
                        bm.mWdata = data_mod1_d;
                        bm.done = 1;
                        next_state = starting;
                        bm.mReq = 0;
                end  
            end
            
            alignleft : begin
                next_state = curr_state;
                write_next_state = write_curr_state;
                    if (length > 27'd32) begin
                        bm.mWdata = data_mod4.lower;
                        length_d = length - 27'd32;
                        
                        if((cnt1 + 2'd2) == cnt)begin
                            bm.mReq = 1;
                            bm.mRW = 0;
                            bm.mAddr = mAddr1;
                            mAddr1_d = mAddr1 + 1;
                            des_d.mem_addr = des.mem_addr;
                            next_state = read;
                            sel_d = 1;
                            data_mod4_d = {fifo[cnt1 + 2'd2],fifo[cnt1 + 2'd1]} >> (source.offset - des.offset);
                            cnt1_d = cnt1 + 1;
                            cnt_d = cnt + 1;
                            count_d = 1;
                        end
                        else if(length_d <= 27'd32) begin
                            bm.mReq = 1;
                            bm.mRW = 0;
                            bm.mAddr = des.mem_addr;
                            mAddr1_d = mAddr1;
                            des_d.mem_addr = des.mem_addr;
                            sel_d = 1;
                            cnt1_d = cnt1;
                        end
                        else begin
                           bm.mReq = 1;
                            bm.mRW = 1;
                            bm.mAddr = des.mem_addr;
                            mAddr1_d = mAddr1;
                            des_d.mem_addr = des.mem_addr + 1;
                            data_mod4_d = {fifo[cnt1 + 2'd2],fifo[cnt1 + 2'd1]} >> (source.offset - des.offset);
                            cnt1_d = cnt1 + 1;
                            cnt_d = cnt;
                            count_d = count;
                            sel_d = 0;
                        end 
                 end 
                 else if(sel == 1) begin
                        data_mod1_d = bm.mRdata;
                        data_mod4_d = {fifo[cnt1 + 2'd2],fifo[cnt1 + 2'd1]} >> (source.offset - des.offset);
                        sel_d = 0;
                        bm.mReq = 1;
                        bm.mRW = 1;
                        bm.mAddr = des.mem_addr;
                        
                        if(length < 27'd32) begin
                            mask1_d = temp << length;
                            mask2_d = ~(temp << length);
                        end
                        else begin
                            mask1_d = 0;
                            mask2_d = temp;
                        end 
                end
                else begin
                    data_mod1_d = (data_mod1 & mask1) + (data_mod4.lower & mask2);
                    bm.mWdata = data_mod1_d;
                    bm.done = 1;
                    next_state = starting;
                    bm.mReq = 0;
                end 
              end 
             
             alignright : begin
                next_state = curr_state;
                write_next_state = write_curr_state;
                
                if (length > 27'd32) begin
                    bm.mWdata = data_mod4.higher;
                    length_d = length - 27'd32;
                        if((cnt1 + 2'd1) == cnt ) begin
                            bm.mReq = 1;
                            bm.mRW = 0;
                            bm.mAddr = mAddr1;
                            mAddr1_d = mAddr1 + 1;
                            des_d.mem_addr = des.mem_addr;
                            next_state = read;
                            sel_d = 1;
                            data_mod4_d = {fifo[cnt1 + 2'd1],fifo[cnt1]} << (des.offset - source.offset);
                            cnt1_d = cnt1 + 1;
                            cnt_d = cnt + 1;
                            count_d = 1;
                         end
                         else if ( (length_d <= 27'd32)) begin
                            bm.mReq = 1;
                            bm.mRW = 0;
                            bm.mAddr = des.mem_addr;
                            mAddr1_d = mAddr1;
                            des_d.mem_addr = des.mem_addr;
                            sel_d = 1;
                            cnt1_d = cnt1;
                        end
                        else begin
                            bm.mReq = 1;
                            bm.mRW = 1;
                            bm.mAddr = des.mem_addr;
                            mAddr1_d = mAddr1;
                            des_d.mem_addr = des.mem_addr + 1;
                            data_mod4_d = {fifo[cnt1 + 2'd1],fifo[cnt1]} << (des.offset - source.offset);
                            cnt1_d = cnt1 + 1;
                            cnt_d = cnt;
                            count_d = count;
                            sel_d = 0;
                        end 
                 end
                 else if(sel == 1) begin
                        data_mod1_d = bm.mRdata;
                        data_mod4_d = {fifo[cnt1 + 2'd1],fifo[cnt1]} << (des.offset - source.offset);
                        sel_d = 0;
                        bm.mReq = 1;
                        bm.mRW = 1;
                        bm.mAddr = des.mem_addr;
                        if(length < 27'd32) begin
                            mask1_d = temp << length;
                            mask2_d = ~(temp << length);
                        end else begin
                            mask1_d = 0;
                            mask2_d = temp;
                end 
                end 
                else begin
                    data_mod1_d = (data_mod1 & mask1) + (data_mod4.higher & mask2);
                    bm.mWdata = data_mod1_d;
                    bm.done = 1;
                    next_state = starting;
                    bm.mReq = 0;
                end 
             end 
         endcase
         end 
         else begin 
            next_state = write;
         end 
       end
    endcase
end
    
always @(posedge (bm.clk)or posedge (bm.reset)) begin
    if(bm.reset) begin
        fifo[0] <= 32'd0;
		fifo[1] <= 32'd0;
		fifo[2] <= 32'd0;
		fifo[3] <= 32'd0;
    end
    else if(bm.done) begin
        fifo[0] <= 32'd0;
		fifo[1] <= 32'd0;
		fifo[2] <= 32'd0;
		fifo[3] <= 32'd0;
    end else begin
		fifo[cnt] <= #1 data_mod_d;
    end 
end 
    
always @(posedge (bm.clk) or posedge (bm.reset)) begin
	if(bm.reset) begin
		mask1 <= 0;
		mask2 <= 0;
		mAddr1 <= 0;
		sa <= 0;
		source <= 0;
		des <= 0;
		length <= 0;
		curr_state <= starting;
		sel <= 0;
		Ssel <= 0;
		cnt <= 0;
		cnt1 <= 0;
		count <= 0;
		write_curr_state <= ideal;
		sa <= 0;
		da <= 0;
		l1 <= 0;
		l2 <= 0;
		des <= 0;
		source <= 0;
		f1 <= 0;
		data_mod <= 0;
		data_mod1 <= 0;
		data_mod2 <= 0;
		data_mod3 <= 0;
		data_mod4 <= 0;
		len1 <= 0;
	end
	else begin
        curr_state <= #1 next_state;
        write_curr_state <= #1 write_next_state;
        sa <= #1 sa_d;
		count <= #1 count_d;
        cnt <= #1 cnt_d;
        cnt1 <= #1 cnt1_d;
        mAddr1 <= #1 mAddr1_d;
        mask1 <= #1 mask1_d;
        mask2 <= #1 mask2_d;
        source <= #1 source_d;
		des <= #1 des_d;
		length <= #1 length_d;
		sel <= #1 sel_d;
		Ssel <= #1 Ssel_d;
        sa <= #1 sa_d;
        da <= #1 da_d;
        l1 <= #1 l1_d;
        l2 <= #1 l2_d;
        len1 <= #1 len1_d;
		des <= #1 des_d;
        source <= #1 source_d;
        f1 <= #1 f1_d;
		data_mod <= #1 data_mod_d;
		data_mod1 <= #1 data_mod1_d;
		data_mod2 <= #1 data_mod2_d;
		data_mod3 <= #1 data_mod3_d;
		data_mod4 <= #1 data_mod4_d;
    end
end 
    
endmodule : bitmove
