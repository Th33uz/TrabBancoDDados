/* 1) Trigger para Validação de Datas */

CREATE TRIGGER tr_validar_datas
BEFORE INSERT OR UPDATE ON pacote
FOR EACH ROW
BEGIN
  IF NEW.dtf_pacote < NEW.dti_pacote THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A data de encerramento deve ser maior ou igual à data de início do pacote';
  END IF;
END;

/*2) Função para Calcular a Quantidade de Dias*/

CREATE FUNCTION getQtdDias(data_inicio DATE, data_fim DATE)
RETURNS INTEGER
BEGIN
  IF data_fim < data_inicio THEN
    RETURN -1;
  ELSE
    RETURN DATEDIFF(data_fim, data_inicio);
  END IF;
END;


/* 3) */

CREATE PROCEDURE sp_listar_pacotes_por_hotel_e_cidade(IN p_cod_hotel INT, IN p_cod_cidade_destino INT)
BEGIN
  SELECT 
    p.num_pacote,
    h.nom_hotel,
    p.dti_pacote,
    p.dtf_pacote,
    getQtdDias(p.dti_pacote, p.dtf_pacote) AS qtd_dias,
    p.vir_pacote,
    co.nom_cidade AS cidade_origem,
    cd.nom_cidade AS cidade_destino
  FROM pacote p
  INNER JOIN hotel h ON p.cod_hotel = h.cod_hotel
  INNER JOIN cidade co ON p.cod_cidadeorig = co.cod_cidade
  INNER JOIN cidade cd ON p.cod_cidadedest = cd.cod_cidade
  WHERE h.cod_hotel = p_cod_hotel AND cd.cod_cidade = p_cod_cidade_destino;
END;



/* 4) */

CREATE PROCEDURE updatePacote(IN p_cod_pacote INT, IN p_percentual DECIMAL(5,2))
BEGIN
  UPDATE pacote
  SET vir_pacote = vir_pacote * (1 + p_percentual / 100)
  WHERE num_pacote = p_cod_pacote;
END;
