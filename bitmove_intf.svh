// This is the interface block for the bit move moduleTopCreate


interface bitmove_intf(input logic clk, reset);

logic sRW;              // A read write for the slave (register interface) R=0
logic sSel;             // The slave is selected (a strobe push or pull)
logic [5:3] sAddr;      // The slave address (3 bit word address)
logic [31:0] sWdata;    // write data to the slave
logic [31:0] sRdata;    // read data from the slave

logic [31:2] mAddr;     // the master address (mem R/W) 30 bits word address
logic [31:0] mWdata;    // data from the master interface (write data)
logic [31:0] mRdata;    // data to the master interface (read data)
logic mRW;              // Is this a master read or write R=0, W=1
logic mBurst;           // Continue to the next address in a burst is OK
logic mReq;             // A transfer request from the master
logic mHold;            // Transfer hold (Data is pipelined)
logic mErr;             // The transfer had an error (comes with mAck)

logic busy;             // an output indicating the bit move block is busy
logic errSeen;          // The operation had an error
logic done;             // The operation completed

modport bm(input clk,reset,sRW,sSel,sAddr,sWdata,output sRdata,
           output mAddr,mWdata,input mRdata,
           output mRW,mReq,mBurst,input mHold,mErr,
           output busy,errSeen,done);
           
modport bridge(output sRW,sSel,sAddr,sWdata,input sRdata,
        input mAddr,mWdata,output mRdata,
        input mRW,mReq,mBurst, output mHold,mErr,input done);

endinterface : bitmove_intf
