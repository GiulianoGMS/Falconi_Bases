CREATE OR REPLACE PROCEDURE NAGP_FALCONI_EXT_VENDAS_BASE56 (vsDtaInicial DATE, vsDtaFinal DATE) IS

    v_file UTL_FILE.file_type;
    v_line VARCHAR2(32767);
    v_Cabecalho VARCHAR2(4000);
    v_buffer CLOB;
    v_chunk_size CONSTANT PLS_INTEGER := 32000;
    v_varcsv VARCHAR2(400);
    v_dtini DATE;
    v_dtfim DATE;
    v_dir   VARCHAR2(4000);
    v_name  VARCHAR2(3000);

BEGIN
   
    -- Abre o arquivo para escrita
    v_file := UTL_FILE.fopen('FALCONI', 'Ext_Falconi_Vendas.csv', 'w', 32767); 

    -- Pega o nome das colunas para inserir no cabecalho pq tenho preguica
   SELECT LISTAGG(COLUMN_NAME,';') WITHIN GROUP (ORDER BY COLUMN_ID)-- ||';DATA'
      INTO v_Cabecalho
      FROM ALL_TAB_COLUMNS A
     WHERE A.table_name = 'NAGV_FALCONI_EXTVENDA_BASE56'
       AND A.column_name != 'DATA_FILTRO';

    -- Escreve o cabe¿alho do CSV
    UTL_FILE.put_line(v_file, v_Cabecalho);

    -- Executa a query e escreve os resultados

      FOR vda IN (SELECT X.ANO,
       X.MES,
       X.DATA,
       X.SEGMENTO,
       X.LOJA,
       X.SEQPRODUTO,
       X.PRODUTO,
       X.VLR_VENDA,
       X.QTD_VENDA,
       X.VLR_COMPRA,
       X.QTD_COMPRA,
       X.MarkDown,
       X.LUCRATIVIDADE,
       X.vlr_promocao FROM NAGV_FALCONI_EXTVENDA_BASE56 X WHERE X.DATA_FILTRO BETWEEN vsDtaInicial AND vsDtaFinal)

      LOOP

       v_line := vda.ANO||';'||
                 vda.MES||';'||
                 vda.DATA||';'||
                 vda.SEGMENTO||';'||
                 vda.LOJA||';'||
                 vda.SEQPRODUTO||';'||
                 vda.PRODUTO||';'||
                 vda.VLR_VENDA||';'||
                 vda.QTD_VENDA||';'||
                 vda.VLR_COMPRA||';'||
                 vda.QTD_COMPRA||';'||
                 vda.MarkDown||';'||
                 vda.LUCRATIVIDADE||';'||
                 vda.vlr_promocao||';';

        v_buffer := v_buffer || v_line || CHR(10); -- Adiciona nova linha ao buffer
        
        IF LENGTH(v_buffer) > v_chunk_size THEN
            UTL_FILE.put_line(v_file, v_buffer); -- Escreve o buffer no arquivo
            v_buffer := ''; -- Limpe o buffer
            
        END IF;
        
    END LOOP;
    
    -- Grava o restante do buffer no final (burro esqueceu)
    IF v_buffer IS NOT NULL THEN
        UTL_FILE.put_line(v_file, v_buffer);
        v_buffer := '';
    END IF;
    
    -- Fecha o arquivo
    UTL_FILE.fclose(v_file);

EXCEPTION

    WHEN OTHERS THEN
        IF UTL_FILE.is_open(v_file) THEN
            UTL_FILE.fclose(v_file);
        END IF;

END;
