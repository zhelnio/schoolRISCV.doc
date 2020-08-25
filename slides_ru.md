---
marp: true
---

<style>
img[alt~="center"] {
  display: block;
  margin: 0 auto;
}
</style>

# SchoolRISCV

https://github.com/zhelnio/schoolRISCV

Stanislav Zhelnio, 2020

---

<!-- paginate: true -->

## Благодарности

- David Harris & Sarah Harris
- Юрий Панчул
- Александр Романов
- IVA Technologies

---

## Что такое schoolRISCV

- простое процессорное ядро для практического преподавания школьникам основ цифровой схемотехники
- написано на языке Verilog
- реализует подмножество архитектуры RISCV
- вырос из аналогичного проекта schoolMIPS

---

## Микроархитектура

![bg right 45%](img/ma.png)

- аппаратная реализация архитектуры в виде схемы

- возможны разные реализации одной архитектуры:
    - однотактная
    - многотактная
    - конвейерная

---

## Особенности schoolRISCV

- однотактная реализация
- нет памяти данных
- словная адресация памяти команд
- 9 инструкций: **add**, **or**, **srl**, **sltu**, **sub**, **addi**, **lui**, **beq**, **bne**

...и этого уже достаточно, чтобы посчитать квадратный корень!

---

## Последовательность проектирования

- тракт данных
  Data Path

- устройство управления
  Control Unit

---

## Спецификация RISC-V

![h:500 center](img/riscv_spec.png)

https://riscv.org/specifications/

---

## Наборы команд RISC-V: спецификация

![h:500 center](img/riscv_is.png)

---

## Архитектурное состояние: спецификация

![w:1080 center](img/riscv_pm.png)

---

## Архитектурное состояние

![h:600 center](png/cpu_00.png)

---

## ADDI: выборка инструкции

![h:600 center](png/cpu_01.png)

---

## ADDI: спецификация

![w:1080 center](img/riscv_addi.png)
![w:1080 center](img/riscv_immi.png)

---

## ADDI: считывание операнда из регистрового файла

![h:600 center](png/cpu_02.png)

---

## ADDI: декодирование константы из тела инструкции

![h:600 center](png/cpu_03.png)

---

## ADDI: вычисление результата арифметической операции

![h:600 center](png/cpu_04.png)

---

## ADDI: декодирование регистра назначения

![h:600 center](png/cpu_05.png)

---

## ADDI: запись результата в регистр назначения

![h:600 center](png/cpu_06.png)

---

## ADDI: вычисление адреса следующей инструкции

![h:600 center](png/cpu_07.png)

---

## ADDI: итоговая схема

![h:600 center](png/cpu_08.png)

---

## ADD: спецификация

![w:1080 center](img/riscv_add.png)

---

## ADD: выборка операнда rs1

![h:600 center](png/cpu_09.png)

---

## ADD: выборка операнда rs2

![h:600 center](png/cpu_10.png)

---

## ADD: передача второго операнда в АЛУ

![h:600 center](png/cpu_11.png)

---

## ADD: итоговая схема

![h:600 center](png/cpu_12.png)

---

## LUI: спецификация

![w:1080 center](img/riscv_lui.png)
...
![w:1080 center](img/riscv_immu.png)

---

## LUI: декодирование и передача константы

![h:600 center](png/cpu_13.png)

---

## BEQ: спецификация

![w:1080 center](img/riscv_bne.png)

---

## BEQ: вычисление адреса условного перехода

![h:600 center](png/cpu_14.png)

---

## BEQ: выбор адреса

![h:600 center](png/cpu_15.png)

---

## BEQ: определение необходимости перехода

![h:600 center](png/cpu_16.png)

---

## BEQ: итоговая схема

![h:600 center](png/cpu_17.png)

---

## BNE: BEQ наоборот

![h:600 center](png/cpu_18.png)

---

## BNE: новая цепь управления

![h:600 center](png/cpu_19.png)

---

## Устройство управления

![h:600 center](png/cpu_20.png)

---

## Декодирование типа инструкции

![h:600 center](png/cpu_21.png)

---

## Итоговая схема процессора

![h:600 center](png/cpu_22.png)

---

## Состав процессора

- Тракт данных
    - Счетчик команд _PC_
    - Память инструкций _Instruction Memory_
    - Декодер инструкций _Instruction Decoder_
    - Регистровый файл _Register File_
    - Арифметико-логическое устройство _ALU_
    - Сумматоры адреса _pcPlus4_ и _pcBranch_
    - Мультиплексоры _pcSrc_, _wdSrc_ и _aluSrc_
- Устройство управления

---

## Реализация: PC, сумматоры и мультиплексор адреса

```Verilog
// sm_register.v
module sm_register
(
    input                 clk,
    input                 rst,
    input      [ 31 : 0 ] d,
    output reg [ 31 : 0 ] q
);
    always @ (posedge clk or negedge rst)
        if(~rst) q <= 32'b0;
        else     q <= d;
endmodule
```

