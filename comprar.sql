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
