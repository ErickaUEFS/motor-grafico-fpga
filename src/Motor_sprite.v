module Motor_sprite (

    input wire clk,

    input wire [9:0] next_x,
    input wire [9:0] next_y,

    // =========================================================
    // Interface de controle
    // =========================================================

    input wire       controle_ativo,

    input wire [4:0] indice,

    input wire       visibilidade,

    input wire       espelhamento_H,
    input wire       espelhamento_V,

    input wire       mover,
    input wire [1:0] direcao,

    output reg [7:0] cor

);


    // =========================================================
    // Conversão para resolução lógica
    // =========================================================

    wire [8:0] logico_x = next_x / 2;
    wire [8:0] logico_y = next_y / 2;


    // =========================================================
    // Direções
    // =========================================================

    localparam CIMA     = 2'b00;
    localparam BAIXO    = 2'b01;
    localparam ESQUERDA = 2'b10;
    localparam DIREITA  = 2'b11;


    // =========================================================
    // Informações dos sprites
    // =========================================================

    reg [8:0] sprite_x [0:31];
    reg [8:0] sprite_y [0:31];

    reg       sprite_ativo [0:31];

    reg [4:0] sprite_img [0:31];

    reg       sprite_espelhado_H [0:31];
    reg       sprite_espelhado_V [0:31];


    // =========================================================
    // Inicialização
    // =========================================================

integer i;

    initial begin
        
        for (i = 0; i < 32; i = i + 1) begin
            

				 // Ativa os primeiros 32 sprites
				 sprite_ativo[i] = 1;         
				 
				 // Atribui uma imagem diferente (0 a 31) para cada um
				 sprite_img[i] = i;           
				 
				 // Espalha na tela em uma grade (6 colunas, espaçamento 16px)
				 // Ex: Sprite 0 = (20,20) | Sprite 1 = (52,20) | Sprite 6 = (20, 52)
				 sprite_x[i] = (i % 6) * 16 + 20; 
				 sprite_y[i] = (i / 6) * 16 + 20; 

            // Nenhum espelhado por padrão
            sprite_espelhado_H[i] = 0;
            sprite_espelhado_V[i] = 0;

        end

    end

    // =========================================================
    // Atualização da configuração do sprite selecionado
    // =========================================================

    always @(posedge clk) begin

        if (controle_ativo) begin

            sprite_ativo[indice] <= visibilidade;

            sprite_espelhado_H[indice] <= espelhamento_H;

            sprite_espelhado_V[indice] <= espelhamento_V;

        end

    end


    // =========================================================
    // Controle da velocidade
    // =========================================================

    reg [21:0] contador;

    localparam LIMITE = 500_000 - 1;


    // =========================================================
    // Movimento
    // =========================================================

    always @(posedge clk) begin

        if (contador == LIMITE) begin

            contador <= 0;

            if (controle_ativo && mover) begin

							case (direcao)

                    CIMA:
                        // Checa apenas se é maior que 0 para não dar underflow
                        if (sprite_y[indice] > 0) begin
                            sprite_y[indice] <= sprite_y[indice] - 1;
                        end
                            
                    BAIXO:
                        // Limite é 120 (tela) - 16 (tamanho do sprite) = 224
                        if (sprite_y[indice] < 104) begin
                            sprite_y[indice] <= sprite_y[indice] + 1;
                        end
                            
                    ESQUERDA:
                        // Checa apenas se é maior que 0
                        if (sprite_x[indice] > 0) begin
                            sprite_x[indice] <= sprite_x[indice] - 1;
                        end
                            
                    DIREITA:
                        // Limite é 160 (tela) - 16 (tamanho do sprite) = 304
                        // (Também corrigi para sprite_x aqui)
                        if (sprite_x[indice] < 144) begin
                            sprite_x[indice] <= sprite_x[indice] + 1;
                        end
                            
                    default:
                        begin
                        end

                endcase

            end

        end

        else begin

            contador <= contador + 1;

			end
		end

    // =========================================================
    // ROM dos sprites
    // =========================================================

    reg [14:0] endereco;

    wire [7:0] cor_rom;


    sprites32 rom (

        .address(endereco),
        .clock(clk),
        .q(cor_rom)

    );


    // =========================================================
    // Coordenada dentro do sprite
    // =========================================================

    reg [8:0] pixel_x;
    reg [8:0] pixel_y;

    integer j;


    // =========================================================
    // Renderização
    // =========================================================

    always @(*) begin

        endereco = 15'd0;

        cor = 8'd0;

        pixel_x = 9'd0;
        pixel_y = 9'd0;


        // -----------------------------------------------------
        // Percorre os sprites
        // -----------------------------------------------------

        for (j = 0; j < 32; j = j + 1) begin

            if (sprite_ativo[j] &&

                (logico_x >= sprite_x[j]) &&
                (logico_x < sprite_x[j] + 16) &&

                (logico_y >= sprite_y[j]) &&
                (logico_y < sprite_y[j] + 16)) begin


                // ---------------------------------------------
                // Coordenada do pixel dentro do sprite
                // ---------------------------------------------

                pixel_x = logico_x - sprite_x[j];
                pixel_y = logico_y - sprite_y[j];


                // ---------------------------------------------
                // Espelhamento horizontal
                // ---------------------------------------------

                if (sprite_espelhado_H[j])
                    pixel_x = 15 - pixel_x;


                // ---------------------------------------------
                // Espelhamento vertical
                // ---------------------------------------------

                if (sprite_espelhado_V[j])
                    pixel_y = 15 - pixel_y;


                // ---------------------------------------------
                // Endereço da ROM
                // ---------------------------------------------

                endereco =
                    (sprite_img[j] * 256) +
                    (pixel_y * 16) +
                    pixel_x;


                // ---------------------------------------------
                // Transparência
                // ---------------------------------------------

                if (cor_rom != 8'h00)
                    cor = cor_rom;

            end

        end

    end

endmodule