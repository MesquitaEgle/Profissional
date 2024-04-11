-- Monitoramento.CarteiraGeral

CREATE SCHEMA Monitoramento
GO


CREATE VIEW Monitoramento.CarteiraGeral
AS

WITH

FundoMAPS AS	----------------------------------------------------------------------------------------------------------------------------------------------------------------
(	SELECT	A.ID_CNPJ_Fundo															ID_CNPJ_Fundo,
			C.Tipo_Fundo_Abreviado													Tipo_Fundo,
			B.Nome_Fundo															Nome_Fundo,
			C1.Tipo_Condominio														Tipo_Condominio,
			C2.Classificacao_Solis													Classificacao_Solis,
			C3.Classificacao_Categoria_Solis										Classificacao_Categoria_Solis,
			A.Data_Posicao															Data_Posicao,
			ISNULL(A.Valor_Cota_Total, 0.00)										Subordinada,
			ISNULL(SR.Valor_Liquido, 0.00)											Senior,
			ISNULL(MZ.Valor_Liquido, 0.00)											Mezanino,
			ISNULL(CASE WHEN A.Valor_Patrimonio IS NULL
							 OR A.Valor_Patrimonio = 0
						THEN A.Valor_Cota_Total
						ELSE A.Valor_Patrimonio
				   END, 0.00)														Patrimonio,
	
			ISNULL(RF.Valor_Total, 0.00)											Renda_Fixa,
			ISNULL(RV.Valor_Total, 0.00)											Renda_Variavel,
			ISNULL(CF.Valor_Total, 0.00)											Cota_Fundos,
			ISNULL(DC.Valor_Total, 0.00)											Direitos_Creditorios,
			ISNULL(PDD.Valor_Total, 0.00)											PDD,
			ISNULL(OI.Valor_Total, 0.00)											Imoveis,
			ISNULL(BMF.Valor_Total, 0.00)											BMF,
			ISNULL(CX.Valor_Total, 0.00)											Conta_Corrente,
			ISNULL(OO.Valor_Total, 0.00)											Outros,
			ISNULL(OVI.Valor_Total, 0.00)											Valor_Indentificar,
			ISNULL(S.Valor_Total, 0.00)												Swap,
			ISNULL(VC.Valor_Total, 0.00)											Valor_Converter,
			ISNULL(VPR1.Valor_Total, 0.00)											Valor_Pagar,
			ISNULL(VPR2.Valor_Total, 0.00)											Valor_Receber,

			ISNULL(ISNULL(CASE WHEN A.Valor_Patrimonio IS NULL
									OR A.Valor_Patrimonio = 0
							   THEN A.Valor_Cota_Total
							   ELSE A.Valor_Patrimonio
						  END, 0.00)
					- (ISNULL(RF.Valor_Total, 0.00)
					+  ISNULL(RV.Valor_Total, 0.00)
					+  ISNULL(CF.Valor_Total, 0.00)	
					+  ISNULL(DC.Valor_Total, 0.00)	
					+  ISNULL(PDD.Valor_Total, 0.00)	
					+  ISNULL(OI.Valor_Total, 0.00)	
--					+  ISNULL(BMF.Valor_Total, 0.00)	
					+  ISNULL(CX.Valor_Total, 0.00)	
					+  ISNULL(OO.Valor_Total, 0.00)	
					+  ISNULL(OVI.Valor_Total, 0.00)	
					+  ISNULL(S.Valor_Total, 0.00)	
					+  ISNULL(VC.Valor_Total, 0.00)	
					+  ISNULL(VPR1.Valor_Total, 0.00)
					+  ISNULL(VPR2.Valor_Total, 0.00)), 0.00)							Conciliacao1,

			ISNULL(ISNULL(CASE WHEN A.Valor_Patrimonio IS NULL
									OR A.Valor_Patrimonio = 0
							   THEN A.Valor_Cota_Total
							   ELSE A.Valor_Patrimonio
						  END, 0.00)
						- (	  ISNULL(A.Valor_Cota_Total, 0.00)
							+ ISNULL(MZ.Valor_Liquido, 0.00)
							+ ISNULL(SR.Valor_Liquido, 0.00)), 0.00)					Conciliacao2,

			ISNULL(RENT1.Diaria, 0.00)													Cota_Dia,
			ISNULL(RENT1.Mensal, 0.00)													Cota_Mes,
			ISNULL(RENT1.Anual, 0.00)													Cota_Ano,
			ISNULL(RENT2.Diaria, 0.00)													Variacao_Dia,
			ISNULL(RENT2.Mensal, 0.00)													Variacao_Mes,
			ISNULL(RENT2.Anual, 0.00)													Variacao_Ano
	
	FROM	Solis.Carteira.MAPS_Parametros							A	WITH(NOLOCK)
			LEFT JOIN Isys.Cadastro.Fundo							B	ON	B.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo	COLLATE Latin1_General_CI_AS
			LEFT JOIN Isys.Parametro.Tipo_fundo						C	ON	C.ID_Tipo_Fundo = B.ID_Tipo_Fundo
			LEFT JOIN Isys.Parametro.Tipo_Condominio				C1	ON	C1.ID_Tipo_Condominio = B.ID_Condominio
			LEFT JOIN Isys.Parametro.Classificacao_Solis			C2	ON	C2.ID_Classificacao_Solis = B.ID_Classificacao_Solis
			LEFT JOIN Isys.Parametro.Classificacao_Categoria_Solis	C3	ON	C3.ID_Classificacao_Categoria_Solis = B.ID_Classificacao_Categoria_Solis

			LEFT JOIN (	SELECT	A.Data_Posicao		Data_Posicao,
								A.ID_CNPJ_Fundo		ID_CNPJ_Fundo,
								SUM(A.Valor_Total)	Valor_Liquido
						FROM	Solis.Carteira.MAPS_Cotas_Superiores	A
								LEFT JOIN Isys.Cota.Cota_Cadastro		B	ON	B.ID_Cota_Cadastro = A.ID_Cota_Cadastro
						WHERE	B.ID_Cota_Tipo = '1' /* SENIOR */
						GROUP BY	A.Data_Posicao,
									A.ID_CNPJ_Fundo)	SR	ON	SR.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo
															AND SR.Data_Posicao = A.Data_Posicao

			LEFT JOIN (	SELECT	A.Data_Posicao		Data_Posicao,
								A.ID_CNPJ_Fundo		ID_CNPJ_Fundo,
								SUM(A.Valor_Total)	Valor_Liquido
						FROM	Solis.Carteira.MAPS_Cotas_Superiores	A
								LEFT JOIN Isys.Cota.Cota_Cadastro		B	ON	B.ID_Cota_Cadastro = A.ID_Cota_Cadastro
						WHERE	B.ID_Cota_Tipo = '2' /* MEZANINO */
						GROUP BY	A.Data_Posicao,
									A.ID_CNPJ_Fundo)	MZ	ON	MZ.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo
															AND MZ.Data_Posicao = A.Data_Posicao

			LEFT JOIN (	SELECT	Data_Posicao		Data_Posicao,
								ID_CNPJ_Fundo		ID_CNPJ_Fundo,
								SUM(Valor_Total)	Valor_Total
						FROM	Solis.Carteira.MAPS_Renda_Fixa
						WHERE	Nome_Papel NOT IN (	SELECT	Descricao	COLLATE SQL_Latin1_General_CP1_CI_AS
													FROM	Isys.Parametro.Identificacao_Ativo
													WHERE	Identificacao = 'DIREITOS CREDITÓRIOS'
															AND Tabela = 'SOLIS.CARTEIRA.MAPS_RENDA_FIXA')
						GROUP BY	Data_Posicao,
									ID_CNPJ_Fundo)		RF	ON	RF.Data_Posicao = A.Data_Posicao
															AND RF.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo							

			LEFT JOIN (	SELECT	Data_Posicao		Data_Posicao,
								ID_CNPJ_Fundo		ID_CNPJ_Fundo,
								SUM(Valor_Total)	Valor_Total
						FROM	Solis.Carteira.MAPS_Renda_Variavel
						GROUP BY	Data_Posicao,
									ID_CNPJ_Fundo)		RV	ON	RV.Data_Posicao = A.Data_Posicao
															AND RV.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo							

			LEFT JOIN (	SELECT	Data_Posicao		Data_Posicao,
								ID_CNPJ_Fundo		ID_CNPJ_Fundo,
								SUM(Valor_Total)	Valor_Total
						FROM	Solis.Carteira.MAPS_Cotas_Fundos
						GROUP BY	Data_Posicao,
									ID_CNPJ_Fundo)		CF	ON	CF.Data_Posicao = A.Data_Posicao
															AND CF.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo							

			LEFT JOIN (	SELECT	A.Data_Posicao		Data_Posicao,
								A.ID_CNPJ_Fundo		ID_CNPJ_Fundo,
								SUM(A.Valor_Total)	Valor_Total
						FROM	(	SELECT	Data_Posicao		Data_Posicao,									
											ID_CNPJ_Fundo		ID_CNPJ_Fundo,
											SUM(Valor_Presente)	Valor_Total
									FROM	Solis.Carteira.MAPS_Outros_Direitos_Creditorios
									GROUP BY	Data_Posicao,
												ID_CNPJ_Fundo
									UNION			
									SELECT	Data_Posicao		Data_Posicao,
											ID_CNPJ_Fundo		ID_CNPJ_Fundo,
											SUM(Valor_Total)	Valor_Total
									FROM	Solis.Carteira.MAPS_Renda_Fixa
									WHERE	Nome_Papel IN (	SELECT	Descricao	COLLATE SQL_Latin1_General_CP1_CI_AS
															FROM	Isys.Parametro.Identificacao_Ativo
															WHERE	Identificacao = 'DIREITOS CREDITÓRIOS'
																	AND Tabela = 'SOLIS.CARTEIRA.MAPS_RENDA_FIXA')
									GROUP BY	Data_Posicao,
												ID_CNPJ_Fundo
									
									UNION
									SELECT	Data_Posicao		Data_Posicao,
											ID_CNPJ_Fundo		ID_CNPJ_Fundo,
											SUM(Valor_Total)	Valor_Total
									FROM	Solis.Carteira.MAPS_Valores_a_Pagar_Receber
									WHERE	ID_Carteira_Sistema = '12'
											AND Segmento IN ('RENDA FIXA')
									GROUP BY	Data_Posicao,
												ID_CNPJ_Fundo)	A
						GROUP BY	A.Data_Posicao,
									A.ID_CNPJ_Fundo)	DC	ON	DC.Data_Posicao = A.Data_Posicao
															AND DC.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo							

			LEFT JOIN (	SELECT	Data_Posicao		Data_Posicao,
								ID_CNPJ_Fundo		ID_CNPJ_Fundo,
								SUM(Valor_Total)	Valor_Total
						FROM	Solis.Carteira.MAPS_Outros_PDD
						GROUP BY	Data_Posicao,
									ID_CNPJ_Fundo)		PDD	ON	PDD.Data_Posicao = A.Data_Posicao
															AND PDD.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo							

			LEFT JOIN (	SELECT	Data_Posicao		Data_Posicao,
								ID_CNPJ_Fundo		ID_CNPJ_Fundo,
								SUM(Valor_Total)	Valor_Total
						FROM	Solis.Carteira.MAPS_Outros_Imoveis
						GROUP BY	Data_Posicao,
									ID_CNPJ_Fundo)		OI	ON	OI.Data_Posicao = A.Data_Posicao
															AND OI.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo							

			LEFT JOIN (	SELECT	Data_Posicao		Data_Posicao,
								ID_CNPJ_Fundo		ID_CNPJ_Fundo,
								SUM(Ajuste)			Valor_Total
						FROM	Solis.Carteira.MAPS_BMF_Futuros
						GROUP BY	Data_Posicao,
									ID_CNPJ_Fundo)		BMF	ON	BMF.Data_Posicao = A.Data_Posicao
															AND BMF.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo							

			LEFT JOIN (	SELECT	Data_Posicao		Data_Posicao,
								ID_CNPJ_Fundo		ID_CNPJ_Fundo,
								SUM(Valor_Total)	Valor_Total
						FROM	Solis.Carteira.MAPS_Caixa
						GROUP BY	Data_Posicao,
									ID_CNPJ_Fundo)		CX	ON	CX.Data_Posicao = A.Data_Posicao
															AND CX.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo							

			LEFT JOIN (	SELECT	Data_Posicao		Data_Posicao,
								ID_CNPJ_Fundo		ID_CNPJ_Fundo,
								SUM(Valor_Total)	Valor_Total
						FROM	Solis.Carteira.MAPS_Outros_Outros
						GROUP BY	Data_Posicao,
									ID_CNPJ_Fundo)		OO	ON	OO.Data_Posicao = A.Data_Posicao
															AND OO.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo							

			LEFT JOIN (	SELECT	Data_Posicao		Data_Posicao,
								ID_CNPJ_Fundo		ID_CNPJ_Fundo,
								SUM(Valor_Total)	Valor_Total
						FROM	Solis.Carteira.MAPS_Outros_Valores_Identificar
						GROUP BY	Data_Posicao,
									ID_CNPJ_Fundo)		OVI	ON	OVI.Data_Posicao = A.Data_Posicao
															AND OVI.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo							

			LEFT JOIN (	SELECT	Data_Posicao		Data_Posicao,
								ID_CNPJ_Fundo		ID_CNPJ_Fundo,
								SUM(Valor_Total)	Valor_Total
						FROM	Solis.Carteira.MAPS_Swap
						GROUP BY	Data_Posicao,
									ID_CNPJ_Fundo)		S	ON	S.Data_Posicao = A.Data_Posicao
															AND S.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo							
																
			LEFT JOIN (	SELECT	Data_Posicao		Data_Posicao,
								ID_CNPJ_Fundo		ID_CNPJ_Fundo,
								SUM(Valor_Total)	Valor_Total
						FROM	Solis.Carteira.MAPS_Valores_a_Converter
						GROUP BY	Data_Posicao,
									ID_CNPJ_Fundo)		VC	ON	VC.Data_Posicao = A.Data_Posicao
															AND VC.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo							

			LEFT JOIN (	SELECT	Data_Posicao		Data_Posicao,
								ID_CNPJ_Fundo		ID_CNPJ_Fundo,
								SUM(Valor_Total)	Valor_Total
						FROM	Solis.Carteira.MAPS_Valores_a_Pagar_Receber
						WHERE	ID_Carteira_Sistema = '11' /*Valores a Pagar*/
						GROUP BY	Data_Posicao,
									ID_CNPJ_Fundo)	VPR1	ON	VPR1.Data_Posicao = A.Data_Posicao
															AND VPR1.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo

			LEFT JOIN (	SELECT	Data_Posicao		Data_Posicao,
								ID_CNPJ_Fundo		ID_CNPJ_Fundo,
								SUM(Valor_Total)	Valor_Total
						FROM	Solis.Carteira.MAPS_Valores_a_Pagar_Receber
						WHERE	ID_Carteira_Sistema = '12' /*Valores a Receber*/
								AND Segmento NOT IN ('RENDA FIXA')
						GROUP BY	Data_Posicao,
									ID_CNPJ_Fundo)	VPR2	ON	VPR2.Data_Posicao = A.Data_Posicao
															AND VPR2.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo
				
			LEFT JOIN (	SELECT	Data_Posicao,
								ID_CNPJ_Fundo,
								Indexador,
								Diaria,
								Mensal,
								Anual
						FROM	Solis.Carteira.MAPS_Rentabilidade
						WHERE	Indexador = 'COTA')		RENT1	ON	RENT1.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo
																AND RENT1.Data_Posicao = A.Data_Posicao
			LEFT JOIN (	SELECT	Data_Posicao,
								ID_CNPJ_Fundo,
								Indexador,
								Diaria,
								Mensal,
								Anual
						FROM	Solis.Carteira.MAPS_Rentabilidade
						WHERE	Indexador = 'VARIAÇÃO')	RENT2	ON	RENT2.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo
																AND RENT2.Data_Posicao = A.Data_Posicao
),


