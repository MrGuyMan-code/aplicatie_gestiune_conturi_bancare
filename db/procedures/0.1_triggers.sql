USE sistem_bancar_db;

DROP PROCEDURE IF EXISTS sp_conturi_active_client;

DELIMITER $$

CREATE PROCEDURE sp_conturi_active_client(IN p_client_id BIGINT UNSIGNED)
BEGIN
    SELECT
        a.id            AS account_id,
        a.iban          AS iban,
        a.currency      AS valuta,
        a.balance       AS balanta,
        a.account_type  AS tip_cont,
        a.opened_at     AS deschis_la
    FROM accounts a
    WHERE a.client_id = p_client_id
      AND a.status    = 'ACTIVE'
    ORDER BY a.currency, a.opened_at;
END$$

DELIMITER ;
