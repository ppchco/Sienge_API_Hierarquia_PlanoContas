# Transformação do Plano de Contas do SIENGE em Hierarquia com Power Query

Este projeto contém um script Power Query para transformar o Plano de Contas obtido da API do SIENGE em um formato adequado para análises de BI estrutrando o Plano de Contas em uma hierarquia de contas, para gerar relatórios e análises de dados financeiros.

# Sienge API – Transformação do Plano de Contas para Tabela Dinâmica

Este projeto demonstra como consumir os dados do Plano de Contas de um CRM SaaS (SIENGE) via API REST e transformá-los, por meio do Power Query (M), para um formato adequado à utilização em Tabelas Dinâmicas e análises de BI.

## Etapas do Processo

1. **Consulta à API:**
   - Utiliza `Web.Contents` e `Json.Document` para obter os dados da API.
   - A URL base é:  
     `https://api.sienge.com.br/{sua-empresa}/public/api/v1/payment-categories`  
     **Atenção:** Substitua `{sua-empresa}` pelo identificador da sua empresa.

2. **Conversão para Tabela:**
   - O resultado JSON é convertido para uma tabela usando `Table.FromList`.

3. **Expansão dos Registros:**
   - Expande a coluna contendo os registros para revelar os campos: `id`, `name`, `tpConta`, `flRedutora`, `flAtiva`, `flAdiantamento` e `flImposto`.

4. **Ajuste de Tipos:**
   - Altera os tipos de dados das colunas para texto, garantindo consistência na manipulação.

5. **Criação de Colunas Auxiliares e Transformações:**
   - **Cálculo do tamanho do `id`:** Cria a coluna `textLenght` para auxiliar na formatação.
   - **Formatação de descrição:** A coluna `Total Geral` é criada para formatar o `id` e o `name` quando o `id` tem tamanho 1.
   - **Substituições de valores:** Ajusta rótulos para "SAÍDAS" e "ENTRADAS".
   - **Ordenação e Preenchimento:** Ordena os registros por `id` e preenche valores faltantes (com `Table.FillDown`) para que os dados se propaguem conforme necessário.
   - **Formatação dos IDs:** Cria a coluna `i.d` que formata o `id` com pontos, conforme seu tamanho (diferentes formatos para tamanhos 1, 3, 5, 7 ou maiores).
   - **Criação de colunas 'Total 1', 'Total 2' e 'Total 3':** Dependendo do tamanho do `id`, são geradas colunas que combinam o `i.d` com o `name`.
   - **Filtragem:** Mantém somente os registros em que `tpConta` é "R" (contas de resultado, por exemplo).
   - **Remoção e Renomeação:** Remove colunas que não são necessárias e renomeia outras para melhor clareza.
   - **Criação de colunas finais:** Gera colunas como `Resultado (completa)`, `#total1.reduz`, `Total 4` e `Conta sem ponto - Descrição` para serem utilizadas nas análises.

6. **Resultado Final:**
   - Ao final, o script retorna uma tabela transformada que pode ser facilmente utilizada em Tabelas Dinâmicas e demais relatórios de BI.

## Código Power Query

O arquivo [PlanoContasTransformacao.pq](src/PLANO_CONTAS.pq) contém o script completo comentado.

---