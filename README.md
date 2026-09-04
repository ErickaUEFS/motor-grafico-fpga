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

## Metodologia

Os computadores possuem como um dos seus componentes principais o processador (CPU), que realiza o controle do fluxo de dados e o processamento de instruções do sistema. Contudo, muitas operações, como o cálculo contínuo das coordenadas de pixels, exigem muito poder de processamento, o que pode sobrecarregar a CPU e tornar o sistema lento. Assim, surge a ideia do coprocessador gráfico (GPU), uma unidade de processamento auxiliar que atua de forma independente e paralela à CPU, servindo para realizar as operações de geração de imagem de forma muito mais eficiente.

Para o desenvolvimento deste coprocessador, a arquitetura foi planejada com foco no paralelismo de hardware. A geração de imagens exige um sincronismo rigoroso para o monitor VGA. Para assegurar o processamento rápido sem comprometer a taxa de varredura do monitor, o sistema opera sob dois domínios de clock: um clock de 100 MHz para os cálculos e a escrita na memória de vídeo, e um clock de 25 MHz para a leitura contínua e o envio do sinal VGA.

### Unidade de controle

A unidade de controle descreve um design de arquitetura responsável pelo fluxo de dados e pela ativação dos módulos de desenho. Atuando como uma Máquina de Estados Finitos (MEF), o módulo `Controle.v` processa as entradas do usuário e direciona as instruções aos motores gráficos.

O módulo faz a leitura das chaves da placa passando pelo Debounce_SW.v. Esse arquivo serve para limpar o ruído mecânico (mau contato que gera instabilizade natural dos botões/chaves), usando um contador interno para garantir que o clique só seja aceito quando o sinal se mantiver totalmente estável.

A máquina de estados opera de um jeito bem direto, alternando entre o ESTADO_NORMAL e o ESTADO_MOVENDO. Lendo as chaves SW[9:8], ela entende qual camada gráfica será enviada para tela (Polígonos, Sprites, Background ou Todos). A partir dessa escolha, ela avisa o motor gráfico correto ligando os sinais de habilitação (como o controle_ativo) e mandando qual é a direcao exata do movimento.

### Memória e Paleta

A memória é um recurso escasso em FPGAs. Mapear totalmente a resolução de 640x480 pixels em formato RGB de 24 bits consumiria blocos lógicos inviáveis para este hardware. Para contornar tal limitação, a arquitetura reduz a malha de desenho para uma resolução lógica de 320x240, desconsiderando o bit menos significativo das coordenadas físicas X e Y advindas do módulo VGA.

O módulo de paleta opera como uma tabela de conversão, recebendo o índice de 8 bits do motor de polígonos e decodificando a cor exigida em um valor de 8 bits de cor RGB (3 primeiros para Vermelho, 3 para Verde e 2 para Azul). A paleta envia a informação de cor para o módulo compositor que mapeia para uma saída RGB de 24 bits (8 bits por canal) ligada diretamente aos conversores digital-analógico do monitor. O índice de valor 0 é reservado como máscara de transparência, ou seja, não traduz de fato uma cor.
Os dados puros de imagens (cenários e sprites) são armazenados em arquivos `.mif` que alimentam as memórias ROM instanciadas no projeto, como o módulo `tiles256.v`, que aloca 16384 bites para localizar e armazenar os padrões gráficos.

### Unidades de Desenho (Motores Gráficos)

A unidade lógico-aritmética visual do coprocessador divide-se em três motores de hardware dedicados. Todos operam com as coordenadas de varredura previamente convertidas para a resolução lógica.

### Unidades de Desenho (Motores Gráficos)

A unidade lógico-aritmética visual do coprocessador divide-se em três motores de hardware dedicados. Todos operam com as coordenadas de varredura previamente convertidas para a resolução lógica.

**Motor de Background**

O módulo `Motor_Background.v` é responsável por formar o cenário utilizando o conceito de Tilemap. Ele armazena uma matriz de 40x30, totalizando 1200 índices de tiles de 8x8 pixels.
Para determinar o pixel correto que a varredura atual está, o módulo soma o deslocamento atual (inicializado em 0) às coordenadas de varredura. O valor resultante é dividido por 8 para identificar a localização do bloco no mapa, e o resto da divisão define a posição exata do pixel dentro do tile selecionado, gerando o endereço de memória apropriado para leitura na ROM.

**Motor de Sprites**

