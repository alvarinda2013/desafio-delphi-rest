# Desafio Delphi Rest

## Passos para realizar o desafio

- Você deverá realizar o fork deste projeto e desenvolver o aplicativo conforme descrito abaixo
- Faça o checkout do fork e desenvolva sua aplicação localmente
- Após finalizar o desenvolvimento, realize um pull request para o nosso repositório

# Descritivo do desafio

## Aplicativo Consulta de CEPs

O desenvolvimento do aplicativo consiste em consumir uma API de consulta de CEP, esta API é pública e você podera obter a documentação e método de autenticação no endereço a seguir: https://brasilapi.com.br/docs

Seu objetivo é realizar o consumo desta API, seguindo o escopo abaixo:

- Tela inicial deve conter um campo para o usuário informar um código de CEP, com uma máscara apropriada para CEPs.
- Deve possuir um botão "Consultar" que após clicado, deverá executar a rotina de consulta de CEP e exibir na tela TODOS os dados retornados da consulta, como UF, Endereço, Bairro, etc...
- Implementar tratamentos de erros e de time-out. Caso a API não responda em até 5 segundos, uma mensagem deverá ser retornada para o usuário que o serviço de CEP está indisponível no momento e que ele deverá tentar novamente mais tarde. 
- Caso o usuário informe um CEP com formato ou conteúdo inválido o tratamento deverá ser realizado pela aplicação antes de realizar a consulta na API e a mensagem adequada exibida para o usuário.
- A rotina de consulta de CEP deverá ser encapsulada em uma Classe TConsultaCEP, onde tudo que seja necessário para realizar o acesso a API esteja auto contido na classe de maneira que essa consulta de CEP possa ser utilizada numa outra tela ou até mesmo numa outra aplicação apenas instanciando a classe e chamando um método "ConsultarCEP(xxx)", que deverá encapsular o retorno dos dados também numa classe. Ex: TRetornoCEP.
- Ao consultar um CEP, os dados retornados devem ser gravados num banco de dados (Postgres de preferencia, mas pode ser outro). Ao consultar um cep, antes de acessar a API, deverá consultar no banco e retornar do banco caso o CEP já exista. Para isso, deverá ser criado a logica de acesso banco numa classe DAO separada da classe de consulta na API (não misturar responsabilidade das classes, pois a classe TConsultaCEP deve continuar sendo possivel obter os CEPs sem que seja necessario acesso a banco de dados)

## Adicionais 

Os adicionais não são obrigatórios, mas poderemos considerá-los para o processo de seleção, caso fiquemos em dúvida entre mais de um candidato, portanto, 
é recomandado faze-los.

- Adicional 1: Utilizar threads ou tasks para que a tela não fique trancada no momento da consulta
- Adicional 2: Fazer um comando no programa para a cada X minutos (configurado no proprio aplicativo) consultar uma faixa de ceps (Ex: do 93336-999 ao 93336-999).. essa faixa tambem tem que ser configurada, acessar os ceps e salvar eles no banco de dados de cache de ceps ou atualizar caso já exista.  Detalhe: cuidar para não dar erro de uso indevido da api (não fazer milhares de acessos em sequencia, colocar um intervalo de tempo). Essa busca deverá ser realizada de forma que não trave a tela (em thread ou task)... e cuidar para que os erros de acesso sejam tratados e salvos em arquivo de log (não pode subir erros na tela para o usuario durante a execução automatica).. quando a task tiver em execução, colocar um aviso em tela para o usuario de que a mesma está rodando (por exemplo, num status bar) a consulta normal tem que continua funcionando durante o processamento das faixas de CEP. Colocar um botão na tela para disparar manualmente, caso o usuario não queria esperar os minutos configurados para rodar automaticamente. Cuidar para não deixar o programa disparar em duplicidade a rotina de busca de faixas (ex: se configurar para disparar a cada poucos minutos, quando chegar o tempo do novo disparo, se a execução anterior ainda tiver em andamento, tem que tratar para não ter duas rodando ao mesmo tempo, ou se o usuario clicar no botão pra disparar manualmente e ja tiver uma automatica sendo executada, tem que parar a que esta rodando ou dar uma mensagem de que ja tem um processamento em execução)
- Adicional 3: Criar suporte a manutenção dos CEPs gravados em banco de dados (opções de visualizar em grid, editar, excluir, buscar por UF, endereço, ou filtrar por faixa de codigo)


## O que será analisado:
- Basicamente, o acabamento geral da aplicação (tratamento de erros, validações e usabilidade da aplicação)
- A UI pode ser simples, mas tem que ter o mínimo de apresentação visual, como por exemplo, cuidar os "tab orders", 
  alinhar e distribuir bem os componentes na tela e fazer uma apresentação com aparência simples, porém que pareça profissional e 
  bem acabado e não pareça um programa feito por um amador.
- Código Fonte: Organização do fonte, cuidado na hora de nomear elementos, endentação, preocupação com criar 
  Um código que seja de fácil leitura e fácil manutenção, bem modularizado e bem organizado.
- Técnicas de orientação a objetos. O código da aplicação tem que estar todo em classes. Nos Forms deve conter 
  apenas a lógica e funcionalidade que são pertinentes a UI e interação com o usuário. Por exemplo, não coloque regras 
  de validações de campo no form e, sim, nas classes de dados, assim evita que se em outro momento essas validações 
  precisarem ser reutilizadas, não precise copiar e colar o código que está no form. ou se, por exemplo , na hipótese de um dia precisar fazer 
  uma interface WEB para o cadastro, se possa reutilizar o máximo possível do código já escrito nas classes. 
- Não deixe "leaks" de memória. Verificar se o programa está destruindo todos os elementos e instâncias que ele criou.​


## O que não será analisado
- Beleza da aplicação,Design gráfico de UI, uso de ícones, imagens,animações, etc... Apesar de ser importante, não é o foco deste exercício.
- Coisas extras implementadas que não foram solicitadas.
  
## Entrega
o programa deverá ser entregue o executável, que deve abrir sem erros, o fonte zipado. Após a entrega, o programa será analisado e poderei solicitar alterações a fim de avaliar o entendimento do candidato referente ao que foi desenvolvido bem como avaliar como o candidato Responde e recebe críticas ao seu trabalho.

## Prazo: 
O prazo deverá ser calculado pelo candidato antes de iniciar o trabalho e informado.
