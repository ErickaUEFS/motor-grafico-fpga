module Motor_Rasterizador(
    
    input wire        clk,
    input wire [9:0]  next_x,
    input wire [9:0]  next_y,

    // Interface de controle   

    input wire        controle_ativo,
    input wire [2:0]  indice,
    input wire        visibilidade,
    input wire        mover,
    input wire [1:0]  direcao,

    output reg [7:0]  color_index

);

    // Direções

    localparam CIMA     = 2'b00;
    localparam BAIXO    = 2'b01;
    localparam ESQUERDA = 2'b10;
    localparam DIREITA  = 2'b11;

    // Resolução lógica

    wire [8:0] logico_x = next_x;
    wire [8:0] logico_y = next_y;

    // Informações dos polígonos

    reg [9:0] posX0 [0:9];
    reg [9:0] posY0 [0:9];

    reg [9:0] posX1 [0:9];
    reg [9:0] posY1 [0:9];

    reg [9:0] posX2 [0:9];
    reg [9:0] posY2 [0:9];

    reg [9:0] posX3 [0:9];
    reg [9:0] posY3 [0:9];

    reg poligono_ativo [0:9];
    reg poligono_tipo  [0:9];
    reg [7:0] poligono_cor [0:9];

    // Inicialização

    reg [21:0] contador;
	 
	 initial begin
	 			contador = 0;
				end
	 
	 
initial begin
			
    integer i;

    for (i = 0; i < 10; i = i + 1) begin

        poligono_ativo[i] = 0;

        posX0[i] = 0;
        posY0[i] = 0;

        posX1[i] = 0;
        posY1[i] = 0;

        posX2[i] = 0;
        posY2[i] = 0;

        posX3[i] = 0;
        posY3[i] = 0;

        poligono_tipo[i] = 0;
        poligono_cor[i] = 0;

    end

    // POLÍGONO 0 - TRIÂNGULO ISÓSCELES
    //
    // Base = 60
    // Altura = 50
    //
    // Os dois lados inclinados possuem o mesmo comprimento.

    poligono_ativo[0] = 1;

    posX0[0] = 30;
    posY0[0] = 30;

    posX1[0] = 90;
    posY1[0] = 30;

    posX2[0] = 60;
    posY2[0] = 80;

    poligono_tipo[0] = 1;
    poligono_cor[0] = 8'd4;

    // POLÍGONO 1 - TRIÂNGULO EQUILÁTERO
    //
    // Lado = 50
    //
    // Altura aproximada:
    // 50 * sqrt(3) / 2 ≈ 43

    poligono_ativo[1] = 1;

    posX0[1] = 125;
    posY0[1] = 30;

    posX1[1] = 175;
    posY1[1] = 30;

    posX2[1] = 150;
    posY2[1] = 73;

    poligono_tipo[1] = 1;
    poligono_cor[1] = 8'd3;

    // POLÍGONO 2 - TRIÂNGULO ESCALENO
    //
    // Os três lados possuem comprimentos diferentes.

    poligono_ativo[2] = 1;

    posX0[2] = 220;
    posY0[2] = 30;

    posX1[2] = 290;
    posY1[2] = 30;

    posX2[2] = 250;
    posY2[2] = 80;

    poligono_tipo[2] = 1;
    poligono_cor[2] = 8'd2;

    // POLÍGONO 3 - QUADRADO
    //
    // Lado = 50

    poligono_ativo[3] = 1;

    posX0[3] = 30;
    posY0[3] = 120;

    posX1[3] = 80;
    posY1[3] = 120;

    posX2[3] = 80;
    posY2[3] = 170;

    posX3[3] = 30;
    posY3[3] = 170;

    poligono_tipo[3] = 0;
    poligono_cor[3] = 8'd5;

    // POLÍGONO 4 - RETÂNGULO
    //
    // Largura = 80
    // Altura  = 40

    poligono_ativo[4] = 1;

    posX0[4] = 130;
    posY0[4] = 120;

    posX1[4] = 210;
    posY1[4] = 120;

    posX2[4] = 210;
    posY2[4] = 160;

    posX3[4] = 130;
    posY3[4] = 160;

    poligono_tipo[4] = 0;
    poligono_cor[4] = 8'd1;