FundoBTG AS		----------------------------------------------------------------------------------------------------------------------------------------------------------------
(	SELECT	A.ID_CNPJ_Fundo															ID_CNPJ_Fundo,
			C.Tipo_Fundo_Abreviado													Tipo_Fundo,
			B.Nome_Fundo															Nome_Fundo,
			C1.Tipo_Condominio														Tipo_Condominio,
			C2.Classificacao_Solis													Classificacao_Solis,
			C3.Classificacao_Categoria_Solis										Classificacao_Categoria_Solis,
			A.Data_Posicao															Data_Posicao,
			ISNULL(SB.Valor_Liquido, 0.00)											Subordinada,
			ISNULL(SR.Valor_Liquido, 0.00)											Senior,
			ISNULL(MZ.Valor_Liquido, 0.00)											Mezanino,
			ISNULL(SUM(A.Valor_Patrimonio), 0.00)									Patrimonio,
	
			ISNULL(RF.Valor_Total, 0.00)											Renda_Fixa,
			ISNULL(BA.Valor_Total, 0.00)											Renda_Variavel,
			ISNULL(BPI.Valor_Total, 0.00)											Cota_Fundos,
			ISNULL(0.00, 0.00)														Direitos_Creditorios,
			ISNULL(0.00, 0.00)														PDD,
			ISNULL(0.00, 0.00)														Imoveis,
			ISNULL(BMF.Valor_Total, 0.00)											BMF,
			ISNULL(0.00, 0.00)														Conta_Corrente,
			null																	Outros,
			ISNULL(0.00, 0.00)														Valor_Indentifica,
			ISNULL(0.00, 0.00)														Swap,
			null																	Valor_Converter,
			ISNULL(VPR1.Valor_Total, 0.00)											Valor_Pagar,
			ISNULL(VPR2.Valor_Total, 0.00)											Valor_Receber,

			null																	Conciliacao1,
			null																	Conciliacao2,

			ISNULL(RENT.Rentabilidade_Dia/100, 0.00)								Cota_Dia,
			ISNULL(RENT.Rentabilidade_Mes/100, 0.00)								Cota_Mes,
			ISNULL(RENT.Rentabilidade_Ano/100, 0.00)								Cota_Ano,
			ISNULL(RENT.Percentual_CDI_Dia/100, 0.00)								Variacao_Dia,
			ISNULL(RENT.Percentual_CDI_Mes/100, 0.00)								Variacao_Mes,
			ISNULL(RENT.Percentual_CDI_Ano/100, 0.00)								Variacao_Ano
	
	FROM	(	SELECT	Data_Posicao			Data_Posicao,
						ID_CNPJ_Fundo			ID_CNPJ_Fundo,
						SUM(Valor_Patrimonio)	Valor_Patrimonio
				FROM	Solis.Carteira.BTG_Rentabilidade
				GROUP BY	Data_Posicao,
							ID_CNPJ_Fundo)							A	
			LEFT JOIN Isys.Cadastro.Fundo							B	ON	B.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo	COLLATE Latin1_General_CI_AS
			LEFT JOIN Isys.Parametro.Tipo_fundo						C	ON	C.ID_Tipo_Fundo = B.ID_Tipo_Fundo
			LEFT JOIN Isys.Parametro.Tipo_Condominio				C1	ON	C1.ID_Tipo_Condominio = B.ID_Condominio
			LEFT JOIN Isys.Parametro.Classificacao_Solis			C2	ON	C2.ID_Classificacao_Solis = B.ID_Classificacao_Solis
			LEFT JOIN Isys.Parametro.Classificacao_Categoria_Solis	C3	ON	C3.ID_Classificacao_Categoria_Solis = B.ID_Classificacao_Categoria_Solis

			LEFT JOIN (	SELECT	A.Data_Posicao		Data_Posicao,
								A.ID_CNPJ_Fundo		ID_CNPJ_Fundo,
								A.Valor_Patrimonio	Valor_Liquido
						FROM	Solis.Carteira.BTG_Rentabilidade	A	WITH(NOLOCK)
								LEFT JOIN Isys.Cota.Cota_Cadastro	B	ON	B.ID_Cota_Cadastro = A.ID_Cota_Cadastro
						WHERE	B.ID_Cota_Tipo = '1' /* SENIOR */)			SR	ON	SR.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo
																			AND SR.Data_Posicao = A.Data_Posicao
			LEFT JOIN (	SELECT	A.Data_Posicao		Data_Posicao,
								A.ID_CNPJ_Fundo		ID_CNPJ_Fundo,
								A.Valor_Patrimonio	Valor_Liquido
						FROM	Solis.Carteira.BTG_Rentabilidade	A	WITH(NOLOCK)
								LEFT JOIN Isys.Cota.Cota_Cadastro	B	ON	B.ID_Cota_Cadastro = A.ID_Cota_Cadastro
						WHERE	B.ID_Cota_Tipo = '2'	/* MEZANINO */)		MZ	ON	MZ.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo
																			AND MZ.Data_Posicao = A.Data_Posicao
			LEFT JOIN (	SELECT	A.Data_Posicao		Data_Posicao,
								A.ID_CNPJ_Fundo		ID_CNPJ_Fundo,
								A.Valor_Patrimonio	Valor_Liquido
						FROM	Solis.Carteira.BTG_Rentabilidade	A	WITH(NOLOCK)
								LEFT JOIN Isys.Cota.Cota_Cadastro	B	ON	B.ID_Cota_Cadastro = A.ID_Cota_Cadastro
						WHERE	B.ID_Cota_Tipo = '3' /* SUBORDINADA */)		SB	ON	SB.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo
																			AND SB.Data_Posicao = A.Data_Posicao

			LEFT JOIN (	SELECT	Data_Posicao		Data_Posicao,
								ID_CNPJ_Fundo		ID_CNPJ_Fundo,
								SUM(Valor_Total)	Valor_Total
						FROM	Solis.Carteira.BTG_Renda_Fixa
						GROUP BY	Data_Posicao,
									ID_CNPJ_Fundo)	RF	ON	RF.Data_Posicao = A.Data_Posicao
														AND	RF.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo

			LEFT JOIN (	SELECT	Data_Posicao		Data_Posicao,
								ID_CNPJ_Fundo		ID_CNPJ_Fundo,
								SUM(Valor_Total)	Valor_Total
						FROM	Solis.Carteira.BTG_Acoes
						GROUP BY	Data_Posicao,
									ID_CNPJ_Fundo)	BA	ON	BA.Data_Posicao = A.Data_Posicao
														AND	BA.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo

			LEFT JOIN (	SELECT	Data_Posicao		Data_Posicao,
								ID_CNPJ_Fundo		ID_CNPJ_Fundo,
								SUM(Valor_Total)	Valor_Total
						FROM	Solis.Carteira.BTG_Portfolio_Investido
						GROUP BY	Data_Posicao,
									ID_CNPJ_Fundo)	BPI	ON	BPI.Data_Posicao = A.Data_Posicao
														AND	BPI.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo

			LEFT JOIN (	SELECT	Data_Posicao		Data_Posicao,
								ID_CNPJ_Fundo		ID_CNPJ_Fundo,
								SUM(Aj_Total)		Valor_Total
						FROM	Solis.Carteira.BTG_Bmf
						GROUP BY	Data_Posicao,
									ID_CNPJ_Fundo)	BMF	ON	BMF.Data_Posicao = A.Data_Posicao
														AND	BMF.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo

			LEFT JOIN (	SELECT	Data_Posicao		Data_Posicao,
								ID_CNPJ_Fundo		ID_CNPJ_Fundo,
								SUM(Valor_Total)	Valor_Total
						FROM	Solis.Carteira.BTG_Despesas
						WHERE	Valor_Total < 0
						GROUP BY	Data_Posicao,
									ID_CNPJ_Fundo)	VPR1	ON	VPR1.Data_Posicao = A.Data_Posicao
															AND	VPR1.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo
			LEFT JOIN (	SELECT	Data_Posicao		Data_Posicao,
								ID_CNPJ_Fundo		ID_CNPJ_Fundo,
								SUM(Valor_Total)	Valor_Total
						FROM	Solis.Carteira.BTG_Despesas
						WHERE	Valor_Total > 0
						GROUP BY	Data_Posicao,
									ID_CNPJ_Fundo)	VPR2	ON	VPR2.Data_Posicao = A.Data_Posicao
															AND	VPR2.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo
			LEFT JOIN (SELECT	A.Data_Posicao		Data_Posicao,
								A.ID_CNPJ_Fundo		ID_CNPJ_Fundo,
								A.Percentual_CDI_Dia,
								A.Percentual_CDI_Mes,
								A.Percentual_CDI_Ano,
								A.Rentabilidade_Dia,
								A.Rentabilidade_Mes,
								A.Rentabilidade_Ano
						FROM	Solis.Carteira.BTG_Rentabilidade	A	WITH(NOLOCK)
								LEFT JOIN Isys.Cota.Cota_Cadastro	B	ON	B.ID_Cota_Cadastro = A.ID_Cota_Cadastro
						WHERE	B.ID_Cota_Tipo = '3' /* SUBORDINADA */)	RENT	ON	RENT.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo
																				AND	RENT.Data_Posicao = A.Data_Posicao
	
	GROUP BY	A.ID_CNPJ_Fundo,
				C.Tipo_Fundo_Abreviado,
				B.Nome_Fundo,
				C1.Tipo_Condominio,
				C2.Classificacao_Solis,
				C3.Classificacao_Categoria_Solis,
				A.Data_Posicao,
				SB.Valor_Liquido,
				SR.Valor_Liquido,
				MZ.Valor_Liquido,
				RENT.Rentabilidade_Dia,
				RENT.Rentabilidade_Mes,
				RENT.Rentabilidade_Ano,
				RENT.Percentual_CDI_Dia,
				RENT.Percentual_CDI_Mes,
				RENT.Percentual_CDI_Ano,
				RF.Valor_Total,
				BA.Valor_Total,
				BMF.Valor_Total,
				BPI.Valor_Total,
				VPR1.Valor_Total,
				VPR2.Valor_Total
				
-- OK	select * from Solis.Carteira.BTG_Acoes
-- OK	select * from Solis.Carteira.BTG_Bmf
-- OK	select * from Solis.Carteira.BTG_Despesas
-- OK	select * from Solis.Carteira.BTG_Portfolio_Investido
-- OK	select * from Solis.Carteira.BTG_Renda_Fixa
-- OK	select * from Solis.Carteira.BTG_Rentabilidade
-- select * from Solis.Carteira.BTG_Resumo
									),

