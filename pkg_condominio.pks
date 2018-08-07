create or replace PACKAGE pkg_condominio IS

-- Cria um novo registo de propriet�rio.
PROCEDURE regista_proprietario (
   nif_in        IN proprietario.nif%TYPE,
   nome_in       IN proprietario.nome%TYPE,
   genero_in     IN proprietario.genero%TYPE,
   piso_in      IN proprietario.piso%TYPE,
   letra_in     IN proprietario.letra%TYPE);

/*---------------------------------------------------------------------------------------*/

-- Cria o novo registo de um administrador, dados um propriet�rio do pr�dio e o ano em que � administrador
PROCEDURE regista_administrador(
	proprietario_in  IN administra.proprietario%TYPE,
	ano_in           IN administra.ano%TYPE);

/*---------------------------------------------------------------------------------------*/

-- Cria o novo registo de um contrato e devolve o n�mero sequencial do contrato criado
FUNCTION regista_contrato(
  empresa_in      IN contrato.empresa%TYPE,
  equipamento_in  IN contrato.equipamento%TYPE,
  ano_in          IN contrato.ano%TYPE,
  euros_in        IN contrato.euros%TYPE)
RETURN contrato.numero%TYPE;

/*---------------------------------------------------------------------------------------*/

-- Cria o novo registo de uma autorizacao de um contrato por parte de um administrador em dado ano
PROCEDURE regista_autorizacao(
  administrador_in IN AUTORIZA.ADMINISTRADOR%TYPE,
  ano_in IN AUTORIZA.ANO%TYPE,
  contrato_in IN AUTORIZA.CONTRATO%TYPE);


-- Remove uma autoriza��o dada por um administrador num determinado ano e contrato
PROCEDURE remove_autorizacao (
  administrador_in IN autoriza.administrador%TYPE,
  ano_in IN autoriza.ano%TYPE,
  contrato_in IN autoriza.contrato%TYPE);

/*---------------------------------------------------------------------------------------*/

-- Remove um contrato e as suas autoriza��es associadas
PROCEDURE remove_contrato (
    numero_in IN contrato.numero%TYPE);

/*---------------------------------------------------------------------------------------*/

-- Remove o registo de um administrador para um determinado ano, bem como todas as autoriza��es que realizou nesse ano
PROCEDURE remove_administrador (          
    proprietario_in IN administra.proprietario%TYPE,
    ano_in IN administra.ano%TYPE);

/*---------------------------------------------------------------------------------------*/

-- Remove uma propriet�rio, todos os seus registos como administrador e todas as suas autoriza��es
PROCEDURE remove_proprietario (
   nif_in        IN proprietario.nif%TYPE);

END pkg_condominio;