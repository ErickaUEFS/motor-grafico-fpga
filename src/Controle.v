module Controle (

    input wire        clk,
    input wire        reset,

    input wire [9:0]  SW,
    input wire [3:0]  KEY,

    // Controle do Rasterizador
  
    output reg [2:0] indice_poligono,
    output reg       poligono_ativo,
    output reg       controle_poligono,
    output reg       mostrar_poligono,

    // Controle dos Sprites

    output reg [4:0] indice_sprite,
    output reg       sprite_ativo,
    output reg       sprite_espelhado_H,
    output reg       sprite_espelhado_V,
    output reg       controle_sprite,
    output reg       mostrar_sprite,

    // Controle do Background

    output reg [2:0] indice_background,
    output reg [4:0] tile_id_background,
    output reg       mostrar_background,
    output reg       controle_back,

    // Controle de movimento

    output reg       mover,
    output reg [1:0] direcao

);

    // Estados da FSM

    localparam ESTADO_NORMAL  = 2'b00;
    localparam ESTADO_MOVENDO = 2'b01;

    reg [1:0] estado;

    // Modos

    localparam MODO_POLIGONO   = 2'b00;
    localparam MODO_SPRITE     = 2'b01;
    localparam MODO_BACKGROUND = 2'b10;
    localparam MODO_TODOS      = 2'b11;

    // Tipos

    localparam TIPO_POLIGONO   = 2'b00;
    localparam TIPO_SPRITE     = 2'b01;
    localparam TIPO_BACKGROUND = 2'b10;
	 localparam TIPO_TODOS = 2'b11;

    // Direções

    localparam CIMA     = 2'b00;
    localparam BAIXO    = 2'b01;
    localparam ESQUERDA = 2'b10;
    localparam DIREITA  = 2'b11;

    // Switches
    //
    // SW9:8 -> modo
    //
    // SW7:3 -> tile do Background
    //
    // SW2:0 -> índice do Background

    wire [1:0] modo = SW[9:8];

    wire [2:0] indice_3bits = SW[2:0];

    wire [4:0] tile_5bits = SW[7:3];

    // Controle do Sprite
    //
    // Para o sprite:
    //
    // SW5:3 -> índice
    // SW2   -> visibilidade
    // SW1   -> espelhamento horizontal
    // SW0   -> espelhamento vertical
    //
    // SW7:6 ficam disponíveis para seleção do tipo no MODO_TODOS.

    wire [4:0] indice_sprite_SW = SW[7:3];

    wire visibilidade = SW[2];

    wire espelho_H = SW[1];

    wire espelho_V = SW[0];

    // Tipo selecionado no MODO_TODOS
    //
    // Aqui SW7:6 escolhem:
    //
    // 00 -> Polígono
    // 01 -> Sprite
    // 10 -> Background

    wire [1:0] tipo = SW[7:6];

    reg [1:0] tipo_selecionado;


    always @(*) begin

        case (modo)

            MODO_POLIGONO:

                tipo_selecionado = TIPO_POLIGONO;


            MODO_SPRITE:

                tipo_selecionado = TIPO_SPRITE;


            MODO_BACKGROUND:

                tipo_selecionado = TIPO_BACKGROUND;


            MODO_TODOS:

                tipo_selecionado = tipo;


            default:

                tipo_selecionado = TIPO_POLIGONO;

        endcase

    end

    // Máquina de estados do movimento
    
    always @(posedge clk) begin

        if (reset) begin

            estado <= ESTADO_NORMAL;

        end

        else begin

            case (estado)

				// Estado normal

                ESTADO_NORMAL: begin

                    if (!KEY[3] ||
                        !KEY[2] ||
                        !KEY[1] ||
                        !KEY[0]) begin

                        estado <= ESTADO_MOVENDO;

                    end

                end

                // Estado movendo

                ESTADO_MOVENDO: begin

                    if (KEY[3] &&
                        KEY[2] &&
                        KEY[1] &&
                        KEY[0]) begin

                        estado <= ESTADO_NORMAL;

                    end

                end


                default: begin

                    estado <= ESTADO_NORMAL;

                end

            endcase

        end

    end

    // Saídas combinacionais

    always @(*) begin

        // Valores padrão
        
        controle_poligono = 1'b0;
        controle_sprite   = 1'b0;
        controle_back     = 1'b0;

        mostrar_poligono   = 1'b0;
        mostrar_sprite     = 1'b0;
        mostrar_background = 1'b0;


        indice_poligono = 3'b000;
        poligono_ativo  = 1'b0;


        indice_sprite = 5'b00000;
        sprite_ativo  = 1'b0;

        sprite_espelhado_H = 1'b0;
        sprite_espelhado_V = 1'b0;


        indice_background  = 3'b000;
        tile_id_background = 5'b00000;


        mover   = 1'b0;
        direcao = CIMA;

        // Seleção do modo

        case (modo)

            // POLÍGONO

            MODO_POLIGONO: begin

                controle_poligono = 1'b1;

                mostrar_poligono = 1'b1;

            end

            // SPRITE
            
            MODO_SPRITE: begin

                controle_sprite = 1'b1;

                mostrar_sprite = 1'b1;

            end

            // BACKGROUND
        
            MODO_BACKGROUND: begin

                controle_back = 1'b1;

                mostrar_background = 1'b1;

            end

            // TODOS

            MODO_TODOS: begin

                mostrar_poligono   = 1'b1;
                mostrar_sprite     = 1'b1;
                mostrar_background = 1'b1;


                case (tipo)

                    TIPO_POLIGONO:

                        controle_poligono = 1'b1;


                    TIPO_SPRITE:

                        controle_sprite = 1'b1;


                    TIPO_BACKGROUND:

                        controle_back = 1'b1;

								
                    TIPO_TODOS: begin
									
								controle_poligono = 1'b1;
								controle_sprite   = 1'b1;
								controle_back     = 1'b1;
								
							  end
                    default:
                        begin
                        end

                endcase

            end


            default:
                begin
                end

        endcase

        // POLÍGONO

        if (tipo_selecionado == TIPO_POLIGONO) begin

            indice_poligono = SW[5:3];

            poligono_ativo = visibilidade;

        end

        // SPRITE
     
        else if (tipo_selecionado == TIPO_SPRITE) begin

            indice_sprite = indice_sprite_SW;

            sprite_ativo = visibilidade;

            sprite_espelhado_H = espelho_H;

            sprite_espelhado_V = espelho_V;

        end

        // BACKGROUND

        else if (tipo_selecionado == TIPO_BACKGROUND) begin

            // SW2:0 = posição no tilemap
            indice_background = SW[2:0];

            // SW7:3 = tile que será colocado
            tile_id_background = SW[7:3];

        end

        // MOVIMENTO

        if (estado == ESTADO_MOVENDO) begin

            if (!KEY[3]) begin

                mover = 1'b1;

                direcao = CIMA;

            end

            else if (!KEY[2]) begin

                mover = 1'b1;

                direcao = BAIXO;

            end

            else if (!KEY[1]) begin

                mover = 1'b1;

                direcao = ESQUERDA;

            end

            else if (!KEY[0]) begin

                mover = 1'b1;

                direcao = DIREITA;

            end

        end

    end

endmodule