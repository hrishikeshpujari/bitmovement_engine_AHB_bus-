// This is a simple driver for the uvm things...
//

`timescale 1ns/10ps

`include "ahb_if.sv"
`include "bitmove_intf.svh"
`include "lcdif.sv"

package tbm;

import uvm_pkg::*;
`include "tbregs.sv"
`include "tbdef.sv"
`include "lcduvm.svp"
`include "seq8.svh"
`include "bmtx.svp"

import uvm_pkg::*; // bmtx.svp ended the tbm package
`include "ahbfab.sv"
`include "bitmove.sv"
`include "ahb_bmaster.sv"
`include "lcd.svp"
`include "mem32x32.sv"
`include "mem128x32.sv"
`include "mem256x32.sv"

module top;

reg clk,reset;

sAHBIF memslv(clk,reset);
mAHBIF tbmstr(clk,reset);
sAHBIF lcdslv(clk,reset);
mAHBIF lcdmstr(clk,reset);
sAHBIF bm0s(clk,reset),bm1s(clk,reset),bm2s(clk,reset),bm3s(clk,reset),
    bm4s(clk,reset),bm5s(clk,reset),bm6s(clk,reset),bm7s(clk,reset);
mAHBIF bm0m(clk,reset),bm1m(clk,reset),bm2m(clk,reset),bm3m(clk,reset),
    bm4m(clk,reset),bm5m(clk,reset),bm6m(clk,reset),bm7m(clk,reset);
bitmove_intf bi0(clk,reset),bi1(clk,reset),bi2(clk,reset),bi3(clk,reset),
    bi4(clk,reset),bi5(clk,reset),bi6(clk,reset),bi7(clk,reset);
MEMIF f0();
MEMIF f1();
RAM128IF r128();
RAM256IF r256();
LCDOUT lout();

initial begin
    reset=1;
    repeat(3) @(posedge(clk)) #1;
    reset=0;
end

initial begin
    clk=1;
    repeat(2_000_000*2) #5 clk=~clk;
    $display("\n\n\nError Error Error\n\nRan out of clocks\n");
    $display("Error Error Error\n\n");
    $finish;
end

initial begin
    run_test("tseq");
end

ahbfab fab(tbmstr.AHBMfab,memslv.AHBSfab,
    lcdmstr.AHBMfab,lcdslv.AHBSfab,
    bm0m.AHBMfab,bm0s.AHBSfab,
    bm1m.AHBMfab,bm1s.AHBSfab,
    bm2m.AHBMfab,bm2s.AHBSfab,
    bm3m.AHBMfab,bm3s.AHBSfab,
    bm4m.AHBMfab,bm4s.AHBSfab,
    bm5m.AHBMfab,bm5s.AHBSfab,
    bm6m.AHBMfab,bm6s.AHBSfab,
    bm7m.AHBMfab,bm7s.AHBSfab);

lcd l(lcdmstr.AHBM,lcdslv.AHBS,f0.F0,f1.F0,
    r128.R0,r256.R0,lout.O0);
    
mem128x32 palmem(clk,r128.write,r128.waddr,r128.wdata,
    r128.raddr,r128.rdata,r128.raddr1,r128.rdata1);
    
mem256x32 cursmem(clk,r256.write,r256.waddr,r256.wdata,
    r256.raddr,r256.rdata,r256.raddr1,r256.rdata1);

mem32x32 fifoMem0(clk,f0.f0_waddr,f0.f0_wdata,f0.f0_write,
    f0.f0_raddr,f0.f0_rdata);

mem32x32 fifoMem1(clk,f1.f0_waddr,f1.f0_wdata,f1.f0_write,
    f1.f0_raddr,f1.f0_rdata);

    
ahb_bridge bm0(bm0m.AHBM,bm0s.AHBS,bi0.bridge);
bitmove bmv0(bi0.bm);
ahb_bridge bm1(bm1m.AHBM,bm1s.AHBS,bi1.bridge);
bitmove bmv1(bi1.bm);
ahb_bridge bm2(bm2m.AHBM,bm2s.AHBS,bi2.bridge);
bitmove bmv2(bi2.bm);
ahb_bridge bm3(bm3m.AHBM,bm3s.AHBS,bi3.bridge);
bitmove bmv3(bi3.bm);
ahb_bridge bm4(bm4m.AHBM,bm4s.AHBS,bi4.bridge);
bitmove bmv4(bi4.bm);
ahb_bridge bm5(bm5m.AHBM,bm5s.AHBS,bi5.bridge);
bitmove bmv5(bi5.bm);
ahb_bridge bm6(bm6m.AHBM,bm6s.AHBS,bi6.bridge);
bitmove bmv6(bi6.bm);
ahb_bridge bm7(bm7m.AHBM,bm7s.AHBS,bi7.bridge);
bitmove bmv7(bi7.bm);


initial begin
    uvm_config_db #(virtual mAHBIF)::set(null, "interfaces", "tbmstr" , tbmstr);
    uvm_config_db #(virtual sAHBIF)::set(null, "interfaces", "memslv" , memslv);
    uvm_config_db #(virtual mAHBIF)::set(null, "interfaces", "lcdmstr" , lcdmstr);
    uvm_config_db #(virtual sAHBIF)::set(null, "interfaces", "lcdslv" , lcdslv);
    uvm_config_db #(virtual LCDOUT)::set(null, "interfaces", "lcdout" , lout);
    uvm_config_db #(virtual mAHBIF)::set(null, "interfaces", "bm0m" , bm0m);
    uvm_config_db #(virtual mAHBIF)::set(null, "interfaces", "bm1m" , bm1m);
    uvm_config_db #(virtual mAHBIF)::set(null, "interfaces", "bm2m" , bm2m);
    uvm_config_db #(virtual mAHBIF)::set(null, "interfaces", "bm3m" , bm3m);
    uvm_config_db #(virtual mAHBIF)::set(null, "interfaces", "bm4m" , bm4m);
    uvm_config_db #(virtual mAHBIF)::set(null, "interfaces", "bm5m" , bm5m);
    uvm_config_db #(virtual mAHBIF)::set(null, "interfaces", "bm6m" , bm6m);
    uvm_config_db #(virtual mAHBIF)::set(null, "interfaces", "bm7m" , bm7m);
    uvm_config_db #(virtual sAHBIF)::set(null, "interfaces", "bm0s" , bm0s);
    uvm_config_db #(virtual sAHBIF)::set(null, "interfaces", "bm1s" , bm1s);
    uvm_config_db #(virtual sAHBIF)::set(null, "interfaces", "bm2s" , bm2s);
    uvm_config_db #(virtual sAHBIF)::set(null, "interfaces", "bm3s" , bm3s);
    uvm_config_db #(virtual sAHBIF)::set(null, "interfaces", "bm4s" , bm4s);
    uvm_config_db #(virtual sAHBIF)::set(null, "interfaces", "bm5s" , bm5s);
    uvm_config_db #(virtual sAHBIF)::set(null, "interfaces", "bm6s" , bm6s);
    uvm_config_db #(virtual sAHBIF)::set(null, "interfaces", "bm7s" , bm7s);
    
end

initial begin
    $dumpfile("ahb.vcd");
    $dumpvars(9,top);
end

endmodule : top