end

    // Movimento

    localparam LIMITE = 500_000 - 1;

    // Limites do polígono selecionado

    reg signed [10:0] menor_x;
    reg signed [10:0] maior_x;
    reg signed [10:0] menor_y;
    reg signed [10:0] maior_y;

    // Cálculo dos limites

    always @(*) begin

        // Começa usando o primeiro vértice

        menor_x = posX0[indice];
        maior_x = posX0[indice];

        menor_y = posY0[indice];
        maior_y = posY0[indice];

        // Vértice 1

        if (posX1[indice] < menor_x)
            menor_x = posX1[indice];

        if (posX1[indice] > maior_x)
            maior_x = posX1[indice];

        if (posY1[indice] < menor_y)
            menor_y = posY1[indice];

        if (posY1[indice] > maior_y)
            maior_y = posY1[indice];

        // Vértice 2

        if (posX2[indice] < menor_x)
            menor_x = posX2[indice];

        if (posX2[indice] > maior_x)
            maior_x = posX2[indice];

        if (posY2[indice] < menor_y)
            menor_y = posY2[indice];

        if (posY2[indice] > maior_y)
            maior_y = posY2[indice];

        // Vértice 3
        //
        // Só é considerado para quadriláteros.

        if (poligono_tipo[indice] == 0) begin

            if (posX3[indice] < menor_x)
                menor_x = posX3[indice];

            if (posX3[indice] > maior_x)
                maior_x = posX3[indice];

            if (posY3[indice] < menor_y)
                menor_y = posY3[indice];

            if (posY3[indice] > maior_y)
                maior_y = posY3[indice];

        end

    end

    // Movimento e visibilidade

    always @(posedge clk) begin

        // Controle da visibilidade

        if (controle_ativo) begin

            poligono_ativo[indice] <= visibilidade;

        end

        // Contador de velocidade

        if (contador == LIMITE) begin

            contador <= 0;

            // Movimento

            if (controle_ativo && mover) begin

                case (direcao)

                    // CIMA

                    CIMA: begin

                        if (menor_y > 0) begin

                            posY0[indice] <= posY0[indice] - 1;
                            posY1[indice] <= posY1[indice] - 1;
                            posY2[indice] <= posY2[indice] - 1;

                            if (poligono_tipo[indice] == 0)
                                posY3[indice] <= posY3[indice] - 1;

                        end

                    end

                    // BAIXO

                    BAIXO: begin

                        if (maior_y < 239) begin

                            posY0[indice] <= posY0[indice] + 1;
                            posY1[indice] <= posY1[indice] + 1;
                            posY2[indice] <= posY2[indice] + 1;

                            if (poligono_tipo[indice] == 0)
                                posY3[indice] <= posY3[indice] + 1;

                        end

                    end

                    // ESQUERDA

                    ESQUERDA: begin

                        if (menor_x > 0) begin

                            posX0[indice] <= posX0[indice] - 1;
                            posX1[indice] <= posX1[indice] - 1;
                            posX2[indice] <= posX2[indice] - 1;

                            if (poligono_tipo[indice] == 0)
                                posX3[indice] <= posX3[indice] - 1;

                        end

                    end

                    // DIREITA

                    DIREITA: begin

                        if (maior_x < 319) begin

                            posX0[indice] <= posX0[indice] + 1;
                            posX1[indice] <= posX1[indice] + 1;
                            posX2[indice] <= posX2[indice] + 1;

                            if (poligono_tipo[indice] == 0)
                                posX3[indice] <= posX3[indice] + 1;

                        end

                    end


                    default: begin
                    end

                endcase

            end

        end

        else begin

            contador <= contador + 1;

        end

    end

    // Edge Functions

    reg signed [21:0] edge0;
    reg signed [21:0] edge1;
    reg signed [21:0] edge2;
    reg signed [21:0] edge3;


    integer j;

    // Rasterização

    always @(*) begin

        color_index = 8'd0;

        // Percorre todos os polígonos

        for (j = 0; j < 10; j = j + 1) begin

            if (poligono_ativo[j]) begin

                // A --> B

                edge0 =
                    ($signed({1'b0,posX1[j]}) -
                     $signed({1'b0,posX0[j]}))
                    *
                    ($signed({1'b0,logico_y}) -
                     $signed({1'b0,posY0[j]}))
                    -
                    ($signed({1'b0,posY1[j]}) -
                     $signed({1'b0,posY0[j]}))
                    *
                    ($signed({1'b0,logico_x}) -
                     $signed({1'b0,posX0[j]}));
                
                // B --> C
					 
                edge1 =
                    ($signed({1'b0,posX2[j]}) -
                     $signed({1'b0,posX1[j]}))
                    *
                    ($signed({1'b0,logico_y}) -
                     $signed({1'b0,posY1[j]}))
                    -
                    ($signed({1'b0,posY2[j]}) -
                     $signed({1'b0,posY1[j]}))
                    *
                    ($signed({1'b0,logico_x}) -
                     $signed({1'b0,posX1[j]}));

                // TRIÂNGULO

                if (poligono_tipo[j] == 1) begin

                    // C --> A

                    edge2 =
                        ($signed({1'b0,posX0[j]}) -
                         $signed({1'b0,posX2[j]}))
                        *
                        ($signed({1'b0,logico_y}) -
                         $signed({1'b0,posY2[j]}))
                        -
                        ($signed({1'b0,posY0[j]}) -
                         $signed({1'b0,posY2[j]}))
                        *
                        ($signed({1'b0,logico_x}) -
                         $signed({1'b0,posX2[j]}));


                    edge3 = 22'sd0;

                    // Verifica se o pixel pertence ao triângulo
						  
					  if (poligono_cor[j] != 8'h00) begin
                    if (
                        ((edge0 >= 0) &&
                         (edge1 >= 0) &&
                         (edge2 >= 0))
                        ||
                        ((edge0 <= 0) &&
                         (edge1 <= 0) &&
                         (edge2 <= 0))
                    ) begin

                        color_index = poligono_cor[j];

                    end

                end
				end

                // QUADRILÁTERO

                else begin

                    // C --> D

                    edge2 =
                        ($signed({1'b0,posX3[j]}) -
                         $signed({1'b0,posX2[j]}))
                        *
                        ($signed({1'b0,logico_y}) -
                         $signed({1'b0,posY2[j]}))
                        -
                        ($signed({1'b0,posY3[j]}) -
                         $signed({1'b0,posY2[j]}))
                        *
                        ($signed({1'b0,logico_x}) -
                         $signed({1'b0,posX2[j]}));

                    // D --> A

                    edge3 =
                        ($signed({1'b0,posX0[j]}) -
                         $signed({1'b0,posX3[j]}))
                        *
                        ($signed({1'b0,logico_y}) -
                         $signed({1'b0,posY3[j]}))
                        -
                        ($signed({1'b0,posY0[j]}) -
                         $signed({1'b0,posY3[j]}))
                        *
                        ($signed({1'b0,logico_x}) -
                         $signed({1'b0,posX3[j]}));

                    // Verifica se o pixel pertence ao quadrilátero

					  if (poligono_cor[j] != 8'h00) begin
                    if (
                        ((edge0 >= 0) &&
                         (edge1 >= 0) &&
                         (edge2 >= 0) &&
                         (edge3 >= 0))
                        ||
                        ((edge0 <= 0) &&
                         (edge1 <= 0) &&
                         (edge2 <= 0) &&
                         (edge3 <= 0))
                    ) begin

                        color_index = poligono_cor[j];

                    end

                end
				  end
            end

        end
    end

endmodule