module frame_buffer (

    input wire        write_clk, // Clock da GPU (100 MHz)
    input wire        read_clk,  // Clock do VGA (25 MHz)

    // Porta de escrita
    input wire        write_enable,
    input wire [16:0] write_address,
    input wire [7:0]  write_data,

    // Porta de leitura
    input wire [16:0] read_address,
    output reg  [7:0] read_data

);

    // Memória: 320 × 240 bytes (pixels)
    reg [7:0] memoria [0:76799];

    always @(posedge write_clk) begin
        if (write_enable) begin
             memoria[write_address] <= write_data;
        end 
    end
        
    always @(posedge read_clk) begin
         read_data <= memoria[read_address];
    end
        
endmodule