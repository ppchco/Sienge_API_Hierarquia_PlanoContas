
---

## src/PLANO_CONTAS.pq

```m
let
    // Consulta à API para obter o Plano de Contas
    Fonte = 
        let
            // Realiza a chamada à API e converte o JSON em registro
            Fonte = Json.Document(
                Web.Contents("https://api.sienge.com.br/{sua-empresa}/public/api/v1/payment-categories")
            )
        in
            Fonte,
    
    // Converte a lista JSON em uma tabela
    #"Convertido para Tabela" = Table.FromList(Fonte, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    
    // Expande a coluna para obter os campos desejados: id, name, tpConta, flRedutora, flAtiva, flAdiantamento e flImposto
    #"Column1 Expandido" = Table.ExpandRecordColumn(
        #"Convertido para Tabela", 
        "Column1", 
        {"id", "name", "tpConta", "flRedutora", "flAtiva", "flAdiantamento", "flImposto"}, 
        {"id", "name", "tpConta", "flRedutora", "flAtiva", "flAdiantamento", "flImposto"}
    ),
    
    // Altera o tipo de dados das colunas para texto
    #"Tipo Alterado" = Table.TransformColumnTypes(
        #"Column1 Expandido",
        {{"id", type text}, {"name", type text}, {"tpConta", type text}, {"flRedutora", type text}, {"flAtiva", type text}, {"flAdiantamento", type text}, {"flImposto", type text}}
    ),
    
    // Adiciona uma coluna que calcula o tamanho do campo 'id'
    #"Personalização Adicionada" = Table.AddColumn(#"Tipo Alterado", "textLenght", each Text.Length([id])),
    
    // Cria a coluna 'Total Geral' para formatação dos registros com id de tamanho 1
    #"Personalização Adicionada1" = Table.AddColumn(
        #"Personalização Adicionada", 
        "Total Geral", 
        each if [textLenght] = 1 then [id] & " - " & [name] else null
    ),
    
    // Substitui valores específicos na coluna 'Total Geral' para padronização dos rótulos
    #"Valor Substituído" = Table.ReplaceValue(
        #"Personalização Adicionada1",
        "2 - SAÍDAS/CUSTOS/DESPESAS",
        "2 - SAÍDAS",
        Replacer.ReplaceText,
        {"Total Geral"}
    ),
    #"Valor Substituído1" = Table.ReplaceValue(
        #"Valor Substituído",
        "1 - ENTRADAS/RECEITAS",
        "1 - ENTRADAS",
        Replacer.ReplaceText,
        {"Total Geral"}
    ),
    
    // Ordena as linhas pela coluna 'id' de forma ascendente
    #"Linhas Classificadas" = Table.Sort(#"Valor Substituído1", {{"id", Order.Ascending}}),
    
    // Preenche para baixo os valores da coluna 'Total Geral'
    #"Preenchido Abaixo" = Table.FillDown(#"Linhas Classificadas", {"Total Geral"}),
    
    // Adiciona uma coluna personalizada 'i.d' para formatar o id com pontos, conforme o tamanho do mesmo
    #"Coluna Personalizada Adicionada" = Table.AddColumn(
        #"Preenchido Abaixo", 
        "i.d", 
        each 
            if [textLenght] = 1 then [id] 
            else if [textLenght] = 3 then Text.Combine({Text.Start([id], 1), ".", Text.Middle([id], 1, 2)}) 
            else if [textLenght] = 5 then Text.Combine({Text.Start([id], 1), ".", Text.Middle([id], 1, 2), ".", Text.Middle([id], 3)}) 
            else if [textLenght] = 7 then Text.Combine({Text.Start([id], 1), ".", Text.Middle([id], 1, 2), ".", Text.Middle([id], 3, 2), ".", Text.Middle([id], 5)}) 
            else Text.Combine({Text.Start([id], 1), ".", Text.Middle([id], 1, 2), ".", Text.Middle([id], 3, 2), ".", Text.Middle([id], 5, 2), ".", Text.Middle([id], 7)})
    ),
    
    // Cria colunas 'Total 1', 'Total 2' e 'Total 3' conforme o tamanho do 'id'
    #"Personalização Adicionada2" = Table.AddColumn(
        #"Coluna Personalizada Adicionada", 
        "Total 1", 
        each if [textLenght] <= 3 then [i.d] & " - " & [name] else null
    ),
    #"Personalização Adicionada3" = Table.AddColumn(
        #"Personalização Adicionada2", 
        "Total 2", 
        each if [textLenght] <= 5 then [i.d] & " - " & [name] else null
    ),
    #"Personalização Adicionada4" = Table.AddColumn(
        #"Personalização Adicionada3", 
        "Total 3", 
        each if [textLenght] <= 7 then [i.d] & " - " & [name] else null
    ),
    
    // Preenche para baixo os valores nas colunas 'Total 1', 'Total 2' e 'Total 3'
    #"Preenchido Abaixo1" = Table.FillDown(#"Personalização Adicionada4", {"Total 1", "Total 2", "Total 3"}),
    
    // Filtra as linhas para manter apenas os registros onde 'tpConta' é "R"
    #"Linhas Filtradas" = Table.SelectRows(#"Preenchido Abaixo1", each ([tpConta] = "R")),
    
    // Remove colunas que não serão utilizadas nas análises
    #"Colunas Removidas" = Table.RemoveColumns(#"Linhas Filtradas", {"tpConta", "flAtiva", "flAdiantamento", "flImposto", "textLenght"}),
    
    // Cria a coluna 'Resultado' concatenando o id formatado com o name
    #"Personalização Adicionada5" = Table.AddColumn(
        #"Colunas Removidas", 
        "Resultado", 
        each [i.d] & " - " & [name]
    ),
    
    // Renomeia a coluna 'flRedutora' para 'redutora'
    #"Colunas Renomeadas" = Table.RenameColumns(#"Personalização Adicionada5", {{"flRedutora", "redutora"}}),
    
    // Cria a coluna 'Total.red' removendo números e símbolos da coluna 'Total 1'
    #"Personalização Adicionada6" = Table.AddColumn(
        #"Colunas Renomeadas", 
        "Total.red", 
        each Text.Trim(Text.Remove([Total 1], {"0".."9", "(", ")", "-", "."}))
    ),
    
    // Cria a coluna 'Total 4' copiando o valor da coluna 'Total 3'
    #"Personalização Adicionada7" = Table.AddColumn(
        #"Personalização Adicionada6", 
        "Total 4", 
        each [Total 3]
    ),
    
    // Cria a coluna 'id-name' concatenando 'id' e 'name'
    #"Personalização Adicionada8" = Table.AddColumn(
        #"Personalização Adicionada7", 
        "id-name", 
        each [id] & " - " & [name]
    ),
    
    // Ajusta os tipos das colunas para texto
    #"Tipo Alterado1" = Table.TransformColumnTypes(
        #"Personalização Adicionada8",
        {
            {"id", type text}, {"Total Geral", type text}, {"i.d", type text}, {"Total 1", type text},
            {"Total 2", type text}, {"Total 3", type text}, {"Resultado", type text},
            {"Total.red", type text}, {"Total 4", type text}, {"id-name", type text}
        }
    ),
    
    // Renomeia a coluna 'id-name' para 'Conta sem ponto - Descrição'
    #"Colunas Renomeadas1" = Table.RenameColumns(#"Tipo Alterado1", {{"id-name", "Conta sem ponto - Descrição"}})
in
    #"Colunas Renomeadas1"
