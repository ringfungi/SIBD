create or replace PACKAGE BODY pkg_condominio IS

-- Cria o novo registo de um proprietário 
PROCEDURE regista_proprietario (
    nif_in     IN proprietario.nif%TYPE,
    nome_in    IN proprietario.nome%TYPE,
    genero_in  IN proprietario.genero%TYPE,
    piso_in    IN proprietario.piso%TYPE,
    letra_in   IN proprietario.letra%TYPE)
IS
BEGIN
INSERT INTO proprietario (nif, nome, genero, piso, letra)
     VALUES (nif_in, nome_in, genero_in, piso_in, letra_in);
     
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
       RAISE_APPLICATION_ERROR(-20001, 'Só pode ser registado um proprietario por apartamento');

    WHEN OTHERS THEN RAISE;
END regista_proprietario;

/*---------------------------------------------------------------------------------------*/

-- Cria o novo registo de um administrador, dados um proprietário do prédio e o ano em que é administrador
PROCEDURE regista_administrador(
    proprietario_in  IN administra.proprietario%TYPE,
    ano_in           IN administra.ano%TYPE)
IS
   prop_counter NUMBER(1) := 0;   
BEGIN
    SELECT COUNT(A.ano) INTO prop_counter FROM administra A WHERE A.ANO = ano_in;    -- Verfica quantos administradores já existem para o ano inserido

    IF (prop_counter >= 2) THEN        -- Caso já haja dois ou mais, retorna um erro. Caso contrário, faz a inserção
      RAISE_APPLICATION_ERROR(-20003,   -- Código definido pelo programador.
                              'Não podem existir mais do que dois administradores por ano.');
    ELSE  
      INSERT INTO administra (proprietario, ano)
      VALUES (proprietario_in, ano_in);
    END IF;

END regista_administrador;

/*---------------------------------------------------------------------------------------*/

-- Cria o novo registo de um contrato e devolve o número sequencial do contrato criado
FUNCTION regista_contrato(                       
empresa_in      IN contrato.empresa%TYPE,
equipamento_in  IN contrato.equipamento%TYPE,
ano_in          IN contrato.ano%TYPE,
euros_in        IN contrato.euros%TYPE)
RETURN contrato.numero%TYPE

IS
nContratos_ano NUMBER;
nContrato NUMBER;
BEGIN
 
  SELECT MAX(numero) INTO nContrato
      FROM contrato;
      IF(nContrato IS NULL) THEN
         nContrato := 1;
      ELSE
         nContrato := nContrato + 1;
      END IF;
  SELECT COUNT (*) INTO nContratos_ano FROM contrato WHERE ano = ano_in AND equipamento = equipamento_in;
  IF nContratos_ano <> 0 THEN
    RAISE_APPLICATION_ERROR(-20666,'Já existe um contrato para este equipamento!');
  ELSE
    INSERT INTO contrato VALUES (nContrato,empresa_in,equipamento_in,ano_in,euros_in);
  END IF;
  RETURN nContrato;
END regista_contrato;

/*---------------------------------------------------------------------------------------*/

-- Cria o novo registo de uma autorizacao de um contrato por parte de um administrador em dado ano
PROCEDURE regista_autorizacao(                   
  administrador_in IN AUTORIZA.ADMINISTRADOR%TYPE,
  ano_in IN AUTORIZA.ANO%TYPE,
  contrato_in IN AUTORIZA.CONTRATO%TYPE)
IS
   nif_admin INT := 0;
   ano_admin INT := 0;
BEGIN
  SELECT DISTINCT A.proprietario, A.ano INTO nif_admin, ano_admin FROM administra A WHERE A.proprietario = administrador_in AND A.ano = ano_in;
  -- O primeiro select faz simultaneamente a verificação da existência do administrador e do par administrador/ano
  ano_admin := 0;
  SELECT COUNT (ano) INTO ano_admin FROM contrato C WHERE C.ano = ano_in AND C.numero = contrato_in;
  -- O segundo select verifica se o ano introduzido é igual ao que consta no contrato
  IF ano_admin = 0 THEN
        RAISE_APPLICATION_ERROR(-20668,'Ano que consta no contrato diferente do ano indicado!');
  ELSE
    INSERT INTO autoriza (administrador, ano, contrato)
     VALUES (administrador_in, ano_in, contrato_in);
  END IF;

  EXCEPTION WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20667,'Administrador e/ou par administrador/ano inexistente!');
END regista_autorizacao;


/*---------------------------------------------------------------------------------------*/

