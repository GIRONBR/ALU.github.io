`default_nettype none

module tt_um_mialu (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    // Asignar entradas
    wire [1:0] A = ui_in[1:0];
    wire [1:0] B = ui_in[3:2];
    wire [2:0] control = ui_in[6:4];

    wire [2:0] result;
    wire       overflow;

    ALU_Pequeña alu (
        .A(A),
        .B(B),
        .control(control),
        .result(result),
        .overflow(overflow)
    );

    assign uo_out = {4'b0000, overflow, result}; // 8 bits totales
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    wire _unused = &{uio_in, ena, clk, rst_n};

endmodule

// ===============================
// ALU con entradas de 2 bits
// ===============================
module ALU_Pequeña (
    input  wire [1:0] A,
    input  wire [1:0] B,
    input  wire [2:0] control,
    output reg  [2:0] result,
    output wire       overflow
);

    wire [2:0] suma = A + B;
    wire [2:0] resta = A - B;
    wire [1:0] and_op = A & B;
    wire [1:0] or_op  = A | B;
    wire [1:0] xor_op = A ^ B;
    wire [1:0] not_op = ~A;
    wire [2:0] shl    = A << 1;
    wire [2:0] shr    = A >> 1;

    assign overflow = suma[2]; // bit 2 es overflow para suma

    always @(*) begin
        case (control)
            3'b000: result = suma;
            3'b001: result = resta;
            3'b010: result = {1'b0, and_op};
            3'b011: result = {1'b0, or_op};
            3'b100: result = {1'b0, xor_op};
            3'b101: result = {1'b0, not_op};
            3'b110: result = shl;
            3'b111: result = shr;
            default: result = 3'b000;
        endcase
    end

endmodule
t

