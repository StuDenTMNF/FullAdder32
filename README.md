
В данном репозитории будет рассказано о полном 32-битном сумматоре с последовательным переносом на языке SystemVerilog в среде разработки Quartus Prime lite
## Введение

32-битный сумматор - это такой элемент, который должен суммировать два 32-битных числа. Чтобы написать его, требуется рассмотреть сначала неполный сумматор, полный сумматор и масштабировать эти сумматоры до нужной нам битности. Поэтому мы начнем рассматривать неполный сумматор
    
## Неполный сумматор (halfAdder)

Неполный сумматор - это такой элемент, который не учитывает бит переноса при получении чисел A и В. В самом простом случае мы можем написать таблицу суммы двух однобитных чисел A и В. 


<img width="178" height="220" alt="image" src="https://github.com/user-attachments/assets/25ebc780-0e7e-4cc4-a8ca-6096c685d9f1" />

Из таблицы видно, что при сумме двух чисел A=B=1 мы должны перенести единицу в следующий разряд. Данная единица и называется битом переноса при сложении двух однобитных чисел.

S - сумма

C - бит переноса 


Запишем макстермы для S и С:

$$
S = \overline{A}B \lor \overline{B}A = A \oplus B
$$

$$
С = А \cdot B
$$

Исходя из формул пришли к тому, что нас полусумматор - это волшебная коробочка со входами A и В. Эта коробочка имеет выходы S и С


<img width="599" height="259" alt="image" src="https://github.com/user-attachments/assets/4a1bf469-e4f6-4461-8b16-82ec1d2d499b" />


После приведения формул к простейшему виду для реализации мы можем описать аппаратуру на одном из языков. Я буду описывать на языке Systemverilog. 
В качестве упражнения и более глубоко понимания материала я советую отдельно реализовать модули XOR, AND и после этого использовать их в главном модуле, который будет называться, например, HalfAdder (или Top, кому как удобнее)

Приступаем к созданию полусумматора:
1. Создание And.
 ```systemverilog


//Наш модуль нельзя называть в точности And, т.к это конфликт с внутренней библиотекой Quartus

module Andd(
input  logic A, //объявляем тип переменной как logic
input  logic B,
output logic C
);

assign C = A & B;

endmodule
```
2. создание Xor
 ```systemverilog


module Xorr(
input  logic A, B, 
output logic C
);

assign C = A ^ B;

endmodule 
```

3. Создание главного модуля HalfAdder

самое интересное в этой задаче начинается в данном пункте. Исходя из фото волшебной коробочки, которое чучили из преобразования таблицы, мы записываем следующее:

```systemverilog


module HalfAdder(
input  logic a,
input  logic b,
output logic carry_o, sum_o
);
```

carry_o - это бит переноса 

sum_o - сумма

А вот для того, чтобы соединить модули Andd и Xorr в одном главном модуле HalfAdder, нужно:

* Объявить модуль, который Вы хотите соединить.
* Дать ему Имя, например And1
* Подключение элементов происходит таким образом: ``` .A(a) ``` . Мы явно показываем, что Вход Элемента Andd подсоединен ко входу ``` a ``` модуля HalfAdder.

В общем, выглядит это следующим образом:
```
Andd And1( .A(a), .B(b), .C(carry_o) );
```
Аналогично для sum_o запишите сами.

Анализируем и синтезируем. Открываем Netlist и в итоге:

<img width="1584" height="789" alt="image" src="https://github.com/user-attachments/assets/57d252cd-84c3-4076-b428-e7a6466145d6" />

Теперь можно переходить к полному сумматору.

## Полный сумматор.(FullAdder)

Неполный сумматор отличался тем, что в него не входил бит переноса Cin. Сейчас же нужно рассмотреть случай, при котором существует бит переноса Cin, входящий в наш неполный сумматор.

Записываем таблицу истинности:

<img width="323" height="323" alt="image" src="https://github.com/user-attachments/assets/d73ce454-b736-4df4-8450-50055a40609e" />

Пишем макстермы для Cout, S.

$$ 
Cout = \overline{Сin}AB \lor Cin\overline{A}B \lor CinA\overline{B} \lor CinAB=AB \lor CoutA\overline{B} \lor Cout\overline{A}B = AB \lor CinB \lor CinA
$$