-- Remove uma autorização dada por um administrador num determinado ano e contrato
PROCEDURE remove_autorizacao (
  administrador_in IN autoriza.administrador%TYPE,
  ano_in IN autoriza.ano%TYPE,
  contrato_in IN autoriza.contrato%TYPE)
IS
BEGIN
    DELETE FROM autoriza WHERE (contrato = contrato_in) AND (administrador = administrador_in) AND (ano = ano_in);
    EXCEPTION
        WHEN OTHERS THEN RAISE;
END remove_autorizacao;

/*---------------------------------------------------------------------------------------*/

-- Remove um contrato e as suas autorizações associadas
PROCEDURE remove_contrato (
    numero_in IN contrato.numero%TYPE)
IS
      TYPE tab_local_aut IS TABLE OF autoriza%ROWTYPE;    -- Tabela local (nested table) para a qual se movem todas linhas da tabela autoriza cujo número
      autorizacoes tab_local_aut;                         -- de contrato é igual ao introduzido.
BEGIN

    SELECT * BULK COLLECT INTO autorizacoes FROM autoriza A WHERE A.contrato = numero_in;

    IF (autorizacoes.COUNT > 0) THEN        -- Loop onde se percorrem todas as linhas da tabela 'autorizacoes', que são apagadas uma a uma (caso existam)
      FOR posicao_atual IN autorizacoes.FIRST .. autorizacoes.LAST LOOP
        pkg_condominio.remove_autorizacao(autorizacoes(posicao_atual).administrador, autorizacoes(posicao_atual).ano, autorizacoes(posicao_atual).contrato);
      END LOOP;
    END IF;    
    
    
    DELETE FROM contrato WHERE (numero = numero_in);
    
    EXCEPTION
        WHEN OTHERS THEN RAISE;
END remove_contrato;

/*---------------------------------------------------------------------------------------*/

-- Remove o registo de um administrador para um determinado ano, bem como todas as autorizações que realizou nesse ano
PROCEDURE remove_administrador (          
    proprietario_in IN administra.proprietario%TYPE,
    ano_in IN administra.ano%TYPE)
IS
      TYPE tab_local_aut IS TABLE OF autoriza%ROWTYPE;
    
      autorizacoes tab_local_aut;  
BEGIN

   SELECT * BULK COLLECT INTO autorizacoes FROM autoriza A WHERE A.administrador = proprietario_in AND A.ano = ano_in;

    IF (autorizacoes.COUNT > 0) THEN
      FOR posicao_atual IN autorizacoes.FIRST .. autorizacoes.LAST LOOP
        pkg_condominio.remove_autorizacao(autorizacoes(posicao_atual).administrador, autorizacoes(posicao_atual).ano, autorizacoes(posicao_atual).contrato);
      END LOOP;
    END IF;    
    
    DELETE FROM administra WHERE (proprietario = proprietario_in) AND (ano_in = ano);
    
    EXCEPTION
        WHEN OTHERS THEN RAISE;
END remove_administrador;


/*---------------------------------------------------------------------------------------*/

-- Remove uma proprietário, todos os seus registos como administrador e todas as suas autorizações
PROCEDURE remove_proprietario (
   nif_in        IN proprietario.nif%TYPE)
IS
      TYPE tab_local_aut IS TABLE OF autoriza%ROWTYPE;
      autorizacoes tab_local_aut;
      TYPE tab_local_admin IS TABLE OF administra%ROWTYPE;
      administracao tab_local_admin;
BEGIN

   SELECT * BULK COLLECT INTO autorizacoes FROM autoriza A WHERE A.administrador = nif_in;
   
   IF (autorizacoes.COUNT > 0) THEN
      FOR posicao_atual IN autorizacoes.FIRST .. autorizacoes.LAST LOOP
        pkg_condominio.remove_autorizacao(autorizacoes(posicao_atual).administrador, autorizacoes(posicao_atual).ano, autorizacoes(posicao_atual).contrato);
      END LOOP;
    END IF;
    
   SELECT * BULK COLLECT INTO administracao FROM administra A WHERE A.proprietario = nif_in;
   
   IF (administracao.COUNT > 0) THEN
      FOR posicao_atual IN administracao.FIRST .. administracao.LAST LOOP
        pkg_condominio.remove_administrador(administracao(posicao_atual).proprietario, administracao(posicao_atual).ano);
      END LOOP;
    END IF;
    
    DELETE FROM proprietario WHERE (nif = nif_in);

  EXCEPTION
    WHEN OTHERS THEN RAISE;

END remove_proprietario;

END pkg_condominio;