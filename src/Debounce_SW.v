module Debounce_SW (

    input wire        clk,
    input wire [9:0]  SW,

    output reg [9:0]  SW_estavel

);

    // Sincronização

    reg [9:0] SW_1;
    reg [9:0] SW_2;


    // Contador

    reg [22:0] contador;

    // Debouncer

    always @(posedge clk) begin

        // Sincroniza os switches

        SW_1 <= SW;
        SW_2 <= SW_1;


        // Verifica se o valor mudou

        if (SW_2 != SW_estavel) begin

            contador <= contador + 1;

            // Se permaneceu diferente por tempo suficiente
            if (contador == 16'hFFFF) begin

                SW_estavel <= SW_2;
                contador <= 0;

            end

        end

        else begin

            contador <= 0;

        end

    end

endmodule