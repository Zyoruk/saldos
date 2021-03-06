USE [Saldos]
GO
/****** Object:  Table [dbo].[cuentas]    Script Date: 28/11/2018 16:16:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[cuentas](
	[_id] [int] NOT NULL,
	[numero_cuenta] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[movimiento]    Script Date: 28/11/2018 16:16:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[movimiento](
	[_id] [int] IDENTITY(1,1) NOT NULL,
	[_idCuenta] [int] NULL,
	[_idTarjeta] [int] NULL,
	[descripcion] [varchar](256) NULL,
	[moneda] [char](4) NULL,
	[monto] [numeric](18, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[saldo]    Script Date: 28/11/2018 16:16:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[saldo](
	[_id] [int] NOT NULL,
	[_idCuenta] [int] NULL,
	[_limite] [numeric](18, 2) NULL,
	[_deuda] [numeric](18, 2) NULL,
	[_disponible] [numeric](18, 2) NULL,
	[_moneda] [varchar](4) NULL,
PRIMARY KEY CLUSTERED 
(
	[_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tarjetas]    Script Date: 28/11/2018 16:16:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tarjetas](
	[_id] [int] NOT NULL,
	[_idCuenta] [int] NULL,
	[numero_tarjeta] [varchar](20) NULL,
	[nombre_prop] [varchar](60) NULL,
PRIMARY KEY CLUSTERED 
(
	[_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[movimiento]  WITH CHECK ADD FOREIGN KEY([_idCuenta])
REFERENCES [dbo].[cuentas] ([_id])
GO
ALTER TABLE [dbo].[movimiento]  WITH CHECK ADD FOREIGN KEY([_idTarjeta])
REFERENCES [dbo].[tarjetas] ([_id])
GO
ALTER TABLE [dbo].[saldo]  WITH CHECK ADD FOREIGN KEY([_idCuenta])
REFERENCES [dbo].[cuentas] ([_id])
GO
ALTER TABLE [dbo].[tarjetas]  WITH CHECK ADD FOREIGN KEY([_idCuenta])
REFERENCES [dbo].[cuentas] ([_id])
GO
/****** Object:  StoredProcedure [dbo].[estado_cuenta]    Script Date: 28/11/2018 16:16:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[estado_cuenta]
@numero_cuenta varchar(20),
@msg varchar(20) out
as 
begin
if(exists(select * from cuentas where numero_cuenta=@numero_cuenta)) begin
select c.numero_cuenta as Cuenta,t.numero_tarjeta as Tarjeta, m.descripcion as Descripcion,m.moneda as Moneda, m.monto as Monto from movimiento as m inner join cuentas as c on m._idCuenta = c._id inner join tarjetas as t on m._idTarjeta = t._id where c.numero_cuenta = @numero_cuenta
set @msg = 'Cuenta encontrada';
end
else
set @msg = 'No existe la cuenta';
end
GO
/****** Object:  StoredProcedure [dbo].[Pagar]    Script Date: 28/11/2018 16:16:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Pagar]
@numero_cuenta varchar(20),
@_cantidad numeric,
@_moneda varchar(4),
@mjs varchar(50)out
as begin
	DECLARE @deuda int;
	DECLARE @tarjeta int;
	select @deuda = _deuda from saldo where _moneda = @_moneda and _idCuenta = (select _id from cuentas where numero_cuenta = @numero_cuenta);
	select @tarjeta = t._id from tarjetas as t where t._idCuenta = (select _id from cuentas where numero_cuenta = @numero_cuenta);
	if(@deuda = 0)
		set @mjs='No tiene deuda que pagar';
	else
		begin
			UPDATE saldo SET _deuda = (_deuda-@_cantidad), _disponible = (_disponible+@_cantidad) WHERE _moneda = @_moneda and _idCuenta = (select _id from cuentas where numero_cuenta = @numero_cuenta);

			DECLARE @id_cuenta int
			select  @id_cuenta = c._id from cuentas as c where c.numero_cuenta = @numero_cuenta

			insert into movimiento (_idCuenta,_idTarjeta, descripcion, moneda, monto) values (@id_cuenta,@tarjeta, 'Pago de tarjeta', @_moneda, @_cantidad);
			set  @mjs='El saldo se ha rebajado correctamente';
		end
end

GO
/****** Object:  StoredProcedure [dbo].[realizar_compra]    Script Date: 28/11/2018 16:16:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[realizar_compra] @cuenta int, @tarjeta int, @mov varchar(20), @descr varchar(256), @moneda char(4), @monto numeric(18,2), @msg varchar(256) out as begin
	/*Probar si la cuenta existe*/
	if (exists(select * from cuentas where _id=@cuenta)) begin
	  if(exists (select * from tarjetas where numero_tarjeta=@tarjeta)) begin
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
			DECLARE @id_tarjeta int
			select @id_tarjeta = t._id from tarjetas as t where t.numero_tarjeta=@tarjeta

			insert into movimiento (_idCuenta, _idTarjeta, descripcion, moneda, monto) values (@cuenta, @id_tarjeta, @descr, @moneda, @monto)
			/*completado*/
			set @msg='Transacción completada'			
		end
		/*Sin saldo*/
		else
				set @msg='No hay saldo disponible'

	   end
	   else
		 set @msg = 'No existe ese número de tarjeta'
	end
	else
	/*Falta cuenta*/
	set @msg='La cuenta no existe'
end
GO
/****** Object:  StoredProcedure [dbo].[retirar]    Script Date: 28/11/2018 16:16:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[retirar] 
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

			select @limite = s._limite, @deuda = s._deuda,@disponible = s._disponible, @cuenta = c.numero_cuenta
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

					DECLARE @id_cuenta int
					select  @id_cuenta = c._id from cuentas as c where c.numero_cuenta = @cuenta

					DECLARE @id_tarjeta int
					select @id_tarjeta = t._id from tarjetas as t where t.numero_tarjeta=@numeroDeTarjeta


					insert into movimiento (_idCuenta,_idTarjeta, descripcion, moneda, monto) 
					values (@id_cuenta 
					, @id_tarjeta
					,'retiro'
					, @moneda				
					, @monto); 

					set @mjs = 'Retiro exitoso';
				end			
		end
	end
END

GO
/****** Object:  StoredProcedure [dbo].[verDeuda]    Script Date: 28/11/2018 16:16:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[verDeuda]
@numero_cuenta varchar(20),
@_moneda varchar(4),
@mjs varchar(50) out,
@monto numeric,
@mjs_monto varchar(50) out,
@mjs_dis varchar(50) out


as begin 
	DECLARE @deuda  numeric
	select @deuda = _deuda from saldo where _idCuenta = (select _id from cuentas where numero_cuenta = @numero_cuenta)  and _moneda = @_moneda;
	if(@deuda = 0 or @deuda < 0)
		set @mjs = 'No tiene deuda actualmente';
	else
		DECLARE @dis numeric
		select @dis = _disponible from saldo where _idCuenta = (select _id from cuentas where numero_cuenta = @numero_cuenta)  and _moneda = @_moneda;
		begin
		set @mjs = 'Su deuda corresponde a ';
		set @mjs_monto = @deuda;
		set @mjs_dis = @dis;
		end
end
GO
