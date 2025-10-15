`timescale 1ns / 1ps

module embedded_fnd(
    input  [3:0] a_com, b_com, c_com,   // COM�� 4��Ʈ
    input  [7:0] a_data, b_data, c_data,// DATA�� 8��Ʈ
    input  [1:0] sel,                   // ���� ��ȣ 2��Ʈ
    
    output reg [7:0] fnd_data,
    output reg [3:0] fnd_com
    );
    
    always @(*) begin
        case (sel)
            2'b01: begin
                fnd_data = a_data;
                fnd_com  = a_com;
            end
            2'b10: begin
                fnd_data = b_data;
                fnd_com  = b_com;
            end
            2'b11: begin
                fnd_data = c_data;
                fnd_com  = c_com;
            end
            default: begin
                fnd_data = 8'b0;
                fnd_com  = 4'b1111; // �⺻�� (����)
            end
        endcase
    end
    
endmodule