FundoVORTX AS	----------------------------------------------------------------------------------------------------------------------------------------------------------------
(	SELECT	A.ID_CNPJ_Fundo														ID_CNPJ_Fundo,
			C.Tipo_Fundo_Abreviado												Tipo_Fundo,
			B.Nome_Fundo														Nome_Fundo,
			C1.Tipo_Condominio													Tipo_Condominio,
			C2.Classificacao_Solis												Classificacao_Solis,
			C3.Classificacao_Categoria_Solis									Classificacao_Categoria_Solis,
			A.Data_Posicao														Data_Posicao,
			ISNULL(SB.Valor_Total, 0.00)										Subordinada,
			ISNULL(SR.Valor_Total, 0.00)										Senior,
			ISNULL(MZ.Valor_Total, 0.00)										Mezanino,
			ISNULL(SUM(A.Valor_Total), 0.00)									Patrimonio,
	
			ISNULL(RF.Valor_Total, 0.00)										Renda_Fixa,
			ISNULL(0.00, 0.00)													Renda_Variavel,
			null																Cota_Fundos,
			ISNULL(DC.Valor_Total, 0.00)										Direitos_Creditorios,
			null																PDD,
			ISNULL(0.00, 0.00)													Imoveis,
			ISNULL(0.00, 0.00)													BMF,
			ISNULL(VCX.Valor_Total, 0.00)										Conta_Corrente,
			ISNULL(0.00, 0.00)													Outros,
			null																Valor_Indentificar,
			ISNULL(0.00, 0.00)													Swap,
			ISNULL(0.00, 0.00)													Valor_Converter,
			ISNULL(VPR1.Valor_Total, 0.00)										Valor_Pagar,
			ISNULL(VPR2.Valor_Total, 0.00)										Valor_Receber,

			null																Conciliacao1,
			null																Conciliacao2,

			null																Cota_Dia,
			null																Cota_Mes,
			null																Cota_Ano,
			null																Variacao_Dia,
			null																Variacao_Mes,
			null																Variacao_Ano
	
	FROM	(	SELECT	Data_Posicao		Data_Posicao,
						ID_CNPJ_Fundo		ID_CNPJ_Fundo,
						SUM(Valor_Total)	Valor_Total
				FROM	Solis.Carteira.VORTX_InfoGerais 
				GROUP BY	Data_Posicao,
							ID_CNPJ_Fundo)							A	
			LEFT JOIN Isys.Cadastro.Fundo							B	ON	B.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo	COLLATE Latin1_General_CI_AS
			LEFT JOIN Isys.Parametro.Tipo_fundo						C	ON	C.ID_Tipo_Fundo = B.ID_Tipo_Fundo
			LEFT JOIN Isys.Parametro.Tipo_Condominio				C1	ON	C1.ID_Tipo_Condominio = B.ID_Condominio
			LEFT JOIN Isys.Parametro.Classificacao_Solis			C2	ON	C2.ID_Classificacao_Solis = B.ID_Classificacao_Solis
			LEFT JOIN Isys.Parametro.Classificacao_Categoria_Solis	C3	ON	C3.ID_Classificacao_Categoria_Solis = B.ID_Classificacao_Categoria_Solis

			LEFT JOIN (	SELECT	A.Data_Posicao		Data_Posicao,
								A.ID_CNPJ_Fundo		ID_CNPJ_Fundo,
								SUM(Valor_Total)	Valor_Total
						FROM	Solis.Carteira.VORTX_InfoGerais		A	WITH(NOLOCK)
								LEFT JOIN Isys.Cota.Cota_Cadastro	B	ON	B.ID_Cota_Cadastro = A.ID_Cota_Cadastro
						WHERE	B.ID_Cota_Tipo = '1' /* SENIOR */
						GROUP BY	A.Data_Posicao,
									A.ID_CNPJ_Fundo)	SR	ON	SR.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo
															AND SR.Data_Posicao = A.Data_Posicao
			LEFT JOIN (	SELECT	A.Data_Posicao		Data_Posicao,
								A.ID_CNPJ_Fundo		ID_CNPJ_Fundo,
								SUM(Valor_Total)	Valor_Total
						FROM	Solis.Carteira.VORTX_InfoGerais		A	WITH(NOLOCK)
								LEFT JOIN Isys.Cota.Cota_Cadastro	B	ON	B.ID_Cota_Cadastro = A.ID_Cota_Cadastro
						WHERE	B.ID_Cota_Tipo = '2' /* MEZANINO */
						GROUP BY	A.Data_Posicao,
									A.ID_CNPJ_Fundo)	MZ	ON	MZ.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo
															AND MZ.Data_Posicao = A.Data_Posicao
			LEFT JOIN (	SELECT	A.Data_Posicao		Data_Posicao,
								A.ID_CNPJ_Fundo		ID_CNPJ_Fundo,
								SUM(Valor_Total)	Valor_Total
						FROM	Solis.Carteira.VORTX_InfoGerais		A	WITH(NOLOCK)
								LEFT JOIN Isys.Cota.Cota_Cadastro	B	ON	B.ID_Cota_Cadastro = A.ID_Cota_Cadastro
						WHERE	B.ID_Cota_Tipo = '3' /* SUBORDINADA */
						GROUP BY	A.Data_Posicao,
									A.ID_CNPJ_Fundo)	SB	ON	SB.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo
															AND SB.Data_Posicao = A.Data_Posicao

			LEFT JOIN (	SELECT	A.Data_Posicao		Data_Posicao,
								A.ID_CNPJ_Fundo		ID_CNPJ_Fundo,
								A.ID_Cota_Cadastro	ID_Cota_Cadastro,
								A.Tipo				Tipo,
								SUM(A.Valor_Total)	Valor_Total
						FROM	(	SELECT	A.Data_Posicao				Data_Posicao,
											A.ID_CNPJ_Fundo				ID_CNPJ_Fundo,
											A.ID_Cota_Cadastro			ID_Cota_Cadastro,
											A.Tipo						Tipo,
											SUM(A.Valor_Mercado_Atual)	Valor_Total
									
									FROM	Solis.Carteira.VORTX_Renda_Fixa		A	WITH(NOLOCK)
											LEFT JOIN Isys.Cota.Cota_Cadastro	B	ON	B.ID_Cota_Cadastro = A.ID_Cota_Cadastro
									WHERE	B.ID_Cota_Tipo = '3' /* SUBORDINADA */
									GROUP BY	A.Data_Posicao,
												A.ID_CNPJ_Fundo,
												A.ID_Cota_Cadastro,
												A.Tipo
									UNION
									SELECT	A.Data_Posicao,
											A.ID_CNPJ_Fundo,
											A.ID_Cota_Cadastro,
											A.Tipo,
											SUM(A.Mercado_Atual)	Valor_Total
									FROM	Solis.Carteira.VORTX_Compromissada	A	WITH(NOLOCK)
											LEFT JOIN Isys.Cota.Cota_Cadastro	B	ON	B.ID_Cota_Cadastro = A.ID_Cota_Cadastro
									WHERE	B.ID_Cota_Tipo = '3' /* SUBORDINADA */
									GROUP BY	A.Data_Posicao,
												A.ID_CNPJ_Fundo,
												A.ID_Cota_Cadastro,
												A.Tipo)	A
						GROUP BY	A.Data_Posicao,
									A.ID_CNPJ_Fundo,
									A.ID_Cota_Cadastro,
									A.Tipo)	RF	ON	RF.Data_Posicao = A.Data_Posicao
												AND RF.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo
						
			LEFT JOIN (	SELECT	A.Data_Posicao				Data_Posicao,
								A.ID_CNPJ_Fundo				ID_CNPJ_Fundo,
								SUM(Valor)	Valor_Total
						FROM	Solis.Carteira.VORTX_Pagar_Receber	A	WITH(NOLOCK)
								LEFT JOIN Isys.Cota.Cota_Cadastro	B	ON	B.ID_Cota_Cadastro = A.ID_Cota_Cadastro
						WHERE	B.ID_Cota_Tipo = '3' /* SUBORDINADA */
								AND A.Detalhe = 'DIREITO CREDITÓRIO'
								AND (A.Descricao NOT LIKE '%MEZ%'
									 AND A.Descricao NOT LIKE '%SEN%')
						GROUP BY	A.Data_Posicao,
									A.ID_CNPJ_Fundo)	DC	ON	DC.Data_Posicao = A.Data_Posicao
															AND DC.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo


			LEFT JOIN (	SELECT	A.Data_Posicao				Data_Posicao,
								A.ID_CNPJ_Fundo				ID_CNPJ_Fundo,
								SUM(Valor)					Valor_Total
						FROM	Solis.Carteira.VORTX_Pagar_Receber	A	WITH(NOLOCK)
								LEFT JOIN Isys.Cota.Cota_Cadastro	B	ON	B.ID_Cota_Cadastro = A.ID_Cota_Cadastro
						WHERE	B.ID_Cota_Tipo = '3' /* SUBORDINADA */
								AND (A.Descricao NOT LIKE '%MEZ%'
									 AND A.Descricao NOT LIKE '%SEN%')
								AND	A.ID_Carteira_Sistema =	'44' /*Pagar*/
						GROUP BY	A.Data_Posicao,
									A.ID_CNPJ_Fundo)	VPR1	ON	VPR1.Data_Posicao = A.Data_Posicao
																AND VPR1.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo

			LEFT JOIN (	SELECT	A.Data_Posicao				Data_Posicao,
								A.ID_CNPJ_Fundo				ID_CNPJ_Fundo,
								SUM(Valor)					Valor_Total
						FROM	Solis.Carteira.VORTX_Pagar_Receber	A	WITH(NOLOCK)
								LEFT JOIN Isys.Cota.Cota_Cadastro	B	ON	B.ID_Cota_Cadastro = A.ID_Cota_Cadastro
						WHERE	B.ID_Cota_Tipo = '3' /* SUBORDINADA */
								AND (A.Descricao NOT LIKE '%MEZ%'
									 AND A.Descricao NOT LIKE '%SEN%')
								AND	A.ID_Carteira_Sistema =	'45' /*Receber*/
						GROUP BY	A.Data_Posicao,
									A.ID_CNPJ_Fundo)	VPR2	ON	VPR2.Data_Posicao = A.Data_Posicao
																AND VPR2.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo

			LEFT JOIN (	SELECT	A.Data_Posicao				Data_Posicao,
								A.ID_CNPJ_Fundo				ID_CNPJ_Fundo,
								SUM(Valor)					Valor_Total
						FROM	Solis.Carteira.VORTX_Disponibilidade	A	WITH(NOLOCK)
								LEFT JOIN Isys.Cota.Cota_Cadastro		B	ON	B.ID_Cota_Cadastro = A.ID_Cota_Cadastro
						WHERE	B.ID_Cota_Tipo = '3' /* SUBORDINADA */
						GROUP BY	A.Data_Posicao,
									A.ID_CNPJ_Fundo)	VCX	ON	VCX.Data_Posicao = A.Data_Posicao
															AND VCX.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo	
	GROUP BY	A.ID_CNPJ_Fundo,
				C.Tipo_Fundo_Abreviado,
				B.Nome_Fundo,
				C1.Tipo_Condominio,
				C2.Classificacao_Solis,
				C3.Classificacao_Categoria_Solis,
				A.Data_Posicao,
				SB.Valor_Total,
				SR.Valor_Total,
				MZ.Valor_Total,
				RF.Valor_Total,
				VPR1.Valor_Total,
				VPR2.Valor_Total,
				DC.Valor_Total,
				VCX.Valor_Total



						
-- select * from Solis.Carteira.VORTX_Aluguel_Acoes			NÃO POSSUI DADOS
-- select * from Solis.Carteira.VORTX_Compromissada		
-- select * from Solis.Carteira.VORTX_Cotas_Aplicadas	
-- select * from Solis.Carteira.VORTX_Disponibilidade		OK
-- select * from Solis.Carteira.VORTX_Futuros				NÃO POSSUI DADOS
-- select * from Solis.Carteira.VORTX_Imoveis				NÃO POSSUI DADOS
-- select * from Solis.Carteira.VORTX_InfoGerais			OK
-- select * from Solis.Carteira.VORTX_Opcoes_Acoes			NÃO POSSUI DADOS
-- select * from Solis.Carteira.VORTX_Pagar_Receber			OK
-- select * from Solis.Carteira.VORTX_Renda_Fixa			OK
-- select * from Solis.Carteira.VORTX_Renda_Variavel		NÃO POSSUI DADOS
-- select * from Solis.Carteira.VORTX_Swap					NÃO POSSUI DADOS
									),
						

