//Module 16-bit sequential calculator
//Description: Performs addition, subtraction, mltiplication and division (16-bits)
//Author: Harsh Agrawal


module calculator(
    //clock and reset suignals
    input wire clk,         //System clock
    input wire rst_n,       //Active low reset
    
    //Control signals
    input wire start,       //Start operation
    input wire[1:0] op,     //Operation: 00:ADD,01:SUB,10:MUL,11:DIV

    //Data Inputs
    input wire [15:0] a,    //First operand
    input wire [15:0] b,    //Second operand

    //Output
    output reg [15:0] result,   //Result of operation
    output reg overflow,
    output reg done,        //Operation completed flag
    output reg error        //Error flag(division by zero)
);
localparam IDLE = 3'b000;
localparam CALC = 3'b001;
localparam DONE = 3'b010;


reg [2:0] state, next_state;
reg [4:0] count;
reg [15:0] temp_a, temp_b;
reg [31:0] product;
reg [15:0] quotient, remainder;


always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= IDLE;
        count <= 5'd0;
    end else begin
        state <= next_state;

        // Count only during CALC for MUL/DIV
        if (state == IDLE) begin
            count <= 5'd0;
        end
        else if (state == CALC && (op == 2'b10 || op == 2'b11)) begin
            count <= count + 1'b1;
        end
    end
end

always @(*) begin
    next_state = state;
    
    case (state)
        IDLE: begin
            if (start)
                next_state = CALC;
        end
        
        CALC: begin
            if (op == 2'b00 || op == 2'b01)   // ADD / SUB
                next_state = DONE;
            else if (count == 5'd16)         // MUL / DIV
                next_state = DONE;
        end
        
        DONE: begin
            if (!start)
                next_state = IDLE;
        end
        
        default: next_state = IDLE;
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        // Reset all outputs and internal registers
        result    <= 16'd0;
        done      <= 1'b0;
        error     <= 1'b0;
        overflow  <= 1'b0;
        temp_a    <= 16'd0;
        temp_b    <= 16'd0;
        product   <= 32'd0;
        quotient  <= 16'd0;
        remainder <= 16'd0;
    end else begin
        case (state)
            IDLE: begin
                done     <= 1'b0;
                error    <= 1'b0;
                overflow <= 1'b0;
                
                // Capture inputs when start is pressed
                if (start) begin
                    temp_a <= a;
                    temp_b <= b;
                    
                    // Initialize for multiplication
                    if (op == 2'b10) begin
                        product <= 32'd0;
                    end
                    
                    // Initialize for division
                    if (op == 2'b11) begin
                        quotient  <= 16'd0;
                        remainder <= 16'd0;
                    end
                end
            end

            CALC: begin
                case(op)
                    2'b00: begin    //addition
                        result <= temp_a + temp_b;
                        overflow <= (temp_a[15] == temp_b[15]) && (result[15] != temp_a[15]);  // Signed overflow check
                    end

                    2'b01: begin        //subtraction
                        result <= temp_a - temp_b;
                        overflow <= (temp_a[15] != temp_b[15]) && (result[15] != temp_a[15]);  // Signed overflow check
                    end

                    2'b10: begin        // multiplication
                        if (count < 5'd16) begin
                            // If LSB of temp_b is 1, add temp_a to product
                            if (temp_b[0]) begin
                                product <= product + {16'd0, temp_a};
                            end
                            // Shift temp_b right, shift product left
                            temp_b  <= temp_b >> 1;
                            temp_a  <= temp_a << 1;
                        end else begin
                            // Multiplication complete
                            result   <= product[15:0];  // Take lower 16 bits
                            overflow <= |product[31:16]; // Check if upper bits are non-zero
                        end
                    end

                    2'b11: begin  // DIVISION (Restoring Division)
                        if (temp_b == 16'd0) begin
                            // Division by zero
                            error  <= 1'b1;
                            result <= 16'd0;
                        end else begin
                            if (count < 5'd16) begin
                                // Shift remainder left and bring in bit from dividend
                                remainder <= {remainder[14:0], temp_a[15]};
                                temp_a    <= {temp_a[14:0], 1'b0};  // Shift dividend left
                                
                                // Try subtraction
                                if ({remainder[14:0], temp_a[15]} >= temp_b) begin
                                    remainder <= {remainder[14:0], temp_a[15]} - temp_b;
                                    quotient  <= {quotient[14:0], 1'b1};  // Quotient bit = 1
                                end else begin
                                    // Remainder stays as shifted value
                                    quotient  <= {quotient[14:0], 1'b0};  // Quotient bit = 0
                                end
                            end else begin
                                // Division complete
                                result <= quotient;
                                error  <= 1'b0;
                            end
                        end
                    end
                endcase  // End of op case
            end  // End of CALC state

            DONE: begin
                done <= 1'b1;

            end

            default: begin
                result <= 16'd0;
                done <= 1'b0;
                error <= 1'b0;
                overflow <= 1'b0;
            end
        endcase
    end
end

endmodule