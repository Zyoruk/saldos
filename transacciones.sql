create table cuentas(
_id int AUTO_INCREMENT,
numero_cuenta varchar(20),
primary key (_id))
go


create table tarjetas(
_id int  AUTO_INCREMENT,
numero_cuenta varchar(20),
numero_tarjeta varchar(20),
nombre_prop varchar(128),
primary key(_id),
FOREIGN key (numero_cuenta) references saldos(cuentas.numero_cuenta))
go

create table movimiento(
_id int  AUTO_INCREMENT,
numero_cuenta varchar(20),
_movimiento varchar(20),
descripcion varchar (256),
moneda char(4),
numero_tarjeta int,
monto int,
primary key(_id),
FOREIGN key (numero_cuenta) references saldos(saldo.numero_cuenta),
FOREIGN key (numero_tarjeta) references (tarjetas.numero_tarjeta))
go


create table saldo(
_id int AUTO_INCREMENT,
numero_cuenta varchar(20),
_limite int,
_deuda int,
_disponible int,
_moneda varchar(4),
primary key(_id),
FOREIGN key (numero_cuenta) references cuentas(cuentas.numero_cuenta))
go


