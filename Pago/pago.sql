
create proc Pagar
@numero_cuenta varchar(20),
@_cantidad int,
@_moneda varchar(4),
@mjs varchar(50)out
as begin
	DECLARE @deuda INT;
	DECLARE @tarjeta int;
	select _deuda = @deuda from saldos where moneda = @_modena and numero_cuenta = @numero_cuenta;
	select numero_tarjeta = @tarjeta from tarjetas t inner join cuentas c on c.numero_cuenta = t.numero_cuenta and c.numero_cuenta = @numero_cuenta;
	if(@deuda == 0))
		set @mjs='No tiene deuda para pagar';
	else
		begin
			UPDATE saldo SET _deuda = deuda -@_cantidad WHERE _moneda = @_modena and numero_cuenta = @numero_cuenta;
			insert into movimiento (numero_cuenta, descripcion, moneda, numero_tarjeta, monto) values (@numero_cuenta, "Pago de tarjeta", @_moneda, @tarjeta, @_cantidad);
			set  @mjs='el saldo se ha rebajado correctamente';
		end
end
go


create proc verDeuda
@numero_cuenta varchar(20),
@_moneda varchar(4),
@mjs varchar(50)out,
@monto int out

as begin 
	select _deuda = @monto from saldo where numero_cuenta = @numero_cuenta and _moneda = @moneda;
	if(@monto == 0 or @monto < 0)
		set @msj = "No tiene deuda actualmente";
	else
		begin
		set @msj = "su deuda corresponde a" + @monto;
		end
end
go