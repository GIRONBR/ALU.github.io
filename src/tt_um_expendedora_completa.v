`default_nettype none
`timescale 1ns / 1ps

// ==========================================
// Wrapper para Tiny Tapeout + lógica completa
// ==========================================
module tt_um_expendedora (
    input  wire [7:0] ui_in,    // Entradas dedicadas
    output wire [7:0] uo_out,   // Salidas dedicadas
    input  wire [7:0] uio_in,   // Pines bidireccionales (entrada)
    output wire [7:0] uio_out,  // Pines bidireccionales (salida)
    output wire [7:0] uio_oe,   // Habilitación de los uio (1 = salida)
    input  wire       ena,      // Enable (siempre 1)
    input  wire       clk,      // Reloj (100 MHz)
    input  wire       rst_n     // Reset activo en bajo
);

    // ========================
    // Asignación de señales de entrada
    // ========================
    wire btnC = ~rst_n;  // botón de reset desde rst_n
    wire btnU = ui_in[0]; // botón up
    wire btnL = ui_in[1]; // botón left
    wire btnR = ui_in[2]; // botón right
    wire btnD = ui_in[3]; // botón down

    // ========================
    // Divisor de reloj (~0.67 Hz)
    // ========================
    reg [31:0] myreg = 0;
    wire slow_clk = myreg[26];

    always @(posedge clk or posedge btnC) begin
        if (btnC)
            myreg <= 32'b0;
        else
            myreg <= myreg + 1;
    end

    // ========================
    // Máquina de estados
    // ========================
    reg [1:0] state = 2'd0;
    reg [1:0] nextstate;

    reg m1, m2, m3;

    // Registro de estado
    always @(posedge slow_clk or posedge btnC) begin
        if (btnC)
            state <= 2'd0;
        else
            state <= nextstate;
    end

    // Transiciones
    always @(*) begin
        nextstate = state;
        case (state)
            2'd0: if (btnU) nextstate = 2'd1;
            2'd1: begin
                if (btnU) nextstate = 2'd2;
                else if (btnL) nextstate = 2'd0;
            end
            2'd2: begin
                if (btnU) nextstate = 2'd3;
                else if (btnL) nextstate = 2'd1;
                else if (btnR) nextstate = 2'd0;
            end
            2'd3: begin
                if (btnU) nextstate = 2'd3;
                else if (btnL) nextstate = 2'd2;
                else if (btnR) nextstate = 2'd1;
                else if (btnD) nextstate = 2'd0;
            end
        endcase
    end

    // Salidas de bebida
    always @(*) begin
        m1 = 0; m2 = 0; m3 = 0;
        case (state)
            2'd1: if (btnL) m1 = 1;
            2'd2: begin
                if (btnL) m1 = 1;
                else if (btnR) m2 = 1;
            end
            2'd3: begin
                if (btnL) m1 = 1;
                else if (btnR) m2 = 1;
                else if (btnD) m3 = 1;
            end
        endcase
    end

    // ========================
    // Asignación de salidas (LEDs)
    // ========================
    assign uo_out[0] = m1;        // LED bebida 1
    assign uo_out[1] = m2;        // LED bebida 2
    assign uo_out[2] = m3;        // LED bebida 3
    assign uo_out[7:3] = 5'b0;    // No usados

    assign uio_out = 8'b0;        // No se usan pines bidireccionales como salida
    assign uio_oe  = 8'b0;        // Todos los uio como entrada (no habilitados)

    // Prevenir warnings de señales no utilizadas
    wire _unused = &{ena};

endmodule

