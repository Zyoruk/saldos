use [saldos] 
go

create table cuentas(
_id int,
numero_cuenta varchar(20),
primary key (_id),
constraint unique_cuentas unique (numero_cuenta))
go


create table saldo(
_id int,
numero_cuenta varchar(20),
_limite int,
_deuda int,
_disponible int,
_moneda varchar(4),
primary key(_id),
constraint unique_cuentas_saldo unique (numero_cuenta),
constraint fk_saldo_cuentas FOREIGN key (numero_cuenta) references cuentas(numero_cuenta))
go

create table tarjetas(
_id int ,
numero_cuenta varchar(20),
numero_tarjeta varchar(20),
nombre_prop varchar(128),
primary key(_id),
constraint unique_cuentas_tarjetas unique (numero_cuenta),
constraint unique_tarjetas_tarjetas unique (numero_tarjeta),
constraint fk_tarjeta_cuentas FOREIGN key (numero_cuenta) references cuentas(numero_cuenta))
go

create table movimiento(
_id int,
numero_cuenta varchar(20),
_movimiento varchar(20),
descripcion varchar (256),
moneda char(4),
numero_tarjeta varchar(20),
monto int,
primary key(_id),
constraint unique_cuentas_movimiento unique (numero_cuenta),
constraint fk_movimiento_cuenta FOREIGN key (numero_cuenta) references cuentas(numero_cuenta),
constraint fk_movimiento_tarjeta FOREIGN key (numero_tarjeta) references tarjetas(numero_tarjeta))
go


