CREATE OR REPLACE PROCEDURE NAGP_FALCONI_EXT_EST_BASE01 (vsDtaInicial DATE, vsDtaFinal DATE) IS

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
    v_file := UTL_FILE.fopen('FALCONI', 'Ext_Falconi_Estoque.csv', 'w', 32767); 

    -- Pega o nome das colunas para inserir no cabecalho pq tenho preguica
   SELECT LISTAGG(COLUMN_NAME,';') WITHIN GROUP (ORDER BY COLUMN_ID)-- ||';DATA'
      INTO v_Cabecalho
      FROM ALL_TAB_COLUMNS A
     WHERE A.table_name = 'NAGV_FALCONI_EXTESTOQUE_BASE01'
       AND A.column_name != 'DTAFILTRO';

    -- Escreve o cabe¿alho do CSV
    UTL_FILE.put_line(v_file, v_Cabecalho);

    -- Executa a query e escreve os resultados

      FOR vda IN (SELECT X.DATA,
         X.seqproduto,
         X.produto,
         X.CATEGORIA_NVL_01,
         X.CATEGORIA_NVL_02,
         X.CATEGORIA_NVL_03,
         X.CATEGORIA_NVL_04,
         X.CATEGORIA_NVL_05,
         X.QTD_ESTOQUE,
         X.ESTOQUE_LOJA,
         X.ESTOQUE_DEPOSITO,
         X.ESTOQUE_TROCA,
         X.ESTOQUE_ALMOXARIFADO,
         X.ESTOQUE_OUTROS,
         X.ESTOQUE_TERECEIROS,
         X.VLR_ESTOQUE,
         X.VLR_ESTOQUE_LOJA,
         X.VLR_ESTOQUE_DEPOSITO,
         X.VLR_ESTOQUE_TROCA,
         X.VLR_ESTOQUE_ALMOXARIFADO,
         X.VLR_ESTOQUE_OUTROS,
         X.ESTOQUE_TERECEIROS_VLR FROM NAGV_FALCONI_EXTESTOQUE_BASE01 X WHERE X.DTAFILTRO BETWEEN vsDtaInicial AND vsDtaFinal)

      LOOP

       v_line := vda.DATA||';'||
         vda.seqproduto||';'||
         vda.produto||';'||
         vda.CATEGORIA_NVL_01||';'||
         vda.CATEGORIA_NVL_02||';'||
         vda.CATEGORIA_NVL_03||';'||
         vda.CATEGORIA_NVL_04||';'||
         vda.CATEGORIA_NVL_05||';'||
         vda.QTD_ESTOQUE||';'||
         vda.ESTOQUE_LOJA||';'||
         vda.ESTOQUE_DEPOSITO||';'||
         vda.ESTOQUE_TROCA||';'||
         vda.ESTOQUE_ALMOXARIFADO||';'||
         vda.ESTOQUE_OUTROS||';'||
         vda.ESTOQUE_TERECEIROS||';'||
         vda.VLR_ESTOQUE||';'||
         vda.VLR_ESTOQUE_LOJA||';'||
         vda.VLR_ESTOQUE_DEPOSITO||';'||
         vda.VLR_ESTOQUE_TROCA||';'||
         vda.VLR_ESTOQUE_ALMOXARIFADO||';'||
         vda.VLR_ESTOQUE_OUTROS||';'||
         vda.ESTOQUE_TERECEIROS_VLR||';';

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
