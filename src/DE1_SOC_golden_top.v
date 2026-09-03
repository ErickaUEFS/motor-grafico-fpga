// ============================================================================
// Copyright (c) 2013 by Terasic Technologies Inc.
// ============================================================================
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// ============================================================================
//           
//  Terasic Technologies Inc
//  9F., No.176, Sec.2, Gongdao 5th Rd, East Dist, Hsinchu City, 30070. Taiwan
//  
//  
//                     web: http://www.terasic.com/  
//                     email: support@terasic.com
//
// ============================================================================
//Date:  Thu Jul 11 11:26:45 2013
// ============================================================================

`define ENABLE_ADC
`define ENABLE_AUD
`define ENABLE_CLOCK2
`define ENABLE_CLOCK3
`define ENABLE_CLOCK4
`define ENABLE_CLOCK
`define ENABLE_DRAM
`define ENABLE_FAN
`define ENABLE_FPGA
`define ENABLE_GPIO
`define ENABLE_HEX
//`define ENABLE_HPS
`define ENABLE_IRDA
`define ENABLE_KEY
`define ENABLE_LEDR
`define ENABLE_PS2
`define ENABLE_SW
`define ENABLE_TD
`define ENABLE_VGA

module DE1_SOC_golden_top(

      /* Enables ADC - 3.3V */
	`ifdef ENABLE_ADC

      output             ADC_CONVST,
      output             ADC_DIN,
      input              ADC_DOUT,
      output             ADC_SCLK,

	`endif

       /* Enables AUD - 3.3V */
	`ifdef ENABLE_AUD

      input              AUD_ADCDAT,
      inout              AUD_ADCLRCK,
      inout              AUD_BCLK,
      output             AUD_DACDAT,
      inout              AUD_DACLRCK,
      output             AUD_XCK,

	`endif

      /* Enables CLOCK2  */
	`ifdef ENABLE_CLOCK2
      input              CLOCK2_50,
	`endif

      /* Enables CLOCK3 */
	`ifdef ENABLE_CLOCK3
      input              CLOCK3_50,
	`endif

      /* Enables CLOCK4 */
	`ifdef ENABLE_CLOCK4
      input              CLOCK4_50,
	`endif

      /* Enables CLOCK */
	`ifdef ENABLE_CLOCK
      input              CLOCK_50,
	`endif

       /* Enables DRAM - 3.3V */
	`ifdef ENABLE_DRAM
      output      [12:0] DRAM_ADDR,
      output      [1:0]  DRAM_BA,
      output             DRAM_CAS_N,
      output             DRAM_CKE,
      output             DRAM_CLK,
      output             DRAM_CS_N,
      inout       [15:0] DRAM_DQ,
      output             DRAM_LDQM,
      output             DRAM_RAS_N,
      output             DRAM_UDQM,
      output             DRAM_WE_N,
	`endif

      /* Enables FAN - 3.3V */
	`ifdef ENABLE_FAN
      output             FAN_CTRL,
	`endif

      /* Enables FPGA - 3.3V */
	`ifdef ENABLE_FPGA
      output             FPGA_I2C_SCLK,
      inout              FPGA_I2C_SDAT,
	`endif

      /* Enables GPIO - 3.3V */
	`ifdef ENABLE_GPIO
      inout     [35:0]         GPIO_0,
      inout     [35:0]         GPIO_1,
	`endif
 

      /* Enables HEX - 3.3V */
	`ifdef ENABLE_HEX
      output      [6:0]  HEX0,
      output      [6:0]  HEX1,
      output      [6:0]  HEX2,
      output      [6:0]  HEX3,
      output      [6:0]  HEX4,
      output      [6:0]  HEX5,
	`endif
	
	/* Enables HPS */
	`ifdef ENABLE_HPS
      inout              HPS_CONV_USB_N,
      output      [14:0] HPS_DDR3_ADDR,
      output      [2:0]  HPS_DDR3_BA,
      output             HPS_DDR3_CAS_N,
      output             HPS_DDR3_CKE,
      output             HPS_DDR3_CK_N, //1.5V
      output             HPS_DDR3_CK_P, //1.5V
      output             HPS_DDR3_CS_N,
      output      [3:0]  HPS_DDR3_DM,
      inout       [31:0] HPS_DDR3_DQ,
      inout       [3:0]  HPS_DDR3_DQS_N,
      inout       [3:0]  HPS_DDR3_DQS_P,
      output             HPS_DDR3_ODT,
      output             HPS_DDR3_RAS_N,
      output             HPS_DDR3_RESET_N,
      input              HPS_DDR3_RZQ,
      output             HPS_DDR3_WE_N,
      output             HPS_ENET_GTX_CLK,
      inout              HPS_ENET_INT_N,
      output             HPS_ENET_MDC,
      inout              HPS_ENET_MDIO,
      input              HPS_ENET_RX_CLK,
      input       [3:0]  HPS_ENET_RX_DATA,
      input              HPS_ENET_RX_DV,
      output      [3:0]  HPS_ENET_TX_DATA,
      output             HPS_ENET_TX_EN,
      inout       [3:0]  HPS_FLASH_DATA,
      output             HPS_FLASH_DCLK,
      output             HPS_FLASH_NCSO,
      inout              HPS_GSENSOR_INT,
      inout              HPS_I2C1_SCLK,
      inout              HPS_I2C1_SDAT,
      inout              HPS_I2C2_SCLK,
      inout              HPS_I2C2_SDAT,
      inout              HPS_I2C_CONTROL,
      inout              HPS_KEY,
      inout              HPS_LED,
      inout              HPS_LTC_GPIO,
      output             HPS_SD_CLK,
      inout              HPS_SD_CMD,
      inout       [3:0]  HPS_SD_DATA,
      output             HPS_SPIM_CLK,
      input              HPS_SPIM_MISO,
      output             HPS_SPIM_MOSI,
      inout              HPS_SPIM_SS,
      input              HPS_UART_RX,
      output             HPS_UART_TX,
      input              HPS_USB_CLKOUT,
      inout       [7:0]  HPS_USB_DATA,
      input              HPS_USB_DIR,
      input              HPS_USB_NXT,
      output             HPS_USB_STP,
