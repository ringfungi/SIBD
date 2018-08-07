/*---------------------------------------1-----------------------------------------*/
SELECT P.nif, P.nome, P.piso, P.letra
 FROM proprietario P, administra A
 WHERE A.ano > 2000
ORDER BY P.piso DESC, P.letra DESC;
/*---------------------------------------2-----------------------------------------*/
SELECT P1.nif, P1.nome
 FROM proprietario P1, administra A
 WHERE (P1.nif = A.proprietario) 
  AND A.ano BETWEEN 2000 AND 2010
UNION  
SELECT P2.nif, P2.nome
 FROM proprietario P2
 WHERE P2.piso > 5 AND P2.genero = 'F';
/*---------------------------------------3-----------------------------------------*/
SELECT C.empresa, A.proprietario
 FROM contrato C, administra A
 WHERE C.equipamento = 'elevadores'
  AND C.ano BETWEEN 2010 AND 2015
  AND A.proprietario LIKE 'P%';
/*---------------------------------------4-----------------------------------------*/
SELECT A1.proprietario, P.nome
 FROM administra A1, proprietario P
 WHERE A1.proprietario = P.nif
 AND P.genero= 'M'
MINUS
SELECT A2.administrador, P2.nome
 FROM autoriza A2, contrato C, proprietario P2
 WHERE C.equipamento = 'extintores'
 AND C.euros > 5000;
/*---------------------------------------5-----------------------------------------*/
SELECT C.empresa, C.equipamento, C.ano, C.euros
FROM contrato C
WHERE NOT EXISTS (SELECT *
                  FROM administra A
                  WHERE A.ano = C.ano
                  AND NOT EXISTS (SELECT *
                                  FROM autoriza A1
                                  WHERE A1.contrato = C.numero
                                  AND A1.administrador = A.proprietario))
ORDER BY C.ano DESC, C.euros DESC, C.empresa ASC, C.equipamento ASC;  
/*---------------------------------------6-----------------------------------------*/
SELECT A.administrador, P.nome, A.ano, SUM(C.euros) AS total, SUM(C.euros * 0.06) as IVA
FROM autoriza A, proprietario P, contrato C
WHERE A.administrador = P.nif
AND A.contrato = C.numero
GROUP BY A.administrador, P.nome, A.ano
ORDER BY A.administrador ASC, P.nome ASC, A.ano DESC;
/*---------------------------------------7-----------------------------------------*/
SELECT A.ano, P.nif, P.nome, COUNT (*) AS n_autorizacoes
FROM autoriza A, proprietario P, contrato C
WHERE A.administrador = P.nif
AND A.contrato = C.numero
GROUP BY A.ano, P.nif, P.nome
HAVING (COUNT(A.administrador) >= ALL (SELECT COUNT(*)
                                     FROM contrato C1, autoriza A1
                                     WHERE C1.numero = A1.contrato
                                     AND A1.ano = A.ano
                                     GROUP BY A1.administrador, A1.ano))
ORDER BY A.ano DESC, P.nome ASC, P.nif ASC;
/*---------------------------------------8-----------------------------------------*/
SELECT DISTINCT P.genero,
         A.proprietario, 
         P.nome, 
         COUNT (A.proprietario) AS n_anos,
         MIN (A.ano) AS a_primeiro,
         MAX (A.ano) AS a_ultimo
FROM proprietario P, administra A
WHERE A.proprietario = P.nif 
GROUP BY P.genero, A.proprietario, P.nome
HAVING (COUNT (A.proprietario) >= ALL (SELECT COUNT(*)
                                      FROM proprietario P1, administra A1
                                      WHERE P1.nif = A1.proprietario
                                      AND P1.genero = P.genero
                                      GROUP BY (P1.genero, P1.nif)));