```Verilog
// sr_cpu.v
    wire [31:0] pc;
    wire [31:0] pcBranch = pc + immB;
    wire [31:0] pcPlus4  = pc + 4;
    wire [31:0] pcNext   = pcSrc ? pcBranch : pcPlus4;
    sm_register r_pc(clk ,rst_n, pcNext, pc);
```

---

## Реализация: память инструкций

```Verilog
// sm_rom.v
module sm_rom
#(
    parameter SIZE = 64
)
(
    input  [31:0] a,
    output [31:0] rd
);
    reg [31:0] rom [SIZE - 1:0];
    assign rd = rom [a];

    initial begin
        $readmemh ("program.hex", rom);
    end

endmodule
```

```Verilog
// sm_top.v
sm_rom reset_rom(imAddr, imData);
```

---

## Реализация: декодер инструкций (начало)

```Verilog
// sr_cpu.v
module sr_decode
(
    input      [31:0] instr,
    output     [ 6:0] cmdOp,
    output     [ 4:0] rd,
    output     [ 2:0] cmdF3,
    output     [ 4:0] rs1,
    output     [ 4:0] rs2,
    output     [ 6:0] cmdF7,
    output reg [31:0] immI,
    output reg [31:0] immB,
    output reg [31:0] immU 
);
    assign cmdOp = instr[ 6: 0];
    assign rd    = instr[11: 7];
    assign cmdF3 = instr[14:12];
    assign rs1   = instr[19:15];
    assign rs2   = instr[24:20];
    assign cmdF7 = instr[31:25];
```

---

## Реализация: декодер инструкций (продолжение)

```Verilog
    // I-immediate
    always @ (*) begin
        immI[10: 0] = instr[30:20];
        immI[31:11] = { 21 {instr[31]} };
    end

    // B-immediate
    always @ (*) begin
        immB[    0] = 1'b0;
        immB[ 4: 1] = instr[11:8];
        immB[10: 5] = instr[30:25];
        immB[31:11] = { 21 {instr[31]} };
    end

    // U-immediate
    always @ (*) begin
        immU[11: 0] = 12'b0;
        immU[31:12] = instr[31:12];
    end
endmodule
```

---

## Реализация: регистровый файл

```Verilog
// sr_cpu.v
module sm_register_file
(
    input         clk,
    input  [ 4:0] a0,
    input  [ 4:0] a1,
    input  [ 4:0] a2,
    input  [ 4:0] a3,
    output [31:0] rd0,
    output [31:0] rd1,
    output [31:0] rd2,
    input  [31:0] wd3,
    input         we3
);
    reg [31:0] rf [31:0];

    assign rd0 = (a0 != 0) ? rf [a0] : 32'b0;
    assign rd1 = (a1 != 0) ? rf [a1] : 32'b0;
    assign rd2 = (a2 != 0) ? rf [a2] : 32'b0;

    always @ (posedge clk)
        if(we3) rf [a3] <= wd3;
endmodule
```

---

## Реализация: операции ALU

```Verilog
// sr_cpu.vh

`define ALU_ADD     3'b000  // A + B

`define ALU_OR      3'b001  // A | B

`define ALU_SRL     3'b010  // A >> B

`define ALU_SLTU    3'b011  // A < B ? 1 : 0

`define ALU_SUB     3'b100  // A - B
```

---

## Реализация: ALU

```Verilog
// sr_cpu.v
module sr_alu
(
    input  [31:0] srcA,
    input  [31:0] srcB,
    input  [ 2:0] oper,
    output        zero,
    output reg [31:0] result
);
    always @ (*) begin
        case (oper)
            default   : result = srcA + srcB;
            `ALU_ADD  : result = srcA + srcB;
            `ALU_OR   : result = srcA | srcB;
            `ALU_SRL  : result = srcA >> srcB [4:0];
            `ALU_SLTU : result = (srcA < srcB) ? 1 : 0;
            `ALU_SUB : result = srcA - srcB;
        endcase
    end

    assign zero   = (result == 0);
endmodule
```

---

## Реализация: мультиплексоры данных

```Verilog
// sr_cpu.v
wire [31:0] srcB = aluSrc ? immI : rd2;
```

```Verilog
// sr_cpu.v
assign wd3 = wdSrc ? immU : aluResult;
```

---

## Сигналы управления 1

![h:600 center](png/cu_00.png)

---

## Код операции: спецификация

![h:620 center](img/riscv_iset.png)

---

## Сигналы управления 2

![h:600 center](png/cu_01.png)

---

## Сигналы управления 3

![h:600 center](png/cu_02.png)

---

## Сигналы управления 4

![h:600 center](png/cu_03.png)

---

## Сигналы управления 5

![h:600 center](png/cu_04.png)

---

## Сигналы управления 6

![h:600 center](png/cu_05.png)

---

## Сигналы управления 7

![h:600 center](png/cu_06.png)