$$
S = \overline{Сin}\overline{A}B \lor \overline{Cin}A\overline{B} \lor Cin\overline{A}\overline{B} \lor CinAB = A \oplus B \oplus Cin
$$

(нужно лишь сравнить таблицу истинности для трехвводового XOR'a и нашу таблицу истинности)

Для Cout же чуть чуть интереснее, но не менее просто. Мы всегда получаем единицу на выходах, когда хотя бы 2 элемента равны единице. Т.е к примеру, если Cin = 0, То мы получаем единицу на выходе только при AB = 1. Если же $Сin \neq 0$ , то мы получаем 1 на выходе при:

1. A=B=1
2. $A \neq B$. При A = 0, B=1, тогда $Сin\overline{A}B=1$ , аналогично для A = 1, B=0 и тогда $Cin\overline{B}A=1$ ,
Исходя из подобных рассуждений результат представлен в последнем равенстве.

Исходя из уравнений, который мы получили, нарисуем примерную схему нашего полного сумматора:

<img width="906" height="431" alt="image" src="https://github.com/user-attachments/assets/91eeeac2-5c38-4b0b-8643-cb7a6969aeb2" />

После всех рассуждений и получении примерной схемы можно приступать к описании нашего полного сумматора. Я так же буду использовать намеченный путь и соединять уже созданные модули Xor, And, Or в один большой модуль под названием полный сумматор(Fulladder). 

Для данной схемы потребуется новый модуль Or. Вы можете сделать его сами. 

```systemverilog


module Orr(

input  logic A, 
input  logic B,
output logic C); 
assign C = A | B;
endmodule
```

Теперь приступим к созданию однобитного полного сумматора. Для создания данной схемы нам потребуются также так называемые провода, который вводятся следующим образом:
``` wire a,b,s ;//Можно объявлять как logic, для нашей схемы это не важно ```

1. Так же определяем входные и выходные сигналы нашей схемы:

```systemverilog


module fulladder(
input  logic a_i,
input  logic b_i, 
input  logic carry_i,//входной бит переноса
output logic sum_o,
output logic carry_o);//выходной бит переноса
);
```
2. Определяем провода, как тип данных wire. 

```systemverilog


wire q, w, e, r, t,y;

```
3. Соединяем модули с помощью проводов. Задача простая, просто чуть неприятная из-за количества элементов. Рекомендую сделать это самим.

```systemverilog


Xorr moduleXOR1( .A(a_i),     .B(b_i),     .C(q)       );//обратите внимание, что одинаковые модули должны называться по разному.
Xorr moduleXOR2( .A(q),       .B(carry_i), .C(sum_o)   );
Andd moduleAND1( .A(a_i),     .B(carry_i), .C(w)       );
Andd moduleAND2( .A(a_i),     .B(b_i),     .C(e)       );
Andd moduleAND3( .A(carry_i), .B(b_i),     .C(r)       );
Orr  moduleOR1 ( .A(w),       .B(e),       .C(t)       );
Orr  moduleOR2 ( .A(t),       .B(r),       .C(carry_o) );

endmodule

```

Все, модуль готов. Анализируем и синтезируем. Открываем Netlist, в итоге получаем наш полный сумматор, который мы описали:

<img width="1461" height="725" alt="image" src="https://github.com/user-attachments/assets/c6802f42-d336-402b-b620-3b3e7ad0eb03" />

Теперь можно переходить к реализации 32и двух битного сумматора.

## 32-битный сумматор

32-битный сумматор( далее просто сумматор или fulladder32) можно сделать простым масштабированием однобитного сумматора до 32ух штук. Но мне проще было написать сначала 4-битный сумматор, чтобы потом уже его масштабировать до сумматора.

А что такое вообще 4ех битный сумматор? По сути, это масштабированный однобитный сумматор, т.е

* На вход ему идут 4ех битные числа A и В.
* На вход ему идет бит переноса.
* С выхода мы получаем 4ех битные числа А и В.
* С выхода мы получаем бит переноса.
  
И это важно понимать, что Бит переноса остался так же однобитным, ведь он вошел однобитным числом. После первого сумматор он вышел с этого сумматора и попал в следующий и так четыре раза.
Числа же 4-битные попадают на вход всего модуля(В смысле модуля четырехбитного сумматора), как шина из 4ех проводов, каждый из четырех проводов попадает в отдельный однобитный сумматор. После однобитного сумматора они так же формируют шину из четырех проводов на выходе, оставаясь четырехбитным числом.

1.Входные сигналы нашей схемы:
```systemverilog

module fulladder4(
  input  logic [3:0] a_i, b_i, //Битность сигналов(проводов) задается подобным образом. Может быть задана также [0:3] или [7:4] например. 
  input  logic       carry_i,
  output logic [3:0] sum_o,
  output logic       carry_o
);

```

2.Теперь соединение однобитных сумматоров
```systemverilog
fulladder fa1 (.a_i(a_i[0]), .b_i(b_i[0]), .carry_i(carry_i), .sum_o(sum_o[0]), .carry_o(c1));
fulladder fa2 (.a_i(a_i[1]), .b_i(b_i[1]), .carry_i(c1),      .sum_o(sum_o[1]), .carry_o(c2));
```
Для fa3 и fa4 допишите сами по аналогии. 

Анализируем и синтезируем описанный сумматор. Открываем Netlist и видим следующее:

<img width="1600" height="832" alt="image" src="https://github.com/user-attachments/assets/bc7ad7dc-31a9-43af-94dc-c57297667fe7" />

Я специально не написал 
```systemverilog
wire c1, c2, c3;

```
Так как даже если вы забыли объявить провода для соединения отдельных модулей (даже если вы в самом соединении объявили, а ранее почему-то нет), то quartus об этом сообщит и сам их добавит.

Warning (10236): Verilog HDL Implicit Net warning at fulladder32.sv(38): created implicit net for "c1"

Warning (10236): Verilog HDL Implicit Net warning at fulladder32.sv(39): created implicit net for "c2"

Warning (10236): Verilog HDL Implicit Net warning at fulladder32.sv(40): created implicit net for "c3"

### Ну чтож, теперь можно переходить к сумматору(fulladder32)

По аналогии с 4-битным сумматором fulladder32 можно описать, масштабируя ранее написанный 4-битный сумматор.

* Так как это сумматор для 32-битных чисел, то и числа A и В должны содержать 32 бита.
* На вход так же подается бит переноса.

1. Входные сигналы нашей схемы
```systemverilog

module fulladder32(
  input  logic [31:0] a_i, b_i,
  input  logic        carry_i,
  output logic [31:0] sum_o,
  output logic        carry_o
);

```

2. Определяем провода, как тип данных wire. 

```systemverilog

wire [8.0]c;

```
3. Соединяем 4-битные сумматоры

```systemverilog

fulladder4 f1( .a_i(a_i[3:0]),  .b_i(b_i[3:0]),  .carry_i(carry_i), .sum_o(sum_o[3:0]),  .carry_o(c[0]) ); 
fulladder4 f2( .a_i(a_i[7:4]),  .b_i(b_i[7:4]),  .carry_i(c[0]),    .sum_o(sum_o[7:4]),  .carry_o(c[1]) );
fulladder4 f3( .a_i(a_i[11:8]), .b_i(b_i[11:8]), .carry_i(c[1]),    .sum_o(sum_o[11:8]), .carry_o(c[2]) );
...

```
Допишите для остальных пяти 4-битных сумматоров по аналогии.

Анализируем и синтезируем. Открываем Netlist и получаем следующее:

<img width="1606" height="657" alt="image" src="https://github.com/user-attachments/assets/2377f3f9-ac1f-4597-a45e-eed767371172" />

Наш 32-битный сумматор готов.
```systemverilog

wire [8:0]c;

```
Конечно, нам нужно было всего лишь ```[6:0]c``` проводов. 

## Проверка сумматора в Modelsim

К сожалению, у меня пока нет навыков написания testbench для проектов, поэтому мы будем пользоваться готовым для проверки нашего сумматора. 

```systemverilog

`timescale 1ns/1ns

module fulladder32_tb;
    // Объявление тестовых сигналов
    logic [31:0] a_i, b_i;
    logic        carry_i;
    logic [31:0] sum_o;
    logic        carry_o;
    
    // Ожидаемые значения (для проверки)
    logic [31:0] expected_sum;
    logic        expected_carry;
    
    // Сумматор для тестирования
    fulladder32 dut (
        .a_i(a_i),
        .b_i(b_i),
        .carry_i(carry_i),
        .sum_o(sum_o),
        .carry_o(carry_o)
    );
    
    initial begin
        // Инициализация
        $dumpfile("dump.vcd");
        $dumpvars(0, fulladder32_tb);
        
        // Тест 1: Нулевые входы
        a_i = 0; b_i = 0; carry_i = 0;
        expected_sum = 0; expected_carry = 0;
        #10;
        check_results("Test 1: Zero inputs");
        
        // Тест 2: Сложение с переносом
        a_i = 32'h0000_0001; 
        b_i = 32'h0000_0001; 
        carry_i = 1;
        expected_sum = 3; 
        expected_carry = 0;
        #10;
        check_results("Test 2: 1+1+carry");
        
        // Тест 3: Максимальные значения без переполнения
        a_i = 32'h7FFF_FFFF; 
        b_i = 32'h7FFF_FFFF; 
        carry_i = 0;
        expected_sum = 32'hFFFF_FFFE;
        expected_carry = 0;
        #10;
        check_results("Test 3: Max no overflow");
        
        // Тест 4: Переполнение
        a_i = 32'hFFFF_FFFF; 
        b_i = 32'hFFFF_FFFF; 
        carry_i = 0;
        expected_sum = 32'hFFFF_FFFE;
        expected_carry = 1;
        #10;
        check_results("Test 4: Full overflow");
        
        // Тест 5: Случайные значения
        for (int i = 0; i < 5; i++) begin
            a_i = $urandom();
            b_i = $urandom();
            carry_i = $random() % 2;
            {expected_carry, expected_sum} = a_i + b_i + carry_i;
            #10;
            check_results($sformatf("Test 5.%0d: Random", i));
        end
        
        // Тест 6: Цепной перенос
        a_i = 32'h1111_1111; 
        b_i = 32'h1111_1111; 
        carry_i = 0;
        expected_sum = 32'h2222_2222;
        expected_carry = 0;
        #10;
        check_results("Test 6: Chain carry");
        
        // Тест 7: Граничный случай (32-й бит)
        a_i = 32'h8000_0000; 
        b_i = 32'h8000_0000; 
        carry_i = 0;
        expected_sum = 0;
        expected_carry = 1;
        #10;
        check_results("Test 7: MSB addition");
        
        $display("All tests completed!");
        $finish;
    end
    
    // Автоматическая проверка результатов
    task check_results(input string test_name);
        if (sum_o !== expected_sum || carry_o !== expected_carry) begin
            $error("%s FAILED", test_name);
            $display("  Inputs:  a_i=%h b_i=%h carry_i=%b", a_i, b_i, carry_i);
            $display("  Outputs: sum_o=%h (exp: %h) carry_o=%b (exp: %b)",
                    sum_o, expected_sum, carry_o, expected_carry);
            $display("  Difference: %d", expected_sum - sum_o);
            $fatal(1);
        end
        else begin
            $display("%s PASSED", test_name);
        end
    endtask
endmodule

```

Добавляем  Testbench в файлы проекта fulladder32. В настройках во вкладке симуляция добавляем наш файл, как testbench файл

<img width="884" height="807" alt="image" src="https://github.com/user-attachments/assets/0c73d3ee-3972-478a-acd8-c2bfbda25b57" />


<img width="530" height="566" alt="image" src="https://github.com/user-attachments/assets/a33d2ef1-939e-4cb8-81df-7237dfe4a825" />


После этого еще раз анализируем и синтезируем. После успешно запускаем RTL Simulation.

<img width="960" height="1032" alt="image" src="https://github.com/user-attachments/assets/e05137c7-e6f7-40d9-9b5f-7a8ce395282c" />

В Modelsim уже мы получим следующее :            

<img width="1896" height="984" alt="image" src="https://github.com/user-attachments/assets/9c827c31-70fd-4dc5-98ec-25c323df517a" />


Все. Вся работа завершена. Мы успешно написали свой первый 32-битный сумматор.

Некоторые ссылки:

1.[Рисунки](https://github.com/MPSU/APS/tree/master/Labs/01.%20Adder)

2.[Описание модулей на языке SystemVerilog](https://github.com/MPSU/APS/blob/master/Basic%20Verilog%20structures/Modules.md)
