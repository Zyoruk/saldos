create table cuentas(
_id int,
numero_cuenta varchar(20),
primary key (_id),
constraint unique_cuentas unique (numero_cuenta))
go


create table saldo(
_id int,
_idCuenta int,
_limite numeric(18,2),
_deuda numeric(18,2),
_disponible numeric(18,2),
_moneda varchar(4),
primary key(_id),
constraint unique_cuentas_saldo unique (_idCuenta),
constraint fk_saldo_cuentas FOREIGN key (_idCuenta) references cuentas(_id))
go

create table tarjetas(
_id int ,
_idCuenta int,
numero_tarjeta varchar(20),
nombre_prop varchar(60),
primary key(_id),
constraint unique_tarjetas_cuenta unique ( _idCuenta, numero_tarjeta),
constraint fk_tarjeta_cuentas FOREIGN key (_idCuenta) references cuentas(_id))
go

create table movimiento(
_id int,
_idCuenta int,
_idTarjeta int,
movimiento varchar(20),
descripcion varchar (256),
moneda char(4),
monto numeric(18,2),
primary key(_id),
constraint unique_movimiento_cuenta_tarjeta unique (_idCuenta, _idTarjeta),
constraint fk_movimiento_cuenta FOREIGN key (_idCuenta) references cuentas(_id),
constraint fk_movimiento_tarjeta FOREIGN key (_idTarjeta) references tarjetas(_id))
go


