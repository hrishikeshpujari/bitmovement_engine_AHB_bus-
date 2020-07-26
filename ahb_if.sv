
// A simple interface for AHB use in class
//

interface mAHBIF(input reg HCLK,HRESET);
    logic HBUSREQ,HGRANT,HREADYin;
    logic [1:0] HRESP;
    logic [31:0] HRDATA,HWDATA,HADDR;
    logic HLOCK;    // not used
    logic [1:0] HTRANS;
    logic HWRITE;
    logic [2:0] HSIZE; // only 32 bits used
    logic [2:0] HBURST;
    logic [3:0] HPROT;     // not used
    logic [3:0] HMASTER;   // not used
    logic HMASTLOCK;       // not used

    modport AHBM( input HCLK, input HRESET,
        input HGRANT, output HBUSREQ, 
        input HREADYin,input HRESP, output HPROT,
        input HRDATA,output HTRANS, output HADDR,
        output HWRITE, output HWDATA, output HSIZE, output HBURST);

    modport AHBMfab(input HCLK, input HRESET,
        output HGRANT, input HBUSREQ, 
        output HREADYin,output HRESP, input HPROT,
        output HRDATA,input HTRANS, input HADDR,
        input HWRITE, input HWDATA, input HSIZE, input HBURST);

endinterface : mAHBIF

interface sAHBIF(input reg HCLK,HRESET);
    logic HREADYin;
    logic HREADY;
    logic HSEL;
    logic [1:0] HRESP;
    logic [31:0] HRDATA,HWDATA,HADDR;
    logic HLOCK;            // not used
    logic [1:0] HTRANS;
    logic HWRITE;
    logic [2:0] HSIZE;      // only 32 bits used
    logic [2:0] HBURST;
    logic [3:0] HPROT;     // not used
    logic [3:0] HMASTER;   // not used
    logic HMASTLOCK;       // not used

    modport AHBS( input HCLK, input HRESET,
        output HREADY, input HREADYin,input HSEL, 
        output HRESP, input HPROT,
        output HRDATA,input HTRANS, input HADDR,
        input HWRITE, input HWDATA, input HSIZE, input HBURST);

    modport AHBSfab(input HCLK, input HRESET,
        input HREADY, output HREADYin,input HRESP, output HSEL, 
        output HPROT,
        input HRDATA,output HTRANS, output HADDR,
        output HWRITE, output HWDATA, output HSIZE, output HBURST);

endinterface : sAHBIF
