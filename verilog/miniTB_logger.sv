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

/*
  Class: miniTB_logger
*/
class miniTB_logger;


  /*
    String: name
    Name of class instance
  */
  protected string name;


  /*
    uint: error_count
    Counter for number of errors
  */
  local int unsigned error_count = 0;


  /*
    Variable: success
    Contains Pass or Fail for success of the unit test
  */
  local results_t success;


  /*
    Variable: is_running
    1 is somewhere between setup and teardown, 1 otherwise
  */
  bit is_running = 0;


  extern function new(string name);

  extern virtual task setup();

  extern virtual protected task run_test();

  extern virtual protected task miniTB_tests();

  extern virtual task teardown();

  extern virtual function void update_exit_status();

  extern task run();
  extern function void report();

  extern local function void fail(string s);

  extern task wait_for_error();
  extern function integer get_error_count();
  extern task give_up();

  extern function bit fail_if(bit b, string s, string f, int l);
  extern function bit fail_unless(bit b, string s, string f, int l);

  extern function string    get_name();
  extern function results_t get_results();

endclass


/*
  Constructor: new
  Initializes the unit test

  Parameters:
    name - instance name of the unit test

*/
function miniTB_logger::new(string name);
  this.name = name;
endfunction


/*
  Method: fail
  Increments Test Result's error count and displays message
  
  Parameters:
    s - display statement to print out
*/
function void miniTB_logger::fail(string s);
  error_count++;
  `ERROR($psprintf("%s: FAIL", s));
endfunction



/*
  Method: wait_for_error
  Blocks until the error_count changes
*/
task miniTB_logger::wait_for_error();
  @(error_count);
endtask


/*
  Method: get_error_count
  returns the error count
*/
function integer miniTB_logger::get_error_count();
  return error_count;
endfunction


/*
  Method: give_up
  blocks indefinitely (Should only be called by `FAIL_IF)
*/
task miniTB_logger::give_up();
  event never;
  @(never);
endtask

/*
  Method: fail_if
  calls fail if expression is true

  Parameters:
    b - evaluation of expression (0 - false, 1 - true)
    s - string to pass to pass or fail task
    f - file name of the failure
    l - line number of the failure

    return 1 if fail else 0
*/
function bit miniTB_logger::fail_if(bit b, string s, string f, int l);
  if (b) begin
    fail($psprintf("fail_if: %s (at %s line:%0d)", s, f, l));
    return 1;
  end
  else begin
    return 0;
  end
endfunction


/*
  Method: fail_unless
  calls fail if expression is not true

  Parameters:
    b - evaluation of expression (0 - false, 1 - true)
    s - string to pass to pass or fail task

    return 1 if fail else 0
*/
function bit miniTB_logger::fail_unless(bit b, string s, string f, int l);
  if (!b) begin
    fail($psprintf("fail_unless: %s (at %s line:%0d)", s, f, l));
    return 1;
  end
  else begin
    return 0;
  end
endfunction


/*
  Function: get_name
  Returns instance name of the unit test
*/
function string miniTB_logger::get_name();
  return name;
endfunction


/*
  Function: get_results
  Returns success of the unit test case
*/
function results_t miniTB_logger::get_results();
  return success;
endfunction


/*
  Method: report
  This task reports the results for the unit tests
*/  
function void miniTB_logger::report();
  if (success == PASS)
    `INFO($psprintf("%0s::PASSED", name));
  else
    `INFO($psprintf("%0s::FAILED", name));
endfunction


/*
  Method: run
  Main run task for the unit test
*/
task miniTB_logger::run();
  run_test();
endtask


/*
  Method: run_test
  execute the list of registered unit tests 
*/
task miniTB_logger::run_test();
  `INFO($psprintf("%s::RUNNING", name));
  miniTB_tests();
endtask


/*
  Method: miniTB_tests
  invoke the unit tests registed with the SMOKE_TEST_BEGIN/END macros
*/
task miniTB_logger::miniTB_tests();
endtask


/*
  Method: setup
  Only required if using VCS since pure virtual functions are not implemented
*/
task miniTB_logger::setup();
endtask


/*
  Method: teardown
  Registers test as passed or failed
*/
task miniTB_logger::teardown();
endtask


function void miniTB_logger::update_exit_status();
  if (error_count == 0)
    success = PASS;
  else
    success = FAIL;
endfunction

