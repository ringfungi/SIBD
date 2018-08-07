VARIABLE n_contrato NUMBER;

BEGIN

pkg_condominio.regista_proprietario(123456789, 'Gervásio', 'M', 1, 'A');
pkg_condominio.regista_proprietario(123456788, 'Catarina', 'F', 1, 'B');
pkg_condominio.regista_proprietario(123456787, 'Guilherme', 'M', 1, 'C');
pkg_condominio.regista_proprietario(123456786, 'António', 'M', 1, 'D');
pkg_condominio.regista_proprietario(123456785, 'Pedro', 'M', 1, 'E');
pkg_condominio.regista_proprietario(123456784, 'Deolinda', 'F', 2, 'A');
pkg_condominio.regista_proprietario(123456783, 'Matilde', 'F', 3, 'F');
pkg_condominio.regista_proprietario(123456782, 'Emma', 'F', 2, 'B');
pkg_condominio.regista_proprietario(123456781, 'Ferreira', 'M', 4, 'A');
pkg_condominio.regista_proprietario(123456780, 'Abhishek', 'M', 1, 'F');

pkg_condominio.regista_administrador(123456789, 2016);
pkg_condominio.regista_administrador(123456789, 2015);
pkg_condominio.regista_administrador(123456789, 2014);
pkg_condominio.regista_administrador(123456788, 2016);
pkg_condominio.regista_administrador(123456788, 2011);
pkg_condominio.regista_administrador(123456780, 2015);
pkg_condominio.regista_administrador(123456781, 2012);
pkg_condominio.regista_administrador(123456780, 2010);
pkg_condominio.regista_administrador(123456782, 2009);
pkg_condominio.regista_administrador(123456785, 2010);
pkg_condominio.regista_administrador(123456784, 2011);

:n_contrato := pkg_condominio.regista_contrato('Empresa A', 'Extintores', 2016, 5001.04);
pkg_condominio.regista_autorizacao(123456789, 2016, :n_contrato);

:n_contrato := pkg_condominio.regista_contrato('Empresa B', 'Extintores', 2015, 3000.00);
pkg_condominio.regista_autorizacao(123456789, 2015, :n_contrato);
pkg_condominio.regista_autorizacao(123456780, 2015, :n_contrato);

:n_contrato := pkg_condominio.regista_contrato('Empresa B', 'Elevadores', 2015, 4000.55);
pkg_condominio.regista_autorizacao(123456780, 2015, :n_contrato);

:n_contrato := pkg_condominio.regista_contrato('Empresa C', 'Extintores', 2010, 3000.66);
pkg_condominio.regista_autorizacao(123456785, 2010, :n_contrato);

:n_contrato := pkg_condominio.regista_contrato('Empresa D', 'Luzes', 2011, 2000.00);
pkg_condominio.regista_autorizacao(123456784, 2011, :n_contrato);
pkg_condominio.regista_autorizacao(123456788, 2011, :n_contrato);

pkg_condominio.remove_contrato(:n_contrato);
:n_contrato := pkg_condominio.regista_contrato('Empresa E', 'Luzes', 2011, 1999.99);
pkg_condominio.regista_autorizacao(123456784, 2011, :n_contrato);
pkg_condominio.regista_autorizacao(123456788, 2011, :n_contrato);

pkg_condominio.remove_autorizacao(123456788, 2011, :n_contrato);

pkg_condominio.remove_administrador(123456788, 2011);

pkg_condominio.remove_proprietario(123456788);
pkg_condominio.remove_proprietario(123456789);

END;
/