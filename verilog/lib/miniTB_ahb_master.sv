//###############################################################
//
//  Licensed to the Apache Software Foundation (ASF) under one
//  or more contributor license agreements.  See the NOTICE file
//  distributed with this work for additional information
//  regarding copyright ownership.  The ASF licenses this file
//  to you under the Apache License, Version 2.0 (the
//  "License"); you may not use this file except in compliance
//  with the License.  You may obtain a copy of the License at
//  
//  http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the License is distributed on an
//  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
//  KIND, either express or implied.  See the License for the
//  specific language governing permissions and limitations
//  under the License.
//
//###############################################################

interface minitb_ahb_master
#(
  addrWidth = 8,
  dataWidth = 32
)
(
  input hclk
);

//logic                 hgrantx;
//logic                 hbusreqx;
//logic                 hlockx;
//
logic                 hready;
logic                 hready_d1;
//logic [1:0]           hresp;
//
logic [1:0]           htrans;
logic [1:0]           htrans_d1;
logic [1:0]           m_trans [$];

logic [addrWidth-1:0] haddr;
logic [addrWidth-1:0] haddr_d1;
logic [addrWidth-1:0] m_addr [$];
logic                 hwrite;
logic                 hwrite_d1;
logic                 m_write [$];
//logic [2:0]           hsize;
//logic [2:0]           hburst;
//logic [3:0]           hprot;
//
logic [dataWidth-1:0] hwdata;
logic [dataWidth-1:0] next_hwdata;
logic [dataWidth-1:0] m_wdata [$];

logic [dataWidth-1:0] hrdata;
logic [dataWidth-1:0] rdata;
event rdata_e;

parameter IDLE   = 2'b00,
          NONSEQ = 2'b10;

logic data_phase = 0;
logic addr_phase = 0;

//
// reset
//
function void reset();
  htrans = IDLE;
  haddr  = 'hx;
  hwrite = 'hx;
  hwdata = 'hx;
  data_phase = 0;
  addr_phase = 0;
endfunction


//
// idle
//
task idle();
  if (!data_phase) @(negedge hclk);
  reset();
  data_phase = 0;
endtask


//
// pipelined_write
//
task automatic pipelined_write(logic [addrWidth-1:0] addr,
                               logic [dataWidth-1:0] data);
endtask


//
// basic_write
//
task automatic basic_write(logic [addrWidth-1:0] addr,
                           logic [dataWidth-1:0] data);
  m_write.push_back(1);
  m_addr.push_back(addr);
  m_wdata.push_back(data);
  m_trans.push_back(NONSEQ);

  @(negedge hclk);
endtask


//
// basic_read
//
task automatic basic_read(logic [addrWidth-1:0] addr,
                          ref logic [dataWidth-1:0] data);
  m_write.push_back(0);
  m_addr.push_back(addr);
  m_wdata.push_back('hx);
  m_trans.push_back(NONSEQ);

  @(rdata_e) data = rdata;
endtask

logic address_phase;
always @(negedge hclk) begin
  hwdata <= next_hwdata;
  hready_d1 <= hready;

  if (address_phase) begin
    haddr_d1 <= haddr;
    hwrite_d1 <= hwrite;
    htrans_d1 <= htrans;
  end

  if (m_addr.size() > 0) begin
    address_phase <= 1;
    haddr <= m_addr.pop_front();
    hwrite <= m_write.pop_front();
    htrans <= m_trans.pop_front();
    next_hwdata <= m_wdata.pop_front();
  end

  else begin
    address_phase <= 0;
    htrans <= 'h0;
    haddr <= 'hx;
    hwrite <= 'hx;
    if (hready) begin
      next_hwdata <= 'hx;
    end
  end
end

always @(posedge hclk) begin
  #1;
  if (htrans == NONSEQ && !hwrite && hready) begin
    rdata = hrdata;
    -> rdata_e;
  end

  else if (htrans_d1 == NONSEQ && !hwrite_d1 && hready && !hready_d1) begin
    rdata = hrdata;
    -> rdata_e;
  end
end

endinterface