FundoTOTVS AS	----------------------------------------------------------------------------------------------------------------------------------------------------------------
(	SELECT	A.ID_CNPJ_Fundo																				ID_CNPJ_Fundo,
			C.Tipo_Fundo_Abreviado																		Tipo_Fundo,
			B.Nome_Fundo																				Nome_Fundo,
			C1.Tipo_Condominio																			Tipo_Condominio,
			C2.Classificacao_Solis																		Classificacao_Solis,
			C3.Classificacao_Categoria_Solis															Classificacao_Categoria_Solis,
			A.Data_Posicao																				Data_Posicao,
			ISNULL(A.Valor_Patrimonio, 0.00)															Subordinada,
			ISNULL(SR.Valor_Liquido, 0.00)																Senior,
			ISNULL(MZ.Valor_Liquido, 0.00)																Mezanino,
			(ISNULL(A.Valor_Patrimonio, 0.00)
			+ISNULL(SR.Valor_Liquido, 0.00)
			+ISNULL(MZ.Valor_Liquido, 0.00))															Patrimonio,
	
			null																						Renda_Fixa,
			null																						Renda_Variavel,
			null																						Cota_Fundos,
			null																						Direitos_Creditorios,
			ISNULL(VPDD.Valor_Total, 0.00)																PDD,
			ISNULL(VIMO.Valor_Total, 0.00)																Imoveis,
			null																						BMF,
			ISNULL(A.Valor_Tesouraria, 0.00)															Conta_Corrente,
			null																						Outros,
			null																						Valor_Indentificar,
			ISNULL(0.0, 0.00)																			Swap,
			ISNULL(0.0, 0.00)																			Valor_Converter,
			ISNULL(VPR1.Valor_Total, 0.00)																Valor_Pagar,
			ISNULL(VPR2.Valor_Total, 0.00)																Valor_Receber,

			null																						Conciliacao1,
			null																						Conciliacao2,

			ISNULL(RENT1.Variacao_Diaria, 0.00)															Cota_Dia,
			ISNULL(RENT1.Variacao_Mensal, 0.00)															Cota_Mes,
			ISNULL(RENT1.Variacao_Anual, 0.00)															Cota_Ano,
			ISNULL(CASE WHEN RENT1.Variacao_Diaria IS NULL
						  OR RENT1.Variacao_Diaria = 0
						THEN 0
						ELSE RENT1.Variacao_Diaria/RENT2.Variacao_Diaria
					END, 0.00)																			Variacao_Dia,
			ISNULL(CASE WHEN RENT1.Variacao_Mensal IS NULL
						  OR RENT1.Variacao_Mensal = 0
						THEN 0
						ELSE RENT1.Variacao_Mensal/RENT2.Variacao_Mensal
					END, 0.00)																			Variacao_Mes,
			ISNULL(CASE WHEN RENT1.Variacao_Anual IS NULL
						  OR RENT1.Variacao_Anual = 0
						THEN 0
						ELSE RENT1.Variacao_Anual/RENT2.Variacao_Anual
					END, 0.00)																			Variacao_Ano
	
	FROM	Solis.Carteira.TOTVS_Patrimonio 						A	WITH(NOLOCK)
			LEFT JOIN Isys.Cadastro.Fundo							B	ON	B.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo	COLLATE Latin1_General_CI_AS
			LEFT JOIN Isys.Parametro.Tipo_fundo						C	ON	C.ID_Tipo_Fundo = B.ID_Tipo_Fundo
			LEFT JOIN Isys.Parametro.Tipo_Condominio				C1	ON	C1.ID_Tipo_Condominio = B.ID_Condominio
			LEFT JOIN Isys.Parametro.Classificacao_Solis			C2	ON	C2.ID_Classificacao_Solis = B.ID_Classificacao_Solis
			LEFT JOIN Isys.Parametro.Classificacao_Categoria_Solis	C3	ON	C3.ID_Classificacao_Categoria_Solis = B.ID_Classificacao_Categoria_Solis

			LEFT JOIN Isys.Cota.Cota_Cadastro						D	ON	D.ID_Cota_Cadastro = A.ID_Cota_Cadastro
			LEFT JOIN (	SELECT	A.Data_Posicao			Data_Posicao,
								A.ID_CNPJ_Fundo			ID_CNPJ_Fundo,
								A.ID_Cota_Cadastro		ID_Cota_Cadastro,
								-SUM(A.Valor_Liquido)	Valor_Liquido
						 FROM	Solis.Carteira.TOTVS_Renda_Fixa		A	WITH(NOLOCK)
								LEFT JOIN Isys.Cota.Cota_Cadastro	B	ON	B.ID_Cota_Cadastro = A.ID_Cota_Cadastro
						 WHERE	A.Conta IN ('SRP')
								AND B.ID_Cota_Tipo = '3'
						 GROUP BY	A.Data_Posicao,
									A.ID_CNPJ_Fundo,
									A.ID_Cota_Cadastro)	SR	ON	SR.Data_Posicao = A.Data_Posicao
															AND SR.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo
															AND SR.ID_Cota_Cadastro = A.ID_Cota_Cadastro
			LEFT JOIN (	SELECT	A.Data_Posicao			Data_Posicao,
								A.ID_CNPJ_Fundo			ID_CNPJ_Fundo,
								A.ID_Cota_Cadastro		ID_Cota_Cadastro,
								-SUM(A.Valor_Liquido)	Valor_Liquido
						 FROM	Solis.Carteira.TOTVS_Renda_Fixa		A	WITH(NOLOCK)
								LEFT JOIN Isys.Cota.Cota_Cadastro	B	ON	B.ID_Cota_Cadastro = A.ID_Cota_Cadastro
						 WHERE	A.Conta IN ('MEZAN')
								AND B.ID_Cota_Tipo = '3'
						 GROUP BY	A.Data_Posicao,
									A.ID_CNPJ_Fundo,
									A.ID_Cota_Cadastro)	MZ	ON	MZ.Data_Posicao = A.Data_Posicao
															AND MZ.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo
															AND MZ.ID_Cota_Cadastro = A.ID_Cota_Cadastro
			LEFT JOIN (	SELECT	A.ID_CNPJ_Fundo,
								A.Data_Posicao,									
								A.Variacao_Diaria,
								A.Variacao_Mensal,
								A.Variacao_Anual
						FROM	Solis.Carteira.TOTVS_Rentabilidade	A
								LEFT JOIN Isys.Cota.Cota_Cadastro	B	ON	B.ID_Cota_Cadastro = A.ID_Cota_Cadastro
						WHERE	B.ID_Cota_Tipo = '3'
								AND A.Indexador = 'COTA')	RENT1	ON	RENT1.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo
																	AND RENT1.Data_Posicao = A.Data_Posicao
			LEFT JOIN (	SELECT	A.ID_CNPJ_Fundo,
								A.Data_Posicao,									
								A.Variacao_Diaria,
								A.Variacao_Mensal,
								A.Variacao_Anual
						FROM	Solis.Carteira.TOTVS_Rentabilidade	A
								LEFT JOIN Isys.Cota.Cota_Cadastro	B	ON	B.ID_Cota_Cadastro = A.ID_Cota_Cadastro
						WHERE	B.ID_Cota_Tipo = '3'
								AND A.Indexador = 'CDI')	RENT2	ON	RENT2.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo
																	AND RENT2.Data_Posicao = A.Data_Posicao

			LEFT JOIN (	SELECT	A.Data_Posicao			Data_Posicao,
								A.ID_CNPJ_Fundo			ID_CNPJ_Fundo,
								A.ID_Cota_Cadastro		ID_Cota_Cadastro,
								-SUM(A.Valor_Total)		Valor_Total
						 FROM	Solis.Carteira.TOTVS_Contas_Pagar_Receber	A	WITH(NOLOCK)
								LEFT JOIN Isys.Cota.Cota_Cadastro			B	ON	B.ID_Cota_Cadastro = A.ID_Cota_Cadastro
						 WHERE	B.ID_Cota_Tipo = '3'
								AND A.Valor_Total >= 0
						 GROUP BY	A.Data_Posicao,
									A.ID_CNPJ_Fundo,
									A.ID_Cota_Cadastro)	VPR1	ON	VPR1.Data_Posicao = A.Data_Posicao
																AND VPR1.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo
																AND VPR1.ID_Cota_Cadastro = A.ID_Cota_Cadastro

			LEFT JOIN (	SELECT	A.Data_Posicao			Data_Posicao,
								A.ID_CNPJ_Fundo			ID_CNPJ_Fundo,
								A.ID_Cota_Cadastro		ID_Cota_Cadastro,
								-SUM(A.Valor_Total)		Valor_Total
						 FROM	Solis.Carteira.TOTVS_Contas_Pagar_Receber	A	WITH(NOLOCK)
								LEFT JOIN Isys.Cota.Cota_Cadastro			B	ON	B.ID_Cota_Cadastro = A.ID_Cota_Cadastro
						 WHERE	B.ID_Cota_Tipo = '3'
								AND A.Valor_Total < 0
						 GROUP BY	A.Data_Posicao,
									A.ID_CNPJ_Fundo,
									A.ID_Cota_Cadastro)	VPR2	ON	VPR2.Data_Posicao = A.Data_Posicao
																AND VPR2.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo
																AND VPR2.ID_Cota_Cadastro = A.ID_Cota_Cadastro

			LEFT JOIN (	SELECT	A.Data_Posicao			Data_Posicao,
								A.ID_CNPJ_Fundo			ID_CNPJ_Fundo,
								A.ID_Cota_Cadastro		ID_Cota_Cadastro,
								SUM(A.Valor_Total)		Valor_Total
						 FROM	Solis.Carteira.TOTVS_Outros_Ativos	A	WITH(NOLOCK)
								LEFT JOIN Isys.Cota.Cota_Cadastro	B	ON	B.ID_Cota_Cadastro = A.ID_Cota_Cadastro
						 WHERE	B.ID_Cota_Tipo = '3'
								AND A.Codigo LIKE '%PDD%'
						 GROUP BY	A.Data_Posicao,
									A.ID_CNPJ_Fundo,
									A.ID_Cota_Cadastro)	VPDD	ON	VPDD.Data_Posicao = A.Data_Posicao
																AND VPDD.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo
																AND VPDD.ID_Cota_Cadastro = A.ID_Cota_Cadastro
			LEFT JOIN (	SELECT	A.Data_Posicao			Data_Posicao,
								A.ID_CNPJ_Fundo			ID_CNPJ_Fundo,
								A.ID_Cota_Cadastro		ID_Cota_Cadastro,
								SUM(A.Valor_Total)		Valor_Total
						 FROM	Solis.Carteira.TOTVS_Outros_Ativos	A	WITH(NOLOCK)
								LEFT JOIN Isys.Cota.Cota_Cadastro	B	ON	B.ID_Cota_Cadastro = A.ID_Cota_Cadastro
						 WHERE	B.ID_Cota_Tipo = '3'
								AND (A.Conta LIKE '%IMÓVEIS%'
									 OR A.Conta LIKE '%IMOVEIS%')
						 GROUP BY	A.Data_Posicao,
									A.ID_CNPJ_Fundo,
									A.ID_Cota_Cadastro)	VIMO	ON	VIMO.Data_Posicao = A.Data_Posicao
																AND VIMO.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo
																AND VIMO.ID_Cota_Cadastro = A.ID_Cota_Cadastro
																	 

	
	WHERE	D.ID_Cota_Tipo = '3' /* SUBORDINADA */
	
--		select * from Solis.Carteira.TOTVS_Conta_Corrente
-- ok	select * from Solis.Carteira.TOTVS_Contas_Pagar_Receber
--		select * from Solis.Carteira.TOTVS_Fundos_Investimento
-- ok	select * from Solis.Carteira.TOTVS_Outros_Ativos
-- ok	select * from Solis.Carteira.TOTVS_Patrimonio
--		select * from Solis.Carteira.TOTVS_Renda_Fixa
-- ok	select * from Solis.Carteira.TOTVS_Rentabilidade				
							),

