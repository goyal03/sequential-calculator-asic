`timescale 1ns/1ps

module calculator_tb;

reg clk;
reg rst_n;
reg start;
reg [1:0] op;
reg [15:0] a;
reg [15:0] b;


wire [15:0] result;
wire overflow;
wire done;
wire error;

//=============================================================================
// Test Counters
//=============================================================================
integer test_count;
integer pass_count;
integer fail_count;


//=============================================================================
// Instantiate Calculator (DUT - Device Under Test)
//=============================================================================
calculator dut (
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .op(op),
    .a(a),
    .b(b),
    .result(result),
    .overflow(overflow),
    .done(done),
    .error(error)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;  // Toggle every 5ns -> 10ns period
end

//=============================================================================
// Reset and Initial Stimulus
//=============================================================================
initial begin
    // Initialize all inputs
    rst_n = 0;
    start = 0;
    op    = 2'b00;
    a     = 16'd0;
    b     = 16'd0;

        // Initialize counters
    test_count = 0;
    pass_count = 0;
    fail_count = 0;


    // Hold reset low for a few cycles
    #20;
    rst_n = 1;

    // Wait after reset release
    #10;
end

//=============================================================================
// Task: Run One Test Case
//=============================================================================
task run_test;
    input [15:0] val_a;
    input [15:0] val_b;
    input [1:0]  operation;
    input [15:0] expected;
    input        expect_error;


    begin
        test_count = test_count + 1;

        // Apply inputs
        a  = val_a;
        b  = val_b;
        op = operation;

        // Start pulse (1 clock cycle)
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;

        // Wait until done goes high
        wait(done == 1);
        @(posedge clk);

        // Check results
        if (expect_error) begin
            if (error == 1) begin
                pass_count = pass_count + 1;
                $display("PASS [%0d] Error detected correctly", test_count);
            end else begin
                fail_count = fail_count + 1;
                $display("FAIL [%0d] Expected error flag", test_count);
            end
        end
        else begin
            if ((result == expected) && (error == 0)) begin
                pass_count = pass_count + 1;
                $display("PASS [%0d] Result = %0d", test_count, result);
            end else begin
                fail_count = fail_count + 1;
                $display("FAIL [%0d] Expected=%0d Got=%0d Error=%b",
                          test_count, expected, result, error);
            end
        end

        // Gap before next test
        repeat(2) @(posedge clk);
    end
endtask

//=============================================================================
// Main Test Sequence (50 Test Cases)
//=============================================================================
initial begin
    // Wait until reset is released
    wait(rst_n == 1);

    $dumpfile("calculator_tb.vcd");     // ADD THIS LINE
    $dumpvars(0, calculator_tb);        // ADD THIS LINE

    $display("\n===============================");
    $display(" Starting Calculator Testbench ");
    $display("===============================\n");

    // ----------------------------------------------------
    // 20 ADD Test Cases (op = 00)
    // ----------------------------------------------------
    run_test(10, 5,   2'b00, 15, 0);
    run_test(100, 25, 2'b00, 125, 0);
    run_test(1, 1,    2'b00, 2, 0);
    run_test(50, 60,  2'b00, 110, 0);
    run_test(0, 0,    2'b00, 0, 0);

    run_test(200, 300, 2'b00, 500, 0);
    run_test(15,  20,  2'b00, 35, 0);
    run_test(99,  1,   2'b00, 100, 0);
    run_test(500, 500, 2'b00, 1000, 0);
    run_test(7,   8,   2'b00, 15, 0);

    run_test(11, 22,   2'b00, 33, 0);
    run_test(123, 321, 2'b00, 444, 0);
    run_test(400, 100, 2'b00, 500, 0);
    run_test(655, 1,   2'b00, 656, 0);
    run_test(12,  34,  2'b00, 46, 0);

    run_test(9,   9,   2'b00, 18, 0);
    run_test(45,  55,  2'b00, 100, 0);
    run_test(1000, 24, 2'b00, 1024, 0);
    run_test(16,  16,  2'b00, 32, 0);
    run_test(250, 250, 2'b00, 500, 0);

    // ----------------------------------------------------
    // 15 SUB Test Cases (op = 01)
    // ----------------------------------------------------
    run_test(20, 5,   2'b01, 15, 0);
    run_test(50, 25,  2'b01, 25, 0);
    run_test(10, 10,  2'b01, 0, 0);
    run_test(100, 1,  2'b01, 99, 0);
    run_test(500, 200,2'b01, 300, 0);

    run_test(30, 15,  2'b01, 15, 0);
    run_test(99, 50,  2'b01, 49, 0);
    run_test(1000,500,2'b01, 500, 0);
    run_test(77, 7,   2'b01, 70, 0);
    run_test(44, 22,  2'b01, 22, 0);

    run_test(60, 30,  2'b01, 30, 0);
    run_test(25, 10,  2'b01, 15, 0);
    run_test(90, 45,  2'b01, 45, 0);
    run_test(81, 9,   2'b01, 72, 0);
    run_test(100,99,  2'b01, 1, 0);

    // ----------------------------------------------------
    // 10 MUL Test Cases (op = 10)
    // ----------------------------------------------------
    run_test(2,  3,   2'b10, 6, 0);
    run_test(5,  5,   2'b10, 25, 0);
    run_test(10, 10,  2'b10, 100, 0);
    run_test(4,  8,   2'b10, 32, 0);
    run_test(6,  7,   2'b10, 42, 0);

    run_test(9,  9,   2'b10, 81, 0);
    run_test(12, 3,   2'b10, 36, 0);
    run_test(15, 2,   2'b10, 30, 0);
    run_test(7,  11,  2'b10, 77, 0);
    run_test(16, 4,   2'b10, 64, 0);

    // ----------------------------------------------------
    // 5 DIV Test Cases (op = 11)
    // ----------------------------------------------------
    run_test(100, 10, 2'b11, 10, 0);
    run_test(81,  9,  2'b11, 9, 0);
    run_test(50,  7,  2'b11, 7, 0);
    run_test(4,  20,  2'b11, 0, 0);

    // Division by zero case
    run_test(25,  0,  2'b11, 0, 1);

    // ----------------------------------------------------
    // Final Summary
    // ----------------------------------------------------
    $display("\n===============================");
    $display(" TESTBENCH COMPLETE ");
    $display(" TOTAL TESTS : %0d", test_count);
    $display(" PASSED      : %0d", pass_count);
    $display(" FAILED      : %0d", fail_count);
    $display("===============================\n");

    $finish;
end
endmodule