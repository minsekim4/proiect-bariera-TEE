module sistem_parcare #(parameter NR_TACTE_SENZOR = 8'd20)(
    input                clk_i,
    input                reset_ni,
    input      [1:0]     paddr,
    input                psel,
    input                penable,
    input                pwrite,
    input      [7:0]     pwdata,
    output reg [7:0]     prdata,
    output               pready,

    input      [1:0]     btn_i,
    input                senzor_proxim,
    output reg           stare_bariera
);

assign pready = 1'b1;

reg  [2:0]   stare_curenta;
reg  [3:0]   nr_locuri_libere;
wire [7:0]   x_tacte_ceas = NR_TACTE_SENZOR;
reg  [7:0]   counter;
reg          intrare_iesire; // 1 == intrare, 0 == iesire

localparam IDLE        = 3'b000;
localparam RIDICARE    = 3'b001;
localparam ASTEAPTA    = 3'b010;
localparam COBORARE    = 3'b011;
localparam UPDATE      = 3'b100;

always @(posedge clk_i or negedge reset_ni) begin
  if(~reset_ni)
      stare_curenta <= IDLE;
  else begin
      case (stare_curenta)
          IDLE:
              if((btn_i == 2'b01 && nr_locuri_libere > 0) || (btn_i == 2'b10 && nr_locuri_libere < 15))
                  stare_curenta <= RIDICARE;
          
          RIDICARE:
              stare_curenta <= ASTEAPTA;

          ASTEAPTA:
              if(counter >= x_tacte_ceas && ~senzor_proxim)
                  stare_curenta <= COBORARE;
          
          COBORARE:
              stare_curenta <= UPDATE;

          UPDATE:
              stare_curenta <= IDLE;

          default: stare_curenta <= IDLE;
      endcase
      end
end

always @(posedge clk_i or negedge reset_ni) begin
  if(~reset_ni)
    stare_bariera <= 0;
  else if (stare_curenta == RIDICARE || stare_curenta == ASTEAPTA) 
           stare_bariera <= 1;
       else if (stare_curenta == COBORARE) 
                stare_bariera <= 0;
end

always @(posedge clk_i or negedge reset_ni) begin
  if(~reset_ni)
    counter <= 0;
  else if (stare_curenta == ASTEAPTA)
    counter <= counter + 1;
  else counter <= 0;
end

always @(posedge clk_i or negedge reset_ni) begin
  if(~reset_ni)
      nr_locuri_libere <= 4'd10;
  else begin
      if (psel && penable && pwrite && (paddr == 2'b01))
          nr_locuri_libere <= pwdata[3:0];
      else if (stare_curenta == UPDATE) begin
          if (intrare_iesire)
              nr_locuri_libere <= nr_locuri_libere - 1'b1;
          else 
              nr_locuri_libere <= nr_locuri_libere + 1'b1;
      end
  end
end

always @(posedge clk_i or negedge reset_ni) begin
  if(~reset_ni)
    intrare_iesire <= 0;
  else if (stare_curenta == IDLE)
          if (btn_i == 2'b01) 
             intrare_iesire <= 1;
          else if (btn_i == 2'b10)
                  intrare_iesire <= 0;
end

always @(posedge clk_i or negedge reset_ni) begin
  if (~reset_ni) 
      prdata <= 8'd0;
  else if (psel && !pwrite) begin
      case (paddr)
          2'b00: prdata <= {6'b0, btn_i};          
          2'b01: prdata <= {4'b0, nr_locuri_libere};       
          2'b10: prdata <= {6'b0, stare_bariera, senzor_proxim}; 
          2'b11: prdata <= x_tacte_ceas;              
      endcase
  end
end

endmodule