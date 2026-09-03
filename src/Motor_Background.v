module Motor_Background (

    input wire        clk,

    input wire [9:0]  next_x,
    input wire [9:0]  next_y,

    // Interface de controle

    input wire        controle_ativo,

    input wire [2:0]  indice,

    input wire [7:0]  tile_id_input,

    input wire        mover,

    input wire [1:0]  direcao,

    output wire [7:0] indice_cor

);

    // Direções

    localparam CIMA     = 2'b00;
    localparam BAIXO    = 2'b01;
    localparam ESQUERDA = 2'b10;
    localparam DIREITA  = 2'b11;

    // Resolução lógica
   
    wire [9:0] x_logico;
    wire [9:0] y_logico;

    assign x_logico = next_x;
    assign y_logico = next_y;

    // Deslocamento do Background

    reg signed [10:0] deslocamento_x;
    reg signed [10:0] deslocamento_y;

    // Contador de velocidade

    reg [21:0] contador;

    localparam LIMITE = 500_000 - 1;

    // Inicialização

    integer linha;
    integer coluna;
    integer misturador;

    initial begin

        deslocamento_x = 11'sd0;
        deslocamento_y = 11'sd0;
        contador = 22'd0;
		
		$readmemh("tilemap_40x30.hex", tilemap);
	
	
			
	end

    // Tilemap
    //
    // 40 x 30 = 1200 posições

    reg [7:0] tilemap [0:1199];

    // Alteração do tilemap

    always @(posedge clk) begin

        if (controle_ativo) begin

            tilemap[indice] <= tile_id_input;

        end

    end

    // Movimento

    always @(posedge clk) begin

        if (contador == LIMITE) begin

            contador <= 22'd0;


            if (controle_ativo && mover) begin

                case (direcao)

                    CIMA: begin
                        deslocamento_y <= deslocamento_y - 11'sd1;
                    end

                    BAIXO: begin
                        deslocamento_y <= deslocamento_y + 11'sd1;
                    end

                    ESQUERDA: begin
                        deslocamento_x <= deslocamento_x - 11'sd1;
                    end

                    DIREITA: begin
                        deslocamento_x <= deslocamento_x + 11'sd1;
                    end

                    default: begin
                    end

                endcase

            end

        end
        else begin
            contador <= contador + 22'd1;
        end

    end

    // Coordenada do mapa

    wire signed [10:0] mapa_x;
    wire signed [10:0] mapa_y;

    assign mapa_x = $signed({1'b0, x_logico}) + deslocamento_x;
    assign mapa_y = $signed({1'b0, y_logico}) + deslocamento_y;

    // Verifica se está dentro do mapa

    wire dentro_do_mapa;

    assign dentro_do_mapa =
        (mapa_x >= 0) && (mapa_x < 320) &&
        (mapa_y >= 0) && (mapa_y < 240);

    // Tile atual

    wire [6:0] tile_x;
    wire [6:0] tile_y;

    assign tile_x = mapa_x / 8;
    assign tile_y = mapa_y / 8;

    // Pixel dentro do tile

    wire [2:0] pixel_x;
    wire [2:0] pixel_y;

    assign pixel_x = mapa_x % 8;
    assign pixel_y = mapa_y % 8;

    // Endereço no Tilemap

    wire [10:0] endereco_tilemap;

    assign endereco_tilemap = tile_y * 40 + tile_x;

    // Tile armazenado na posição atual
    
    wire [7:0] tile_id; 

    assign tile_id =
        dentro_do_mapa ?
        tilemap[endereco_tilemap] :
        8'b00000000;

    // Endereço do pixel dentro do tile

    wire [5:0] endereco_pixel;

    assign endereco_pixel = pixel_y * 8 + pixel_x;

    // Endereço da ROM

    wire [13:0] endereco_rom; 


    assign endereco_rom =
        tile_id * 64 + endereco_pixel;

    // ROM dos tiles

    wire [7:0] dado_rom;

    tiles256 memoria_tiles (
        .address(endereco_rom),
        .clock(clk),
        .q(dado_rom)
    );


    // Saída

    assign indice_cor =
        dentro_do_mapa ?
        dado_rom :
        8'h00;

endmodule