FundoSINQIA AS		----------------------------------------------------------------------------------------------------------------------------------------------------------------
(	SELECT	SB.ID_CNPJ_Fundo																					ID_CNPJ_Fundo,
			C.Tipo_Fundo_Abreviado																				Tipo_Fundo,
			B.Nome_Fundo																						Nome_Fundo,
			C1.Tipo_Condominio																					Tipo_Condominio,
			C2.Classificacao_Solis																				Classificacao_Solis,
			C3.Classificacao_Categoria_Solis																	Classificacao_Categoria_Solis,
			SB.Data_Posicao																						Data_Posicao,
			ISNULL(SB.Valor_Liquido, 0.00)																		Subordinada,
			ISNULL(SR.Valor_Liquido, 0.00)																		Senior,
			ISNULL(MZ.Valor_Liquido, 0.00)																		Mezanino,
			ISNULL(SB.Valor_Liquido, 0.00) +
			ISNULL(SR.Valor_Liquido, 0.00) +
			ISNULL(MZ.Valor_Liquido, 0.00)																		Patrimonio,
	
			null																								Renda_Fixa,
			null																								Renda_Variavel,
			null																								Cota_Fundos,
			null																								Direitos_Creditorios,
			null																								PDD,
			null																								Imoveis,
			null																								BMF,
			null																								Conta_Corrente,
			null																								Outros,
			null																								Valor_Indentificar,
			null																								Swap,
			null																								Valor_Converter,
			null																								Valor_Pagar,
			null																								Valor_Receber,

			null																								Conciliacao1,
			null																								Conciliacao2,

		/*	ISNULL(RENT1.Dia, 0.00)																				*/ null Cota_Dia,
		/*	ISNULL(RENT1.Mes, 0.00)																				*/ null Cota_Mes,
		/*	ISNULL(RENT1.Ano, 0.00)																				*/ null Cota_Ano,
		/*	ISNULL(CASE WHEN RENT1.Dia = 0 OR RENT1.Dia IS NULL THEN 0	ELSE RENT1.Dia/Variacao_Dia	END, 0.00)	*/ null Variacao_Dia,
		/*	ISNULL(CASE WHEN RENT1.Mes = 0 OR RENT1.Mes IS NULL THEN 0	ELSE RENT1.Mes/Variacao_Mes	END, 0.00)	*/ null Variacao_Mes,
		/*	ISNULL(CASE WHEN RENT1.Ano = 0 OR RENT1.Ano IS NULL THEN 0	ELSE RENT1.Ano/Variacao_Ano	END, 0.00)	*/ null Variacao_Ano
	
	FROM	(	SELECT	A.Data_Posicao	Data_Posicao,
						A.ID_CNPJ_Fundo	ID_CNPJ_Fundo,
						SUM(A.VlMrc)	Valor_Liquido
				FROM	Solis.Carteira.SINQIA_Carteira		A	WITH(NOLOCK)
						LEFT JOIN Isys.Cota.Cota_Cadastro	B	ON	B.ID_Cota_Cadastro = A.ID_Cota_Cadastro
				WHERE	A.NoGrpN3 IN ('PATRIMONIO LIQUIDO')
						AND B.ID_Cota_Tipo = '3' /* SUBORDINADA */
				GROUP BY	A.Data_Posicao,
							A.ID_CNPJ_Fundo)						SB
			LEFT JOIN Isys.Cadastro.Fundo							B	ON	B.ID_CNPJ_Fundo = SB.ID_CNPJ_Fundo	COLLATE Latin1_General_CI_AS
			LEFT JOIN Isys.Parametro.Tipo_fundo						C	ON	C.ID_Tipo_Fundo = B.ID_Tipo_Fundo
			LEFT JOIN Isys.Parametro.Tipo_Condominio				C1	ON	C1.ID_Tipo_Condominio = B.ID_Condominio
			LEFT JOIN Isys.Parametro.Classificacao_Solis			C2	ON	C2.ID_Classificacao_Solis = B.ID_Classificacao_Solis
			LEFT JOIN Isys.Parametro.Classificacao_Categoria_Solis	C3	ON	C3.ID_Classificacao_Categoria_Solis = B.ID_Classificacao_Categoria_Solis

			LEFT JOIN (	SELECT	A.Data_Posicao	Data_Posicao,
								A.ID_CNPJ_Fundo	ID_CNPJ_Fundo,
						        -SUM(A.VlMrc)	Valor_Liquido
						FROM	Solis.Carteira.SINQIA_Carteira		A	WITH(NOLOCK)
								LEFT JOIN Isys.Cota.Cota_Cadastro	B	ON	B.ID_Cota_Cadastro = A.ID_Cota_Cadastro
						WHERE	A.NoGrpN3 IN ('PL COTA SÊNIOR')
								AND B.ID_Cota_Tipo = '3' /* SUBORDINADA */
						GROUP BY	A.Data_Posicao,
									A.ID_CNPJ_Fundo)	SR	ON	SR.ID_CNPJ_Fundo = SB.ID_CNPJ_Fundo	
															AND SR.Data_Posicao = SB.Data_Posicao	
			LEFT JOIN (	SELECT	A.Data_Posicao	Data_Posicao,
								A.ID_CNPJ_Fundo	ID_CNPJ_Fundo,
						        -SUM(A.VlMrc)	Valor_Liquido
						FROM	Solis.Carteira.SINQIA_Carteira		A	WITH(NOLOCK)
								LEFT JOIN Isys.Cota.Cota_Cadastro	B	ON	B.ID_Cota_Cadastro = A.ID_Cota_Cadastro
						WHERE	A.NoGrpN3 IN ('PL - COTA MEZANINO')
								AND B.ID_Cota_Tipo = '3' /* SUBORDINADA */
						GROUP BY	A.Data_Posicao,
									A.ID_CNPJ_Fundo)	MZ	ON	MZ.ID_CNPJ_Fundo = SB.ID_CNPJ_Fundo
															AND MZ.Data_Posicao = SB.Data_Posicao
/*
			LEFT JOIN (	SELECT	Data_Posicao,
								ID_CNPJ_Fundo,
								Dia,
								Mes,
								Ano
						FROM	Solis.Carteira.SINQIA_Carteira
						WHERE	NoGrpN3 = 'PATRIMONIO LIQUIDO')		RENT1	ON	RENT1.ID_CNPJ_Fundo = SB.ID_CNPJ_Fundo
																			AND RENT1.Data_Posicao = SB.Data_Posicao
			LEFT JOIN (	SELECT	Data_Posicao,
								ID_CNPJ_Fundo,
								Indice,
								Variacao_Dia,
								Variacao_Mes,
								Variacao_Ano
						FROM	Solis.Carteira.SINQIA_Rentabilidade
						WHERE	Indice = 'CDI')		RENT2	ON	RENT2.ID_CNPJ_Fundo = SB.ID_CNPJ_Fundo
																AND RENT2.Data_Posicao = SB.Data_Posicao
*/
-- 	SELECT * FROM Solis.Carteira.SINQIA_Carteira
--- SELECT * FROM Solis.Carteira.SINQIA_Rentabilidade
																						),
				