`endif 

      /* Enables IRDA - 3.3V */
	`ifdef ENABLE_IRDA
      input              IRDA_RXD,
      output             IRDA_TXD,
	`endif

      /* Enables KEY - 3.3V */
	`ifdef ENABLE_KEY
      input       [3:0]  KEY,
	`endif

      /* Enables LEDR - 3.3V */
	`ifdef ENABLE_LEDR
      output      [9:0]  LEDR,
	`endif

      /* Enables PS2 - 3.3V */
	`ifdef ENABLE_PS2
      inout              PS2_CLK,
      inout              PS2_CLK2,
      inout              PS2_DAT,
      inout              PS2_DAT2,
	`endif

      /* Enables SW - 3.3V */
	`ifdef ENABLE_SW
      input       [9:0]  SW,
	`endif

      /* Enables TD - 3.3V */
	`ifdef ENABLE_TD
      input             TD_CLK27,
      input      [7:0]  TD_DATA,
      input             TD_HS,
      output            TD_RESET_N,
      input             TD_VS,
	`endif

      /* Enables VGA - 3.3V */
	`ifdef ENABLE_VGA
      output      [7:0]  VGA_B,
      output             VGA_BLANK_N,
      output             VGA_CLK,
      output      [7:0]  VGA_G,
      output             VGA_HS,
      output      [7:0]  VGA_R,
      output             VGA_SYNC_N,
      output             VGA_VS
	`endif
);


//=======================================================
//  REG/WIRE declarations
//=======================================================

reg clknovo_100;
reg lckd;

clknew (
		.refclk(CLOCK_50),   //  refclk.clk
		.rst(0),      //   reset.reset
		.outclk_0(clknovo_100), // outclk0.clk
		.locked(lckd)    //  locked.export
	);

reg clocknovo;

wire [9:0]SW_estavel; 
	 
Debounce_SW (

    .clk(clocknovo),
    .SW(SW),

    .SW_estavel(SW_estavel)

);	 




wire [9:0] next_x, next_y;

wire [7:0]corpaleta;

always@(posedge CLOCK2_50) begin
    clocknovo <= ~clocknovo;
    
    end
    




// Calculos da GPU

reg [9:0] gpu_x = 0;
reg [9:0] gpu_y = 0;
reg desenhando_quadro = 1; // Flag para saber se a GPU está trabalhando

reg vsync_anterior = 1;
reg swap_request = 0;
reg buffer_exibicao = 0;
wire vsync_borda = (vsync_anterior == 1'b1) && (VGA_VS == 1'b0);

always @(posedge CLOCK_50) begin

    vsync_anterior <= VGA_VS;

    if (desenhando_quadro) begin
        // GPU varrendo a tela 320x240
        if (gpu_x < 10'd319) begin
            gpu_x <= gpu_x + 10'd1;
        end else begin
            gpu_x <= 10'd0;
            if (gpu_y < 10'd239) begin
                gpu_y <= gpu_y + 10'd1;
            end else begin
           
                gpu_y <= 10'd0;
                desenhando_quadro <= 1'b0;
                swap_request <= 1'b1;
            end
        end
    end

    // Gerencia a troca de buffer no VSYNC
    if (vsync_borda && swap_request) begin
        buffer_exibicao <= ~buffer_exibicao; // Troca a tela exibida
        swap_request <= 1'b0;                // Abaixa o pedido
        desenhando_quadro <= 1'b1;           // Acorda a GPU pro próximo quadro
    end
end

wire [9:0] render_x = gpu_x;
wire [9:0] render_y = gpu_y;

wire [7:0] pixel_color;

wire [7:0] poligono_color;
wire [7:0] sprite_color;
wire [7:0] back_color;


// saidas do controlador para o rasterizador
wire [2:0] indice_poligono;
wire       poligono_ativo;
wire       controle_poligono;
wire       mostrar_poligono;

// saidas do controlador para o motor de sprites
wire [4:0] indice_sprite;
wire       sprite_ativo;
wire       sprite_espelhado_H;
wire       sprite_espelhado_V;
wire       controle_sprite;
wire       mostrar_sprite;

// saidas do controlador para o background
wire [2:0] indice_background;
wire       mostrar_background;
wire       controle_back;
wire [4:0] tile_id_background;

wire mover;
wire [1:0] direcao;



Controle controle (

    .clk(clocknovo),
    .reset(0),

    .SW(SW_estavel),
    .KEY(KEY),

    // Controle do Rasterizador

    .indice_poligono(indice_poligono),
    .poligono_ativo(poligono_ativo),
    .controle_poligono(controle_poligono),
    .mostrar_poligono(mostrar_poligono),

    // Controle dos Sprites
    .indice_sprite(indice_sprite),
    .sprite_ativo(sprite_ativo),
    .sprite_espelhado_H(sprite_espelhado_H),
    .sprite_espelhado_V(sprite_espelhado_V),
    .controle_sprite(controle_sprite),
    .mostrar_sprite(mostrar_sprite),

    // Controle do Background
    .indice_background(indice_background),
	 .tile_id_background(tile_id_background), 
    .mostrar_background(mostrar_background),
	 .controle_back(controle_back),
   
    // Movimento
    .mover(mover),
    .direcao(direcao)

);


Motor_sprite sprite (

    .clk(CLOCK_50),

    .next_x(render_x),
    .next_y(render_y),

    .controle_ativo(controle_sprite),

    .indice(indice_sprite),

    .visibilidade(sprite_ativo),

    .espelhamento_H(sprite_espelhado_H),

    .espelhamento_V(sprite_espelhado_V),

	 .mover(mover),
	 .direcao(direcao),

    .cor(sprite_color)

);

Motor_Background background (

    .clk(clknovo_100),

    .next_x(render_x),
    .next_y(render_y),

    .controle_ativo(controle_back),

    .indice(indice_background),

    .tile_id_input(tile_id_background),

    .mover(mover),
    .direcao(direcao),

    .indice_cor(back_color)

);



Motor_Rasterizador rasterizador (

    .clk(CLOCK_50),

    .next_x(render_x),
    .next_y(render_y),

    .controle_ativo(controle_poligono),

    .indice(indice_poligono),
	 .visibilidade(poligono_ativo),
		
    .mover(mover),
    .direcao(direcao),

    .color_index(corpaleta)

);

paleta(

 .clk(CLOCK_50),

 .programar(0),
 .endereco(corpaleta),
 .codigo_cor(0),
 
 .cor(poligono_color)



);


// fio pra levar pro compositor 
wire [7:0] compositor_color; 

Compositor(

    .corPoligono(poligono_color),
    .corSprite(sprite_color),
    .corBack(back_color),

    .mostrarPoligono(mostrar_poligono),
    .mostrarSprite(mostrar_sprite),
    .mostrarBack(mostrar_background),

    .pixel_color(compositor_color)

);

// Double Buffer

// Calculamos o endereço.
wire [16:0] write_addr_calc;
assign write_addr_calc = (gpu_y * 17'd320) + gpu_x;

// Atraso de 1 clock.
reg [16:0] write_addr_pipe1 = 0;
reg we_pipe1 = 0;

always @(posedge CLOCK_50) begin
    // 1 único estágio de atraso.
    write_addr_pipe1 <= write_addr_calc;
    we_pipe1         <= desenhando_quadro;
end

// Endereço de leitura (Do VGA a 25MHz).
wire [16:0] read_addr;
wire [8:0] fb_x = next_x >> 1; 
wire [7:0] fb_y = next_y >> 1; 
assign read_addr = (fb_y * 17'd320) + fb_x;

// Sinais de controle de escrita.
wire fb0_write_enable = (buffer_exibicao == 1'b1) && we_pipe1;
wire fb1_write_enable = (buffer_exibicao == 1'b0) && we_pipe1;

wire [7:0] fb0_read_data;
wire [7:0] fb1_read_data;

frame_buffer frame_buffer_0 (
    .write_clk(CLOCK_50), 
    .read_clk(clocknovo),    
    
    .write_enable(fb0_write_enable),
    .write_address(write_addr_pipe1), // <-- Atraso de 1 clock
    .write_data(compositor_color),
    
    .read_address(read_addr),
    .read_data(fb0_read_data)
);

frame_buffer frame_buffer_1 (
    .write_clk(CLOCK_50), 
    .read_clk(clocknovo),    
    
    .write_enable(fb1_write_enable),
    .write_address(write_addr_pipe1), // <-- Atraso de 1 clock
    .write_data(compositor_color),
    
    .read_address(read_addr),
    .read_data(fb1_read_data)
);

wire [7:0] framebuffer_color;
assign framebuffer_color = (buffer_exibicao == 1'b0) ? fb0_read_data : fb1_read_data;

// Instantiate VGA driver                   
vga_driver draw   ( .clock(clocknovo),        // 25 MHz PLL
                    .reset(0),      // Active high reset, manipulated by instantiating module
                    .color_in(framebuffer_color), // Pixel color (RRRGGGBB) for pixel being drawn
                    .next_x(next_x),        // X-coordinate (range [0, 639]) of next pixel to be drawn
                    .next_y(next_y),        // Y-coordinate (range [0, 479]) of next pixel to be drawn
                    .hsync(VGA_HS),         // All of the connections to the VGA screen below
                    .vsync(VGA_VS),
                    .red(VGA_R),
                    .green(VGA_G),
                    .blue(VGA_B),
                    .sync(VGA_SYNC_N),
                    .clk(VGA_CLK),
                    .blank(VGA_BLANK_N)
);

//=======================================================
//  Structural coding
//=======================================================





endmodule
