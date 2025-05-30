`default_nettype none

// Wrapper requerido por Tiny Tapeout
module tt_um_mialu (
    input  wire [7:0] ui_in,    // Entradas dedicadas
    output wire [7:0] uo_out,   // Salidas dedicadas
    input  wire [7:0] uio_in,   // Pines bidireccionales (entrada)
    output wire [7:0] uio_out,  // Pines bidireccionales (salida)
    output wire [7:0] uio_oe,   // Habilitación de los uio (1 = salida)
    input  wire       ena,      // Enable (siempre 1)
    input  wire       clk,      // Reloj
    input  wire       rst_n     // Reset activo en bajo
);

    // Combinar ui_in y uio_in en un solo bus de entrada
    wire [15:0] sw;
    assign sw = {uio_in, ui_in};  // sw[15:0] = uio_in[7:0] ++ ui_in[7:0]

    // Salida de la ALU
    wire [6:0] led;

    // Instancia de la ALU
    ALU_Completa alu (
        .sw(sw),
        .led(led)
    );

    // Asignar salida a los pines de salida dedicados
    assign uo_out = {1'b0, led};  // led[6:0] en uo_out[6:0], relleno con 0 en MSB
    assign uio_out = 8'b0;        // no usamos salidas bidireccionales
    assign uio_oe  = 8'b0;        // todos los uio como entrada

    // Para evitar warnings de señales no utilizadas
    wire _unused = &{ena, clk, rst_n, 1'b0};

endmodule

// ============================
// Módulo ALU principal
// ============================
module ALU_Completa(
    input  logic [15:0] sw,
    output logic [6:0]  led
);

    logic [5:0] suma_resultado;
    logic [5:0] resta_resultado;
    logic [5:0] and_resultado;
    logic [5:0] or_resultado;
    logic [5:0] xor_resultado;
    logic [5:0] not_resultado;
    logic [5:0] shift_left_resultado;
    logic [5:0] shift_right_resultado;

    logic [4:0] A_principal;
    logic [4:0] B_principal;
    logic [2:0] control;
    logic [5:0] resultado;
    logic       overflow;

    assign A_principal = sw[4:0];
    assign B_principal = sw[9:5];
    assign control     = sw[14:12];

    assign led[5:0] = resultado;
    assign led[6]   = overflow;

    sumador_completo sumador (
        .A(A_principal),
        .B(B_principal),
        .SUM(suma_resultado)
    );

    Restador_completo restador (
        .A(A_principal),
        .B(B_principal),
        .DIFF(resta_resultado)
    );

    assign and_resultado  = {1'b0, A_principal & B_principal};
    assign or_resultado   = {1'b0, A_principal | B_principal};
    assign xor_resultado  = {1'b0, A_principal ^ B_principal};
    assign not_resultado  = {1'b0, ~A_principal};
    assign shift_left_resultado  = {1'b0, A_principal} << 1;
    assign shift_right_resultado = {1'b0, A_principal} >> 1;

    assign overflow = suma_resultado[5];

    always_comb begin
        case (control)
            3'b000: resultado = suma_resultado;
            3'b001: resultado = resta_resultado;
            3'b010: resultado = and_resultado;
            3'b011: resultado = or_resultado;
            3'b100: resultado = xor_resultado;
            3'b101: resultado = not_resultado;
            3'b110: resultado = shift_left_resultado;
            3'b111: resultado = shift_right_resultado;
            default: resultado = 6'd0;
        endcase
    end

endmodule

// ============================
// Sumador de 5 bits con acarreo
// ============================
module sumador_completo(
    input  logic [4:0] A,
    input  logic [4:0] B,
    output logic [5:0] SUM
);
    logic [4:0] G;
    logic [4:0] P;
    logic [5:0] C;
    logic [4:0] S;

    assign G = A & B;
    assign P = A ^ B;

    assign C[0] = 1'b0;
    assign C[1] = G[0] | (P[0] & C[0]);
    assign C[2] = G[1] | (P[1] & G[0]) | (P[1] & P[0] & C[0]);
    assign C[3] = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) | (P[2] & P[1] & P[0] & C[0]);
    assign C[4] = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) |
                  (P[3] & P[2] & P[1] & G[0]) |
                  (P[3] & P[2] & P[1] & P[0] & C[0]);
    assign C[5] = G[4] | (P[4] & G[3]) | (P[4] & P[3] & G[2]) |
                  (P[4] & P[3] & P[2] & G[1]) |
                  (P[4] & P[3] & P[2] & P[1] & G[0]) |
                  (P[4] & P[3] & P[2] & P[1] & P[0] & C[0]);

    assign S = P ^ C[4:0];
    assign SUM = {C[5], S};
endmodule

// ============================
// Restador directo (combinacional)
// ============================
module Restador_completo(
    input  logic [4:0] A,
    input  logic [4:0] B,
    output logic [5:0] DIFF
);
    assign DIFF = A - B;
endmodule

