using System;

public class Pagar
{
	DataClasses1Pago p = new DataClasses1Pago();
	public Pagar()
	{

	}

	public void pagar(string numero_cuenta, int cantidad, int moneda)
	{
		p.Pagar(numero_cuenta, cantidad, moneda, ref msj);
		return msj;
	}

	public void verDeuda(string numero_cuenta, int moneda) 
	{
		p.verDeuda(numero_cuenta, moneda, ref msj, ref monto);
		if (monto > 0)
		{
			return monto;
		}
		else
		{
			return msj;
		}
	}
}
