module paleta (

 input clk,

 input programar,
 input [7:0]endereco,
 input [23:0]codigo_cor,
 
 output [7:0]cor

);


reg [7:0] paleta_memoria [0:255];


initial begin
    paleta_memoria[0] = 8'b00000000; // transparente
    paleta_memoria[1] = 8'b11111111; // branco
    paleta_memoria[2] = 8'b11100000; // vermelho
    paleta_memoria[3] = 8'b00011100; // verde
    paleta_memoria[4] = 8'b00000011; // azul
	 paleta_memoria[5] = 8'b11111100; // amarelo
end


assign cor = paleta_memoria[endereco];

always@(posedge clk) begin
		if (programar) begin
			paleta_memoria[endereco] <= codigo_cor;
		end
end

endmodule