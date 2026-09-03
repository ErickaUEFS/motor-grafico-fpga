module Compositor (

	input wire [7:0]corPoligono,
	input wire [7:0]corSprite,
	input wire [7:0]corBack,

	
    input wire mostrarPoligono,
    input wire mostrarSprite,
    input wire mostrarBack,
	
	
	output reg [7:0]pixel_color
	
);


	always @(*) begin

		 pixel_color = 8'd0;

		 if (mostrarBack && corBack != 8'd0)
			  pixel_color = corBack;

		 if (mostrarSprite && corSprite != 8'd0)
			  pixel_color = corSprite;

		 if (mostrarPoligono && corPoligono != 8'd0)
			  pixel_color = corPoligono;

	end
	
endmodule