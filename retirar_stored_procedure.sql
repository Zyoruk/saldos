create PROCEDURE retirar 
	@numeroDeTarjeta int,
	@monto numeric,
	@moneda char(3),
	@mjs varchar(50) out
AS
BEGIN
	if ( not exists (select * from tarjetas where numero_tarjeta=@numeroDeTarjeta))
	begin
		set @mjs = 'No existe ese número de tarjeta'
	end
	else
	begin
		declare @a numeric(18,2);
		select @a = _disponible from saldo;
		if (@a < @monto)
		begin
			set @mjs = 'Fondos insuficientes';
		end
		else 
		begin
			/**El monto es suficiente*/
			declare @cuenta int;
			declare @deuda numeric (18,2);
			declare @limite numeric (18,2);
			declare @disponible numeric (18,2);

			select @limite = s._limite, @limite = s._limite,@disponible = s._disponible, @cuenta = c.numero_cuenta
			from saldo as s 
			inner join tarjetas as t 
			on t._idCuenta = s._idCuenta 
			inner join cuentas as c
			on c._id = t._idCuenta
			where t.numero_tarjeta = @numeroDeTarjeta
			and s._moneda = @moneda;

			/*
			Un retiro debe de 
			aumentar la deuda
			reducir el disponible
			anotar la moneda
			y verificar que no llegue al limite
			*/

			if (@deuda + @monto > @limite)
				begin
					set @mjs = 'El monto excede el limite'; 
				end 				
			else 
				begin
					update saldo 
					set _deuda = @deuda+@monto, _disponible = @disponible - @monto 
					where _moneda = @moneda;
					insert into movimiento (_idCuenta, descripcion, moneda,_idTarjeta, monto) 
					values ((select c._id 
							from cuentas as c 
							where c.numero_cuenta = @cuenta) 
					, 'retiro'
					, @moneda
					, (select t._id 
						from tarjetas as t 
						where t.numero_tarjeta=@numeroDeTarjeta)
					, @monto); 
				end			
		end
	end
END
GO
