-- Insere o grande volume do CSV pela opção TEXT IMPORTER do PLSQL, pois sera mais rapido
-- Tabela NAGT_FALC_ALTPRODEMPRESA

DECLARE 
    i INTEGER := 0;
    total INTEGER := 0;
    /* Criei para registrar o log do loop enquanto está executando */
    /* Pode consultar na tabela GLN_LOG_PROCESSO_LOOP o andamento */
    PROCEDURE ATUALIZAR_LOG(p_total NUMBER) IS
    PRAGMA AUTONOMOUS_TRANSACTION; -- acho que nao precisa mas ta ai
    
    BEGIN
        MERGE INTO GLN_LOG_PROCESSO_LOOP L
        USING (SELECT 'TOTAL_ALTERADO' AS ID FROM DUAL) D
        ON (L.MENSAGEM = D.ID)
        WHEN MATCHED THEN 
            UPDATE SET L.DATA_LOG = SYSTIMESTAMP, L.TOTAL = p_total
        WHEN NOT MATCHED THEN 
            INSERT (MENSAGEM, DATA_LOG, TOTAL) 
            VALUES ('TOTAL_ALTERADO', SYSTIMESTAMP, p_total);

        COMMIT;
    END ATUALIZAR_LOG;
    /*******/
    
BEGIN
    FOR rec IN (SELECT A.* FROM NAGT_FALC_ALTPRODEMPRESA A INNER JOIN MRL_PRODUTOEMPRESA E ON E.SEQPRODUTO = A.SEQPRODUTO AND A.NROEMPRESA = E.NROEMPRESA
                  WHERE A.FORMA != NVL(E.FORMAARREDSUGABAST, 'X'))
    LOOP
        i := i + 1;
        total := total + 1;
        
       UPDATE MRL_PRODUTOEMPRESA X SET X.FORMAARREDSUGABAST = rec.FORMA
                                 WHERE X.SEQPRODUTO = rec.Seqproduto
                                   AND X.NROEMPRESA = rec.NROEMPRESA ;
        
        IF i = 1000 THEN -- Define o Commit por quantidade de linhas
            COMMIT;
            ATUALIZAR_LOG(total);  -- Atualiza o total no log
            i := 0;
        END IF;
    END LOOP;

    COMMIT;
    ATUALIZAR_LOG(total); -- Atualiza o total final
END;
