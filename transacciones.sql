/*
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
descripcion varchar (256),
moneda char(4),
monto numeric(18,2),
primary key(_id),
constraint unique_movimiento_cuenta_tarjeta unique (_idCuenta, _idTarjeta),
constraint fk_movimiento_cuenta FOREIGN key (_idCuenta) references cuentas(_id),
constraint fk_movimiento_tarjeta FOREIGN key (_idTarjeta) references tarjetas(_id))
go
*/
create proc realizar_compra @cuenta int, @tarjeta int, @mov varchar(20), @descr varchar(256), @moneda char(4), @monto numeric(18,2), @msg varchar(256) out, @done bit out as begin
	/*Probar si la cuenta existe*/
	if (exists(select * from cuentas where _id=@cuenta)) begin
		/*Probar si la cuenta tiene saldo disponible*/
		if (exists(select * from saldo where _idCuenta=@cuenta and _disponible >= @monto)) begin
			declare @actual numeric(18,2)
			declare @debe numeric(18,2)
			select @debe = _deuda from saldo where _idCuenta=@cuenta
			select @actual = _disponible from saldo where _idCuenta=@cuenta
			/*Actualizar saldo disponible y deuda*/
			update saldo set _disponible = @actual - @monto where _idCuenta=@cuenta
			update saldo set _deuda = @debe + @monto where _idCuenta=@cuenta
			/*Guardar la transaccion*/
			insert into movimiento (_idCuenta, _idTarjeta, descripcion, moneda, monto) values (@cuenta, @tarjeta, @descr, @moneda, @monto)
			/*completado*/
			set @done=1
			set @msg='Transaccion sompletada'
		end
		/*Sin saldo*/
		set @done=0
		set @msg='No hay saldo disponible'
	end
	/*Falta cuenta*/
	set @done=0
	set @msg='La cuenta no existe'
end