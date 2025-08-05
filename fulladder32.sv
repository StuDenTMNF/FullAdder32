// Файл: full_adder_32bit.sv

// --- Базовые гейты ---
module Andd(input logic A, B, output logic C);
  assign C = A & B;
endmodule

module Orr(input logic A, B, output logic C);
  assign C = A | B;
endmodule

module Xorr(input logic A, B, output logic C);
  assign C = A ^ B;
endmodule

// --- Однобитный полный сумматор ---
module fulladder(
  input  logic a_i, b_i, carry_i,
  output logic sum_o, carry_o
);
  logic q1;
  // Более эффективная реализация
  assign q1 = a_i ^ b_i;
  assign sum_o = q1 ^ carry_i;
  assign carry_o = (a_i & b_i) | (q1 & carry_i);
endmodule

// --- 4-битный полный сумматор ---
module fulladder4(
  input  logic [3:0] a_i, b_i,
  input  logic       carry_i,
  output logic [3:0] sum_o,
  output logic       carry_o
);
  // Объявляем провода для переносов между битами!
 logic c1,c2,c3;  // <--- ВОТ КАК НАДО БЫЛО, BAKA!

  fulladder fa1 (.a_i(a_i[0]), .b_i(b_i[0]), .carry_i(carry_i), .sum_o(sum_o[0]), .carry_o(c1));
  fulladder fa2 (.a_i(a_i[1]), .b_i(b_i[1]), .carry_i(c1),      .sum_o(sum_o[1]), .carry_o(c2));
  fulladder fa3 (.a_i(a_i[2]), .b_i(b_i[2]), .carry_i(c2),      .sum_o(sum_o[2]), .carry_o(c3));
  fulladder fa4 (.a_i(a_i[3]), .b_i(b_i[3]), .carry_i(c3),      .sum_o(sum_o[3]), .carry_o(carry_o));
endmodule

// --- 32-битный полный сумматор (Твой модуль для теста) ---
module fulladder32(
  input  logic [31:0] a_i, b_i,
  input  logic        carry_i,
  output logic [31:0] sum_o,
  output logic        carry_o
);
  logic [6:0] c;
  fulladder4 f1 (.a_i(a_i[3:0]),   .b_i(b_i[3:0]),   .carry_i(carry_i), .sum_o(sum_o[3:0]),   .carry_o(c[0]));
  fulladder4 f2 (.a_i(a_i[7:4]),   .b_i(b_i[7:4]),   .carry_i(c[0]),    .sum_o(sum_o[7:4]),   .carry_o(c[1]));
  fulladder4 f3 (.a_i(a_i[11:8]),  .b_i(b_i[11:8]),  .carry_i(c[1]),    .sum_o(sum_o[11:8]),  .carry_o(c[2]));
  fulladder4 f4 (.a_i(a_i[15:12]), .b_i(b_i[15:12]), .carry_i(c[2]),    .sum_o(sum_o[15:12]), .carry_o(c[3]));
  fulladder4 f5 (.a_i(a_i[19:16]), .b_i(b_i[19:16]), .carry_i(c[3]),    .sum_o(sum_o[19:16]), .carry_o(c[4]));
  fulladder4 f6 (.a_i(a_i[23:20]), .b_i(b_i[23:20]), .carry_i(c[4]),    .sum_o(sum_o[23:20]), .carry_o(c[5]));
  fulladder4 f7 (.a_i(a_i[27:24]), .b_i(b_i[27:24]), .carry_i(c[5]),    .sum_o(sum_o[27:24]), .carry_o(c[6]));
  fulladder4 f8 (.a_i(a_i[31:28]), .b_i(b_i[31:28]), .carry_i(c[6]),    .sum_o(sum_o[31:28]), .carry_o(carry_o));
endmodule