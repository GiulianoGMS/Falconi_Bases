CREATE OR REPLACE VIEW NAGV_FALCONI_EXTVENDA_BASE56 AS
SELECT ANO,
             MES,
             TO_CHAR(DATA,'DD/MM/YYYY') DATA,
             SEGMENTO,
             LOJA,
             SEQPRODUTO,
             PRODUTO,
             nvl(sum(VLR_VENDA),0) VLR_VENDA,
             nvl(sum(QTD_VENDA),0) QTD_VENDA,
             nvl(sum(VLR_COMPRA),0) VLR_COMPRA,
             nvl(sum(QTD_COMPRA),0) QTD_COMPRA,
             case when nvl(sum(VLR_VENDA),0) = 0 then 0 else trunc(((nvl(sum(VLR_VENDA),0) - (NVL(SUM(CUSTO_BRUTO),0)))/nvl(sum(VLR_VENDA),0))*100,2)   end MarkDown,
              ROUND(SUM(NVL(LUCRATIVIDADE,0)),2) LUCRATIVIDADE,
              sum(vlr_promocao) VLR_PROMOCAO,
              DATA DATA_FILTRO
FROM(
select to_char(x.dtaoperacao,'YYYY') ANO,
           to_char(x.dtaoperacao,'MM') MES,
          x.dtaoperacao DATA,
          DECODE(X.NROSEGMENTO,5,'E-commerce',8,'E-commerce','Loja') SEGMENTO,
           X.NROEMPRESA LOJA,
           X.SEQPRODUTO SEQPRODUTO,
           y.produto PRODUTO,
           sum(x.vlroperacao) VLR_VENDA,
           null VLR_COMPRA,
           sum(x.qtdoperacao) QTD_VENDA,
           null QTD_COMPRA,
           SUM(X.vvlrctobruto) CUSTO_BRUTO,
           SUM( X.vlroperacao  - X.vvlrctoliquido  - X.vvlrimpostosaida - nvl( X.vlrdespoperacionalitem, 0 )  - X.vlrcomissao  - X.vlrverbacompra  - X.vlrcalcimpostovda     )  LUCRATIVIDADE,
            SUM(x.vlrpromoc) vlr_promocao
from fatog_vendadia x inner join dim_produto y on (x.seqproduto = y.seqproduto)
where x.codgeraloper in (37,48,123,610,615,613,810,916,910,911,76)
GROUP BY to_char(x.dtaoperacao,'MM') ,
           to_char(x.dtaoperacao,'YYYY'),
           X.NROEMPRESA ,X.NROSEGMENTO,
           X.SEQPRODUTO ,
           y.produto,
  x.dtaoperacao

union all

select to_char(x.Dtaentrada,'YYYY') ANO,
           to_char(x.Dtaentrada,'MM') MES,
           X.DTAENTRADA DATA,
          'Loja' SEGMENTO,
           X.NROEMPRESA LOJA,
           X.SEQPRODUTO SEQPRODUTO,
           y.produto PRODUTO,
           null,
           sum(x.vlritem + x.vlripi + x.vlrdespforanf + x.vlrdesptributitem + x.vlricmsst + x.vlrfcpst - x.vlrdescitem) VLR_COMPRA,
           null,
           sum(x.qtditem) QTD_COMPRA,
           NULL,
           NULL,
           null
from fato_compra x inner join dim_produto y on (x.seqproduto = y.seqproduto)
where x.codgeraloper in (1,121,200,900,928)
GROUP BY to_char(x.Dtaentrada,'MM') ,
           to_char(x.Dtaentrada,'YYYY'),
           X.NROEMPRESA ,
           X.SEQPRODUTO ,
           y.produto,
            X.DTAENTRADA )
group by  ANO, MES, DATA,LOJA, SEQPRODUTO, PRODUTO,SEGMENTO;