FundoPMS AS		----------------------------------------------------------------------------------------------------------------------------------------------------------------
(	SELECT	A.ID_CNPJ_Fundo															ID_CNPJ_Fundo,
			C.Tipo_Fundo_Abreviado													Tipo_Fundo,
			B.Nome_Fundo															Nome_Fundo,
			C1.Tipo_Condominio														Tipo_Condominio,
			C2.Classificacao_Solis													Classificacao_Solis,
			C3.Classificacao_Categoria_Solis										Classificacao_Categoria_Solis,
			A.Data_Posicao															Data_Posicao,
			ISNULL(SB.Valor_Liquido, 0.00)											Subordinada,
			ISNULL(SR.Valor_Liquido, 0.00)											Senior,
			ISNULL(MZ.Valor_Liquido, 0.00)											Mezanino,
			ISNULL(SUM(A.Valor_Patrimonio_Atual), 0.00)								Patrimonio,
	
			null																	Renda_Fixa,
			null																	Renda_Variavel,
			null																	Cota_Fundos,
			null																	Direitos_Creditorios,
			null																	PDD,
			null																	Imoveis,
			null																	BMF,
			null																	Conta_Corrente,
			null																	Outros,
			null																	Valor_Indentificar,
			null																	Swap,
			null																	Valor_Converter,
			null																	Valor_Pagar,
			null																	Valor_Receber,

			null																	Conciliacao1,
			null																	Conciliacao2,
			ISNULL(RENT1.Variacao_Dia, 0.00)										Cota_Dia,
			null																	Cota_Mes,
			null																	Cota_Ano,
			null																	Variacao_Dia,
			null																	Variacao_Mes,
			null																	Variacao_Ano
	
	FROM	(	SELECT	Data_Posicao				Data_Posicao,
						ID_CNPJ_Fundo				ID_CNPJ_Fundo,
						SUM(Valor_Patrimonio_Atual)	Valor_Patrimonio_Atual
				FROM	Solis.Carteira.PMS_Resumo
				GROUP BY	Data_Posicao,
							ID_CNPJ_Fundo)							A
			LEFT JOIN Isys.Cadastro.Fundo							B	ON	B.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo	COLLATE Latin1_General_CI_AS
			LEFT JOIN Isys.Parametro.Tipo_fundo						C	ON	C.ID_Tipo_Fundo = B.ID_Tipo_Fundo
			LEFT JOIN Isys.Parametro.Tipo_Condominio				C1	ON	C1.ID_Tipo_Condominio = B.ID_Condominio
			LEFT JOIN Isys.Parametro.Classificacao_Solis			C2	ON	C2.ID_Classificacao_Solis = B.ID_Classificacao_Solis
			LEFT JOIN Isys.Parametro.Classificacao_Categoria_Solis	C3	ON	C3.ID_Classificacao_Categoria_Solis = B.ID_Classificacao_Categoria_Solis

			LEFT JOIN (	SELECT	A.Data_Posicao					Data_Posicao,
								A.ID_CNPJ_Fundo					ID_CNPJ_Fundo,
								SUM(A.Valor_Patrimonio_Atual)	Valor_Liquido
					--	SELECT	*
						FROM	Solis.Carteira.PMS_Resumo			A	WITH(NOLOCK)
								LEFT JOIN Isys.Cota.Cota_Cadastro	B	ON	B.ID_Cota_Cadastro = A.ID_Cota_Cadastro
						WHERE	B.ID_Cota_Tipo = '1' /* SÊNIOR */
						GROUP BY	A.Data_Posicao,
									A.ID_CNPJ_Fundo)	SR	ON	SR.Data_Posicao = A.Data_Posicao
															AND SR.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo
			LEFT JOIN (	SELECT	A.Data_Posicao					Data_Posicao,
								A.ID_CNPJ_Fundo					ID_CNPJ_Fundo,
								SUM(A.Valor_Patrimonio_Atual)	Valor_Liquido
						FROM	Solis.Carteira.PMS_Resumo			A	WITH(NOLOCK)
								LEFT JOIN Isys.Cota.Cota_Cadastro	B	ON	B.ID_Cota_Cadastro = A.ID_Cota_Cadastro
						WHERE	B.ID_Cota_Tipo = '2' /* MEZANINO */
						GROUP BY	A.Data_Posicao,
									A.ID_CNPJ_Fundo)	MZ	ON	MZ.Data_Posicao = A.Data_Posicao
															AND MZ.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo
			LEFT JOIN (	SELECT	A.Data_Posicao					Data_Posicao,
								A.ID_CNPJ_Fundo					ID_CNPJ_Fundo,
								SUM(A.Valor_Patrimonio_Atual)	Valor_Liquido
						FROM	Solis.Carteira.PMS_Resumo			A	WITH(NOLOCK)
								LEFT JOIN Isys.Cota.Cota_Cadastro	B	ON	B.ID_Cota_Cadastro = A.ID_Cota_Cadastro
						WHERE	B.ID_Cota_Tipo = '3' /* SUBORDINADA */
						GROUP BY	A.Data_Posicao,
									A.ID_CNPJ_Fundo)	SB	ON	SB.Data_Posicao = A.Data_Posicao
															AND SB.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo
			LEFT JOIN (	SELECT	Data_Posicao,
								ID_CNPJ_Fundo,
								ID_Cota_Cadastro,
								Variacao_Dia
						FROM	Solis.Carteira.PMS_Resumo
						WHERE	Carteira = 'SUBORDINADA')	RENT1	ON	RENT1.Data_Posicao = A.Data_Posicao
																	AND RENT1.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo
	
	
	GROUP BY	A.ID_CNPJ_Fundo,
				C.Tipo_Fundo_Abreviado,
				B.Nome_Fundo,
				C1.Tipo_Condominio,
				C2.Classificacao_Solis,
				C3.Classificacao_Categoria_Solis,
				A.Data_Posicao,
				SB.Valor_Liquido,
				SR.Valor_Liquido,
				MZ.Valor_Liquido,
				RENT1.Variacao_Dia
	
-- SELECT	* FROM	Solis.Carteira.PMS_Estoque
-- SELECT	* FROM	Solis.Carteira.PMS_Provisoes
-- SELECT	* FROM	Solis.Carteira.PMS_Resumo									
							
)
/*
-- TESTE		----------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT	A.ID_CNPJ_Fundo										Fundo_CNPJ,
		A.Tipo_Fundo +' '+A.Nome_Fundo						Fundo_Tipo_Nome,
		(	SELECT	TOP(1) X.Nome_Fantasia
			FROM	AdministradorNome	X
			WHERE	X.Data_Inicio <= A.Data_Posicao
					AND X.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo
					COLLATE Latin1_General_CI_AS
			ORDER BY	X.Data_Inicio	DESC)				Administrador,
		(	SELECT	TOP(1) X.Nome_Fantasia
			FROM	GestorNome	X
			WHERE	X.Data_Inicio <= A.Data_Posicao
					AND X.ID_CNPJ_Fundo = A.ID_CNPJ_Fundo
					COLLATE Latin1_General_CI_AS
			ORDER BY	X.Data_Inicio	DESC)				Gestor
		
FROM	(	SELECT * FROM FundoMAPS			UNION
			SELECT * FROM FundoBTG			UNION
			SELECT * FROM FundoVORTX		UNION
			SELECT * FROM FundoTOTVS		UNION
			SELECT * FROM FundoSINQIA		UNION
			SELECT * FROM FundoPMS			)	A

-- WHERE	A.Nome_Fundo like '%IMPETUS%'
ORDER BY	Nome_Fundo
*/