---

## Сигналы управления 8

![h:600 center](png/cu_07.png)

---

## Сигналы управления 9

![h:600 center](png/cu_08.png)

---

## Сигналы управления 10

![h:600 center](png/cu_09.png)

---

## Сигналы управления 11

![h:600 center](png/cu_10.png)

---

## Сигналы управления 12

![h:600 center](png/cu_11.png)

---

## Сигналы управления 13

![h:600 center](png/cu_12.png)

---

## Сигналы управления 14

![h:600 center](png/cu_13.png)

---

## Сигналы управления 15

![h:600 center](png/cu_14.png)

---

## Сигналы управления 16

![h:600 center](png/cu_15.png)

---

## Сигналы управления 17

![h:600 center](png/cu_16.png)

---

## Сигналы управления 18

![h:600 center](png/cu_17.png)

---

## Сигналы управления 19

![h:600 center](png/cu_18.png)

---

## Сигналы управления 20

![h:600 center](png/cu_19.png)

---

## Сигналы управления 21

![h:600 center](png/cu_20.png)

---

## Сигналы управления 22

![h:600 center](png/cu_21.png)

---

## Сигналы управления 23

![h:600 center](png/cu_22.png)

---

## Сигналы управления 24

![h:600 center](png/cu_23.png)

---

## Сигналы управления 25

![h:600 center](png/cu_24.png)

---

## Сигналы управления 26

![h:600 center](png/cu_25.png)

---

## Реализация: коды инструкций

```Verilog
// sr_cpu.vh
// instruction opcode
`define RVOP_ADDI   7'b0010011
`define RVOP_BEQ    7'b1100011
...

// instruction funct3
`define RVF3_ADDI   3'b000
`define RVF3_BEQ    3'b000
`define RVF3_BNE    3'b001
`define RVF3_ADD    3'b000
...
`define RVF3_ANY    3'b???

// instruction funct7
`define RVF7_ADD    7'b0000000
...
`define RVF7_ANY    7'b??????? 
```

---

## Реализация: устройство управления (начало)

```Verilog
// sr_cpu.v
module sr_control
(
    input     [ 6:0] cmdOp,
    input     [ 2:0] cmdF3,
    input     [ 6:0] cmdF7,
    input            aluZero,
    output           pcSrc, 
    output reg       regWrite, 
    output reg       aluSrc,
    output reg       wdSrc,
    output reg [2:0] aluControl
);
    reg          branch;
    reg          condZero;
    assign pcSrc = branch & (aluZero == condZero);
```

---

## Реализация: устройство управления (продолжение)

```Verilog
// sr_cpu.v
    always @ (*) begin
        branch      = 1'b0;
        condZero    = 1'b0;
        regWrite    = 1'b0;
        aluSrc      = 1'b0;
        wdSrc       = 1'b0;
        aluControl  = `ALU_ADD;

        casez( {cmdF7, cmdF3, cmdOp} )
            { `RVF7_ADD,  `RVF3_ADD,  `RVOP_ADD  } : begin regWrite = 1'b1; aluControl = `ALU_ADD;  end
            { `RVF7_OR,   `RVF3_OR,   `RVOP_OR   } : begin regWrite = 1'b1; aluControl = `ALU_OR;   end
            { `RVF7_SRL,  `RVF3_SRL,  `RVOP_SRL  } : begin regWrite = 1'b1; aluControl = `ALU_SRL;  end
            { `RVF7_SLTU, `RVF3_SLTU, `RVOP_SLTU } : begin regWrite = 1'b1; aluControl = `ALU_SLTU; end
            { `RVF7_SUB,  `RVF3_SUB,  `RVOP_SUB  } : begin regWrite = 1'b1; aluControl = `ALU_SUB;  end

            { `RVF7_ANY,  `RVF3_ADDI, `RVOP_ADDI } : begin regWrite = 1'b1; aluSrc = 1'b1; aluControl = `ALU_ADD; end
            { `RVF7_ANY,  `RVF3_ANY,  `RVOP_LUI  } : begin regWrite = 1'b1; wdSrc  = 1'b1; end

            { `RVF7_ANY,  `RVF3_BEQ,  `RVOP_BEQ  } : begin branch = 1'b1; condZero = 1'b1; aluControl = `ALU_SUB; end
            { `RVF7_ANY,  `RVF3_BNE,  `RVOP_BNE  } : begin branch = 1'b1; aluControl = `ALU_SUB; end
        endcase
    end
```

---

## Структура проекта и подключение периферии

![h:600 center](img/board.png)

---

## Программирование системы

![h:600 center](png/program_flow.png)

---

## Что дальше?

- Цифровая схемотехника и архитектура компьютера
David Harris & Sarah Harris
ДМК Пресс

- Цифровой синтез: практический курс
Александр Романов & Юрий Панчул
ДМК Пресс

- Syntacore SCR1
https://github.com/syntacore/scr1

---

## Ваши вопросы?