A geração de elementos mais móveis e dinâmicos ocorre através do `Motor_sprite.v`, que controla registradores de posição X e Y, além de visibilidade e espelhamento, para até 32 sprites simultâneos.
O módulo varre ativamente as coordenadas e, caso o ponto lógico atual esteja dentro das dimensões de 16x16 pixels de um sprite ativo (estar ativo é uma sinalização que cada sprite armazena), calcula o endereço na ROM correspondente. A aplicação de espelhamento é feita de forma aritmética; se o sinal de inversão estiver habilitado, a coordenada local do pixel é subtraída de 15, permitindo reutilizar o mesmo sprite na memória para orientações distintas.

**Motor de Rasterização de Polígonos**

Para desenhar polígonos, o `Motor_Rasterizador.v` dispensa bancos de imagem e utiliza aritmética inteira.
A técnica para triângulos e quadrado preenchidos a partir de coordenadas recebidas (x e y para cada vértice) é a Edge Functions (Equações de Arestas). O algoritmo realiza o determinante entre o vetor de cada aresta do triângulo e o vetor do ponto de varredura com cada vértice recebido. Quando os três determinantes resultantes apresentam o mesmo sinal, comprova-se que a coordenada pertence à área interna do polígono, habilitando o preenchimento do pixel com o índice de cor pré-definido (índice de cor é a saída do módulo).

### Controlador VGA e Double Buffering

Como os três motores funcionam em paralelo, é necessário um estágio de composição de cena. O `Compositor.v` atua como um multiplexador que obedece à regra de prioridade: Polígonos sobrepõem Sprites, que sobrepõem o Background. Caso a camada superior envie a cor 0 (transparência), a cor da camada inferior é assumida.

Para exibir a imagem composta sem instabilidades visuais, o projeto implementa o conceito de Double Buffering utilizando memória RAM.
A GPU opera no clock de 100 MHz desenhando o quadro inteiro em um buffer. Simultaneamente, o módulo `vga_driver.v` lê o segundo buffer a 25 MHz para enviar os dados aos fios físicos do monitor VGA e gerar os intervalos de Blanking necessários (sincronismo horizontal e vertical). Apenas ao final da atualização da tela (durante o pulso de VSYNC), o sinal de `swap_request` inverte a leitura dos buffers, atualizando o quadro de forma imperceptível para o usuário.

## Testes

Os testes físicos representam uma etapa fundamental na validação do projeto, servindo para confirmar se o sincronismo dos clocks e a lógica descrita funcionam perfeitamente na prática ao enviar o sinal visual para o monitor. Para validar se cada módulo estava operando de forma correta, a estratégia adotada foi isolar os motores gráficos utilizando as chaves da placa, testando o comportamento de cada desenho um por vez na tela. 

Um exemplo notório dessa depuração ocorreu na verificação do Motor de Rasterização de Polígonos. Durante os primeiros testes físicos de movimentação, notou-se um erro visual com erro de proporção: a figura geométrica desformatava completamente ao mudar de local pela tela. O problema acontecia porque a lógica inicial de deslocamento não estava mantendo a proporção exata da geometria. Para investigar e solucionar esse defeito, adotou-se a estratégia de deslocar apenas 1 pixel por ciclo de movimento, permitindo visualizar a transição do desenho de forma bem suave. 

Com essa abordagem, percebeu-se de forma muito clara que "deslocar" um polígono não é apenas mudar o ponto de origem, mas significa, obrigatoriamente, somar ou subtrair 1 pixel de *todos* os seus vértices simultaneamente na coordenada solicitada. Ou seja, para mover um quadrado para a direita, a máquina precisava incrementar exatamente 1 pixel nos registradores `posX0`, `posX1`, `posX2` e `posX3` ao mesmo tempo. Qualquer atraso ou falta de atualização em um desses vértices causava a deformação visual.

Assim como ocorreu com os polígonos, os motores de sprites e de background foram avaliados passo a passo na placa física. Esse processo garantiu que os limites de borda da tela fossem respeitados (evitando que o desenho "vazasse" para o outro lado do monitor) e que a sobreposição das camadas no Compositor funcionasse perfeitamente, validando o trabalho em conjunto de toda a arquitetura diretamente no hardware.

### Como realizar testes?

