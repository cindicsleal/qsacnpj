#' @title Função que orquestra as demais funções para realizar o tratamento e organização dos dados do CNPJ
#'
#' @description Essa função foi desenvolvida utilizando como elementro central uma função complementar
#' chamada 'readr::read_lines_chunked', com o propósito de ler o arquivo de 95Gb em partes de
#' 10.000, 100.000 ou 1.000.000 de linhas por vez.
#'
#' @param path_arquivos_txt Caminho (path) dos arquivos com a base de dados do CNPJ.
#' @param localizar_cnpj Vetor com o número dos CNPJ que se deseja filtrar e obter os dados.
#' O valor padrão é "NAO", o que força ao tratamento de todas as linha da base de dados
#' @param n_lines Número de linhas que podem ser iteradas por vez: 10000, 100000 ou 1000000
#' @param armazenar Indica a forma de armazenamento dos dados: 'csv' ou 'sqlite' (OBS1: O delimitador do CSV é o simbolo: "#'),
#'  (OBS2: Preferencialmente, defina a pasta de trabalho da sessão 'Working Directory' na mesma em que estão localizados os arquivos
#' da base de dados no CNPJ)
#'
#' @examples
#' \dontrun{
#' qsacnpj::gerar_bd_cnpj(path_arquivos_txt = "D:/qsa_cnpj",
#'                        localizar_cnpj = "NAO",
#'                        n_lines = 100000,
#'                        armazenar = "csv")
#'
#'
#'# Exemplo com número de CNPJ, entre aspas (""), do Banco do Brasil, Banco do Nordeste,
#'# Banco da Amazônia e Caixa Econômica
#'
#' qsacnpj::gerar_bd_cnpj(path_arquivos_txt = "D:/qsa_cnpj",
#'                        localizar_cnpj = c("00000000000191", "07237373000120",
#'                                             "00360305000104", "04902979000144"),
#'                        n_lines = 100000,
#'                        armazenar = "sqlite")
#'}
#'
#'
#' @export

gerar_bd_cnpj <- function(path_arquivos_txt,
                          localizar_cnpj = "NAO",
                          n_lines = 100000,
                          armazenar = "csv") {


        path_arquivos_txt <- dir(path_arquivos_txt)


        if(is.null(path_arquivos_txt)) {

                stop("Defina o caminho (path) do arquivo da base de dados do CNPJ")
        }


        #!!! Criar uma função para verificar se os CNPJ na variável 'localizar_cnpj' são válidos

        if(!n_lines %in% c(10000, 100000, 1000000)) {

                stop("Escolha a opção 10000, 100000 ou 1000000 para a quantidade de linhas a serem analisadas por vez!")

        }

        if(!armazenar %in% c("csv", "sqlite", "sqlserver", "oracle", "mysql")) {

                stop("Escolha a opção 'csv', 'sqlite', 'sqlserver', 'oracle' ou 'mysql' para armazenar os dados!")
        }

        if(dir.exists("bd_cnpj_tratados") == FALSE){

                dir.create("bd_cnpj_tratados")

                print("Pasta 'bd_cnpj_tratados' criada com sucesso!")

        }

        if (file.exists(file.path("bd_cnpj_tratados", "bd_dados_qsa_cnpj.db"))){

                stop(paste("O arquivo 'bd_dados_qsa_cnpj.db' já existe no diretório 'bd_cnpj_tratados'.",
                           "Para realizar a primeira execução do código com o SQLite, é preciso apagar ou mover o arquivo do diretório."))

        }

        if (file.exists(file.path("bd_cnpj_tratados", "cnpj_dados_cadastrais_pj.csv"))) {

                stop(paste("O arquivo 'cnpj_dados_cadastrais_pj.csv' já existe no diretório 'bd_cnpj_tratados'.",
                           "Para realizar a primeira execução do código com CSV, é preciso apagar ou mover o arquivo do diretório."))

        }


                print(paste("Iniciando o tratamento e consolidação dos dados do CNPJ.",
                      "Esse processo pode levar entre 4h a 5h, dependenndo da configuração do computador!"))


        obter_dados_qsa(path_arquivos_txt,
                        localizar_cnpj,
                        n_lines,
                        armazenar)

                print(paste("Base de Dados do CNPJ gerada com Sucesso! Tabelas geradas:",
                      "`dados_cadastrais_pj`, `dados_socios_pj` e `dados_cnae_secundario_pj`"))


                print("Adicionando na base a tabela com dados dos Entes Públicos Federais, Estaduais e Municipais!")

        obter_dados_cnpj_entes_publicos(armazenar)

                print("Tabela `tab_cnpj_entes_publicos_br` gerada com Sucesso!")


                print("Adicionando na base a tabela com Código e Nome da Qualificação dos Responsáveis!")

        obter_dados_qualificacao_responsavel(armazenar)

                print("Tabela `tab_qualificacao_responsavel_socio` gerada com Sucesso!")


                print("Adicionando na base a tabela com Código e Nome da Situação Cadastral!")

        obter_dados_situacao_cadastral(armazenar)

                print("Tabela `tab_situacao_cadastral` gerada com Sucesso!")


                print("Adicionando na base a tabela com Código e Nome da Natureza Jurídica!")

        obter_dados_natureza_juridica(armazenar)

                print("Tabela `tab_natureza_juridica` gerada com Sucesso!")


                print("Adicionando na base a tabela com os CNAEs!")

        obter_dados_cnae(armazenar)

                print("Tabela `tab_cnae` gerada com Sucesso!")

                print("Adicionando na base a tabela com os Códigos dos Municípios do SIAFI-IBGE!")

        obter_dados_codigo_municipios_siafi(armazenar)

        print("Tabela `codigo_municipios_siafi` gerada com Sucesso!")


        message("Fim do Processamento: Base de Dados do CNPJ gerada com Sucesso!")

}