-- RESULTADO	----------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT	(	SELECT	TOP(1) X.Estruturacao_Nome
			FROM	BdTeste.Monitoramento.FundoEstruturacao	X
			WHERE	X.Data_Inicio <= A.Data_Posicao
					AND X.Composicao = 'ADMINISTRADOR'
					AND X.Fundo_CNPJ = A.ID_CNPJ_Fundo
					COLLATE Latin1_General_CI_AS
			ORDER BY	X.Data_Inicio	DESC)				Administrador_Nome,
		(	SELECT	TOP(1) X.Estruturacao_Nome
			FROM	BdTeste.Monitoramento.FundoEstruturacao	X
			WHERE	X.Data_Inicio <= A.Data_Posicao
					AND X.Composicao = 'GESTOR'
					AND X.Fundo_CNPJ = A.ID_CNPJ_Fundo
					COLLATE Latin1_General_CI_AS
			ORDER BY	X.Data_Inicio	DESC)				Gestor_Nome,
		A.ID_CNPJ_Fundo										Fundo_CNPJ,
		A.Tipo_Fundo										Fundo_Tipo,
		A.Nome_Fundo										Fundo_Nome,
		A.Tipo_Fundo +' '+ A.Nome_Fundo						Fundo_Tipo_Nome,
		A.Tipo_Condominio									Fundo_Condominio,
		A.Classificacao_Solis								Fundo_Classificacao,
		A.Classificacao_Categoria_Solis						Fundo_Categoria,
		A.Data_Posicao										Data_Posicao,
		(	SELECT	Status_Dia
			FROM	Solis.Data.Data	X
			WHERE	X.Data_Posicao = A.Data_Posicao)		Data_Status,
		A.Subordinada										Subordinada_Valor,
		CASE WHEN A.Subordinada IS NULL
			   OR A.Subordinada = 0
			   OR A.Patrimonio IS NULL
			   OR A.Patrimonio = 0
			 THEN 0
			 ELSE A.Subordinada/A.Patrimonio
		END													Subordinada_PL,
		A.Senior											Senior_Valor,
		CASE WHEN A.Senior IS NULL
			   OR A.Senior = 0
			   OR A.Patrimonio IS NULL
			   OR A.Patrimonio = 0
			 THEN 0
			 ELSE A.Senior/A.Patrimonio
		END													Senior_PL,
		A.Mezanino											Mezanino_Valor,
		CASE WHEN A.Mezanino IS NULL
			   OR A.Mezanino = 0
			   OR A.Patrimonio IS NULL
			   OR A.Patrimonio = 0
			 THEN 0
			 ELSE A.Senior/A.Patrimonio
		END													Mezanino_PL,
		A.Patrimonio										Valor_Patrimonio,
		A.Renda_Fixa										Renda_Fixa_Valor,
		CASE WHEN A.Renda_Fixa IS NULL
			   OR A.Renda_Fixa = 0
			   OR A.Patrimonio IS NULL
			   OR A.Patrimonio = 0
			 THEN 0
			 ELSE A.Renda_Fixa/A.Patrimonio
		END													Renda_Fixa_PL,
		A.Renda_Variavel									Renda_Variavel_Valor,
		CASE WHEN A.Renda_Variavel IS NULL
			   OR A.Renda_Variavel = 0
			   OR A.Patrimonio IS NULL
			   OR A.Patrimonio = 0
			 THEN 0
			 ELSE A.Renda_Variavel/A.Patrimonio
		END													Renda_Variavel_PL,
		A.Cota_Fundos										Cota_Fundos_Valor,
		CASE WHEN A.Cota_Fundos IS NULL
			   OR A.Cota_Fundos = 0
			   OR A.Patrimonio IS NULL
			   OR A.Patrimonio = 0
			 THEN 0
			 ELSE A.Cota_Fundos/A.Patrimonio
		END													Cota_Fundos_PL,
		A.Direitos_Creditorios								Direitos_Creditorios_Valor,
		CASE WHEN A.Direitos_Creditorios IS NULL
			   OR A.Direitos_Creditorios = 0
			   OR A.Patrimonio IS NULL
			   OR A.Patrimonio = 0
			 THEN 0
			 ELSE A.Direitos_Creditorios/A.Patrimonio
		END													Direitos_Creditorios_PL,
		A.PDD												PDD_Valor,
		CASE WHEN A.PDD IS NULL
			   OR A.PDD = 0
			   OR A.Patrimonio IS NULL
			   OR A.Patrimonio = 0
			 THEN 0
			 ELSE A.PDD/A.Patrimonio
		END													PDD_PL,
		A.Imoveis											Imoveis_Valor,
		CASE WHEN A.Imoveis IS NULL
			   OR A.Imoveis = 0
			   OR A.Patrimonio IS NULL
			   OR A.Patrimonio = 0
			 THEN 0
			 ELSE A.Imoveis/A.Patrimonio
		END													Imoveis_PL,
		A.BMF												BMF_Valor,
		CASE WHEN A.BMF IS NULL
			   OR A.BMF = 0
			   OR A.Patrimonio IS NULL
			   OR A.Patrimonio = 0
			 THEN 0
			 ELSE A.BMF/A.Patrimonio
		END													BMF_PL,
		A.Conta_Corrente									Conta_Corrente_Valor,
		CASE WHEN A.Conta_Corrente IS NULL
			   OR A.Conta_Corrente = 0
			   OR A.Patrimonio IS NULL
			   OR A.Patrimonio = 0
			 THEN 0
			 ELSE A.Conta_Corrente/A.Patrimonio
		END													Conta_Corrente_PL,
		A.Outros											Outros_Valor,
		CASE WHEN A.Outros IS NULL
			   OR A.Outros = 0
			   OR A.Patrimonio IS NULL
			   OR A.Patrimonio = 0
			 THEN 0
			 ELSE A.Outros/A.Patrimonio
		END													Outros_PL,
		A.Valor_Indentificar								Valor_Indentificar,
		CASE WHEN A.Valor_Indentificar IS NULL
			   OR A.Valor_Indentificar = 0
			   OR A.Patrimonio IS NULL
			   OR A.Patrimonio = 0
			 THEN 0
			 ELSE A.Valor_Indentificar/A.Patrimonio
		END													Valor_Indentificar_PL,
		A.Swap												Swap_Valor,
		CASE WHEN A.Swap IS NULL
			   OR A.Swap = 0
			   OR A.Patrimonio IS NULL
			   OR A.Patrimonio = 0
			 THEN 0
			 ELSE A.Swap/A.Patrimonio
		END													Swap_PL,
		A.Valor_Converter									Converter_Valor,
		CASE WHEN A.Valor_Converter IS NULL
			   OR A.Valor_Converter = 0
			   OR A.Patrimonio IS NULL
			   OR A.Patrimonio = 0
			 THEN 0
			 ELSE A.Valor_Converter/A.Patrimonio
		END													Converter_PL,
		A.Valor_Pagar										Pagar_Valor,
		CASE WHEN A.Valor_Pagar IS NULL
			   OR A.Valor_Pagar = 0
			   OR A.Patrimonio IS NULL
			   OR A.Patrimonio = 0
			 THEN 0
			 ELSE A.Valor_Pagar/A.Patrimonio
		END													Pagar_PL,
		A.Valor_Receber										Receber_Valor,
		CASE WHEN A.Valor_Receber IS NULL
			   OR A.Valor_Receber = 0
			   OR A.Patrimonio IS NULL
			   OR A.Patrimonio = 0
			 THEN 0
			 ELSE A.Valor_Receber/A.Patrimonio
		END													Receber_PL,

		A.Conciliacao1,
		A.Conciliacao2,

		A.Cota_Dia,
		A.Cota_Mes,
		A.Cota_Ano,
		A.Variacao_Dia,
		A.Variacao_Mes,
		A.Variacao_Ano,
		AVG(A.Patrimonio)
				OVER (PARTITION BY	A.ID_CNPJ_Fundo,
									FORMAT(A.Data_Posicao, 'yyyy-MM')
					  ORDER BY	A.Data_Posicao
				ROWS BETWEEN UNBOUNDED PRECEDING
						 AND CURRENT ROW)					Patrimonio_Media_Mes

FROM	(	SELECT * FROM FundoMAPS			UNION
			SELECT * FROM FundoBTG			UNION
			SELECT * FROM FundoVORTX		UNION
			SELECT * FROM FundoTOTVS		UNION
			SELECT * FROM FundoSINQIA		UNION
			SELECT * FROM FundoPMS			)	A

WHERE	A.Data_Posicao >= DATEADD(MONTH, -24, DATEADD(DAY, 1, EOMONTH(GETDATE(), -1)))
		AND A.Data_Posicao <= GETDATE()
--		AND	A.Nome_Fundo like '%IMPETUS%'

GO


