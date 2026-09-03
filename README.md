# Núcleo de Coprocessador Gráfico em FPGA 
MI de Sistemas Digitais (TEC499) - TP03

## Sumário

* [Introdução](#introdução)
* [Pré-requisitos](#pré-requisitos)
* [Como instalar?](#como-instalar)
* [Requisitos do problema](#requisitos-do-problema)
* [Recursos utilizados](#recursos-utilizados)
* [Metodologia](#metodologia)
  * [Unidade de controle](#unidade-de-controle)
  * [Memória e Paleta](#memória-e-paleta)
  * [Unidades de Desenho (Motores Gráficos)](#unidades-de-desenho-motores-gráficos)
  * [Controlador VGA e Double Buffering](#controlador-vga-e-double-buffering)
* [Testes](#testes)
  * [Como realizar testes?](#como-realizar-testes)
* [Como utilizar o coprocessador?](#como-utilizar-o-coprocessador)
* [Conclusão](#conclusão)
* [Referências](#referências)
* [Colaboradores](#colaboradores)

## Introdução

Os sistemas computacionais exigem, de forma recorrente, a exibição de interfaces visuais complexas, o que demanda a atualização constante de uma vasta matriz de pixels para a formação de quadros na tela. Realizar a varredura de coordenadas e o cálculo das posições de cada elemento visual diretamente na CPU (Central Processing Unit) exige muito poder de processamento, o que pode sobrecarregar o processador principal e tornar os processos gerais do sistema mais lentos. Devido a isso, surge a necessidade de um coprocessador gráfico, uma unidade de processamento dedicada a gerenciar operações visuais de forma modularizada e eficiente.

Diante dessa abordagem, foi solicitado aos alunos da disciplina TEC499 (Sistemas Digitais) da Universidade Estadual de Feira de Santana o desenvolvimento do núcleo de um coprocessador gráfico em FPGA, inspirado na arquitetura de consoles de 16 bits. O projeto utiliza a placa DE1-SoC e a linguagem de descrição de hardware Verilog comportamental, sendo preparado para, em etapas posteriores, ser controlado por um driver Linux em Assembly ARM para a execução de uma aplicação em C.

## Pré-requisitos

É necessário ter um kit de desenvolvimento DE1-SoC, pertencente à família Cyclone V. Também é necessário possuir o software Quartus Prime Lite Edition (a versão 23.1 foi utilizada no desenvolvimento) instalado no dispositivo para implementar o coprocessador na placa e realizar a síntese do hardware. Além disso, o uso de um monitor com interface VGA é essencial para a visualização das imagens geradas e resultados obtidos.

Os requisitos de hardware devem ser estritamente seguidos, visto que a pinagem e a configuração dos clocks estão estabelecidas para o kit de desenvolvimento especificado.

## Como instalar?

1. Faça o download do projeto como arquivo .zip do repositório e extraia no seu computador.
2. Abra o software Quartus Prime.
3. Acesse File > Open Project.
4. Encontre e selecione o arquivo `pbl1.qpf` na pasta raiz extraída.
5. Com o projeto aberto, inicie a compilação clicando no ícone de compilação ou acessando Processing > Start Compilation.
6. Vá em Tools > Programmer.
7. Clique em Hardware Setup para garantir que o Quartus reconheceu a placa conectada.
8. Carregue o arquivo `.sof` gerado e clique em Start para gravar o hardware na FPGA.

## Requisitos do problema

O problema exige um núcle de coprocessador capaz de gerar sinais de vídeo contínuos e compor uma cena gráfica, reduzindo a carga do processador ARM. Os requisitos estipulados foram:

* Hardware do coprocessador descrito integralmente em Verilog.
* Saída de vídeo operando na resolução de 640x480 pixels a 60 Hz via interface VGA.
* Resolução lógica interna da cena em 320x240 pixels, de modo que cada pixel lógico seja duplicado (fator 2x2) na saída física.
* Suporte a três camadas gráficas independentes:
  * **Plano de Fundo (Background):** Baseado em um tilemap de 40x30 entradas, empregando blocos de 8x8 pixels com capacidade de deslocamento da cena (scrolling).
  * **Sprites:** Memória e controle para no mínimo 32 objetos dinâmicos de 16x16 pixels, com suporte a propriedades como ativação e espelhamento horizontal e vertical.
  * **Polígonos:** Motor de rasterização de triângulos e retângulos preenchidos, empregando estritamente aritmética inteira.
  * Sistema de composição com prioridade visual entre as camadas e suporte a transparência, utilizando uma paleta programável de 256 cores convertidas para RGB.

## Recursos utilizados

* **Placa DE1-SoC:** Hardware principal, utilizando o chip FPGA (família Cyclone V) para receber a descrição do projeto e instanciar os blocos de memória.
* **Quartus Prime Lite 23.1:** Software que permite a criação, depuração e otimização de códigos em linguagem de descrição de hardware, utilizado para gerar os IP Cores (circuitos lógicos pré-projetados) necessários (ALTSYNCRAM para mémorias dedicadas e Altera PLL para geração de clock específico).
* **GitHub:** Plataforma de hospedagem utilizada para versionar os arquivos de código-fonte (`.v`), projetos (`.qpf`, `.qsf`) e arquivos de inicialização de memória (`.mif`, `.hex`).