Com a FPGA programada e o monitor conectado via VGA, os testes de controle de hardware utilizam as entradas físicas:
1. Utilizando as chaves `SW[9:8]`, selecione modos (`00` para Polígonos, `01` para Sprites e `10` para Background). Isso isola a via de dados de cada motor, permitindo a depuração visual independente.
2. Acione os botões `KEY[3:0]` para deslocar cima, baixo, direita e esquerda (tanto para polígonos, sprites, e background), observando o comportamento do componente nos limites do monitor que não permitem ultrapassar a resolução 640x480, feito para evitar underflow ou overflow nos registradores de posição.
3. Modifique para o modo de exibição total (`11`) e sobreponha os sprites aos cenários e polígonos, com o intuito de validar a integridade da lógica de transparência e prioridade de visibilidade definida pelo módulo Compositor.
4. Para as chaves 'SW[7:5]' em motor background SW[9:8] em 00, selecione qual posição do mapa receberá o novo tile escolhido, e selecione o índice do tile na memória com as chaves SW[4:2] Com isso, consegue-se editar de forma isolada, por exemplo, o tile das 4 primeiras posições do canto esquerdo superior do monitor.
5. Nos modos de Sprite e Polígonos, use a chave 'SW[2]' e note o componente de índice 0 sumir ou reaparecer. Essa chave atua como liga/desliga, alterando a flag de ativação e visibilidade do objeto.
6. Exclusivamente no modo Sprite, manipule as chaves SW[1:0], elas ativam o espelhamento da imagem na horizontal e na vertical, invertendo o sentido do sprite selecionado instantaneamente.

## Conclusão

Diante do detalhamento de todos os componentes, conclui-se que o desenvolvimento deste núcleo de coprocessador gráfico em FPGA cumpriu com os objetivos estabelecidos para o problema, operando de forma autônoma para desenhar polígonos, sprites e cenários na tela. Mais do que a entrega de um produto funcional, a construção deste projeto proporcionou uma imersão profunda e prática nos conceitos de arquitetura de computadores. O processo evidenciou a importância da modularização, mostrando como um sistema complexo precisa ser dividido em blocos dedicados e independentes — como unidades de controle, memórias, motores gráficos — para que o processador funcione de maneira organizada e paralela.

O desenvolvimento teve um impacto significativo no aprendizado sobre a geração de imagens digitais. Foi necessário compreender desde o princípio mais básico: o fato de que uma imagem na tela não aparece de uma só vez, mas é um aglomerado de pixels desenhados individualmente pelo monitor em um processo de varredura constante, da esquerda para a direita e de cima para baixo. Entender essa dinâmica física foi essencial para projetar a lógica de hardware que calcula, no exato nanossegundo, qual cor deve ser enviada aos fios do cabo VGA.

Para que essa comunicação com o monitor funcionasse sem interrupções, o domínio sobre a lógica de controle e o gerenciamento de clocks mostrou-se um aprendizado indispensável. Como a FPGA precisa calcular a posição matemática das figuras ao mesmo tempo em que a tela varre os pixels, o sistema foi estruturado com dois clocks independentes operando em conjunto com a técnica de Double Buffering. Esse controle temporal foi o responsável por eliminar falhas e instabilidades na formação do quadro, resultando em um vídeo limpo e sincronizado.

Por fim, estratégias como o uso da resolução lógica (agrupando pixels reais para economizar blocos de memória RAM) e a aplicação de equações matemáticas puras (Edge Functions) para rasterizar geometrias sem o uso de imagens pré-salvas, demonstraram na prática como contornar as limitações físicas de hardware de forma eficiente. 

Apesar do funcionamento correto dos motores gráficos, o projeto apresenta algumas limitações próprias desta primeira etapa de desenvolvimento. No motor de rasterização, por exemplo, o suporte a figuras geométricas restringe-se exclusivamente à geração de triângulos e retângulos preenchidos, não permitindo o desenho de polígonos mais complexos. Além disso, a interface de interação é exclusivamente manual e dependente do hardware na placa DE1-SoC, utilizando apenas as chaves e botões como meio de controle e coleta de dados de escolha. Consequentemente, o núcleo gráfico, operando de forma isolada neste momento, não é capaz de receber comandos via periféricos externos, como teclado e mouse. Essa restrição de controle, no entanto, é temporária e será superada nas etapas futuras do projeto, quando houver a implementação do barramento de comunicação (MMIO), permitindo que o processador ARM assuma o tratamento dos periféricos de entrada e envie as instruções diretamente ao coprocessador.

## Referências

Patterson, D. A. ; Hennessy, J. L. 2016. Morgan Kaufmann Publishers. Computer organization and design: ARM edition. 5ª edição.

PANTUZA, J. Organização e arquitetura de computadores: pipeline em processadores. Disponível em: https://blog.pantuza.com/artigos/organizacao-e-arquitetura-de-computadores-pipeline-em-processadores.

INTEL CORPORATION. Intel 8087 Numeric Data Processor: User’s Manual. Disponível em: https://datasheets.chipdb.org/Intel/x86/808x/datashts/8087/205835-007.pdf.

## Colaboradores

Ericka Almeida de Lima- ErickaUEFS

Gustavo Leão- GustavolLeao

Felipe Queiroz-felsq

