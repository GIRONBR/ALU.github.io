`timescale 1ns / 1ps

module expendedora_completa (
    input clk,           // Reloj de 100 MHz
    input btnC,          // BOTON DE RESETEO 
    input btnU, btnL, btnR, btnD,  // Botones de entrada
    output [2:0] led     // LEDs para indicar bebida
);

    // =======================
    // Divisor de reloj
    // =======================
    reg [31:0] myreg = 0;
    wire slow_clk;

    assign slow_clk = myreg[26];  // Frecuencia ~0.67 Hz

    always @(posedge clk or posedge btnC) begin
        if (btnC)
            myreg <= 32'b0;
        else
            myreg <= myreg + 1;
    end

    // =======================
    // Máquina de Estados
    // =======================
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

    assign led[0] = m1;
    assign led[1] = m2;
    assign led[2] = m3;

endmodule

