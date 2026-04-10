CREATE OR REPLACE VIEW NAGV_FALCONI_EXTESTOQUE_BASE01 AS

select to_char(x.dtaestoque,'DD/MM/YYYY') DATA,
       x.seqproduto SEQPRODUTO,
       y.produto PRODUTO,
       z.categorian1 CATEGORIA_NVL_01,
       z.categorian2 CATEGORIA_NVL_02,
       z.categorian3 CATEGORIA_NVL_03,
       z.categorian4 CATEGORIA_NVL_04,
       z.categorian5 CATEGORIA_NVL_05,
       to_char(sum(x.qtdestoque),'FM999G999G999D90', 'NLS_NUMERIC_CHARACTERS='',.''') QTD_ESTOQUE,
       to_char(sum(x.qtdestqloja),'FM999G999G999D90', 'NLS_NUMERIC_CHARACTERS='',.''') ESTOQUE_LOJA,
       to_char(sum(x.qtdestqdeposito),'FM999G999G999D90', 'NLS_NUMERIC_CHARACTERS='',.''') ESTOQUE_DEPOSITO,
       to_char(sum(x.qtdestqtroca),'FM999G999G999D90', 'NLS_NUMERIC_CHARACTERS='',.''') ESTOQUE_TROCA,
       to_char(sum(x.qtdestqalmoxarifado),'FM999G999G999D90', 'NLS_NUMERIC_CHARACTERS='',.''') ESTOQUE_ALMOXARIFADO,
       to_char(sum(x.qtdestqoutro),'FM999G999G999D90', 'NLS_NUMERIC_CHARACTERS='',.''') ESTOQUE_OUTROS,
       to_char(sum(x.qtdestqterceiro),'FM999G999G999D90', 'NLS_NUMERIC_CHARACTERS='',.''') ESTOQUE_TERECEIROS,
       to_char(sum(X.qtdestoque*x.vlrctobruto),'FM999G999G999D90', 'NLS_NUMERIC_CHARACTERS='',.''')  VLR_ESTOQUE,
        to_char(sum(x.qtdestqloja*x.vlrctobruto),'FM999G999G999D90', 'NLS_NUMERIC_CHARACTERS='',.''') VLR_ESTOQUE_LOJA,
        to_char(sum(x.qtdestqdeposito*x.vlrctobruto),'FM999G999G999D90', 'NLS_NUMERIC_CHARACTERS='',.''') VLR_ESTOQUE_DEPOSITO,
        to_char(sum(x.qtdestqtroca*x.vlrctobruto),'FM999G999G999D90', 'NLS_NUMERIC_CHARACTERS='',.''') VLR_ESTOQUE_TROCA,
        to_char(sum(x.qtdestqalmoxarifado*x.vlrctobruto),'FM999G999G999D90', 'NLS_NUMERIC_CHARACTERS='',.''') VLR_ESTOQUE_ALMOXARIFADO,
          to_char(sum(x.qtdestqoutro*x.vlrctobruto),'FM999G999G999D90', 'NLS_NUMERIC_CHARACTERS='',.''') VLR_ESTOQUE_OUTROS,
        to_char(sum(x.qtdestqterceiro*x.vlrctobruto),'FM999G999G999D90', 'NLS_NUMERIC_CHARACTERS='',.''') ESTOQUE_TERECEIROS_VLR,
        x.dtaestoque DTAFILTRO
        
  from fato_estoque@bi x inner join dim_produto@bi y on (x.seqproduto = y.seqproduto)
                                              inner join dim_categoria@bi z  on (y.seqfamilia = z.seqfamilia)
 where 1=1
 and x.qtdestoque <>  0 
 group by to_char(x.dtaestoque,'DD/MM/YYYY') ,
       x.seqproduto ,
       y.produto ,
       z.categorian1 ,
       z.categorian2 ,
       z.categorian3 ,
       z.categorian4 ,
       z.categorian5 , dtaestoque
