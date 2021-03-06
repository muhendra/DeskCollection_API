USE [MNC_GUI_SSS]
GO
/****** Object:  StoredProcedure [dbo].[sp_account_collection_insert]    Script Date: 27/01/2022 11:15:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_account_collection_insert]
(
	@p_id					int output
	,@p_account_no			nvarchar(25)
	,@p_collection_date		datetime
	,@p_cust_name			nvarchar(50) = ''
	,@p_result_code			nvarchar(10) --ubah parameter - Chandra - Thu, 02/Apr/2015 - 11:31 am 
	,@p_action_code			nvarchar(10) --ubah parameter - Chandra - Thu, 02/Apr/2015 - 11:31 am 
	,@p_remark				nvarchar(255)
	,@p_asal_action			nvarchar(10)
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(25)
	,@p_cre_ip_address		nvarchar(25)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(25)
	,@p_mod_ip_address		nvarchar(25)
	,@p_promise_date		datetime
	,@p_period				int
	-- Chandra - Tue, 16/Jun/2015 - 02:54 pm 
	,@p_c_code				nvarchar(6) = ''
) as
begin

	select	@p_cust_name = name
	from	ls_agreement
	where	lsagree = @p_account_no
	
	-- Audit Request (+) ------------------------------------------------
	declare @f_next_value		varchar(8000),
			@f_prev_value		varchar(8000),
			@menu_name			nvarchar(200), --(+) Ezra : 22-07-2017
			@table_name			nvarchar(200), --(+) Ezra : 22-07-2017
			@id_log				nvarchar(200)  --(+) Ezra : 22-07-2017

	-- hari - 6/21/2015 11:54:59 PM	update status JB
	if exists(SELECT 1 FROM dbo.ACCOUNT_COLLECTION where ACCOUNT_NO = @p_account_no and ACTION_ID = (select top 1 id from master_action where code = 'PTP') and IS_PROMISE_CALL = 0)
	BEGIN
		--(+) Ezra : 22-07-2017
		DECLARE @id_c INT

		--(+) Ezra : 22-07-2017
		DECLARE update_ac CURSOR READ_ONLY FOR
		SELECT	ID 
		FROM	ACCOUNT_COLLECTION
		where	ACCOUNT_NO = @p_account_no 
				AND ACTION_ID = (select top 1 id from master_action where code = 'PTP') 
				AND IS_PROMISE_CALL = 0

		OPEN	update_ac
		FETCH	update_ac
		INTO	@id_c

		WHILE	@@FETCH_STATUS = 0
		BEGIN
				
				SET @menu_name		= 'Desk Collection'
				SET @table_name		= 'ACCOUNT_COLLECTION'
				SET @id_log			= 'ID'
				SET	@menu_name		= UPPER(@menu_name)	
				SET @table_name		= UPPER(@table_name)	

				exec dbo.xsp_data_log_trx_get_value @table_name, @id_log, @id_c, @f_prev_value OUTPUT
				--============================================================================================================

				update	dbo.ACCOUNT_COLLECTION
				SET		IS_PROMISE_CALL = 1
				WHERE	ID = @id_c

				 -- Audit Request (+) ------------------------------------------------
				exec dbo.xsp_data_log_trx_get_value @table_name, @id_log, @id_c, @f_next_value output

				if @f_prev_value <> @f_next_value
					exec dbo.xsp_data_log_trx_insert @menu_name, @table_name, 'EDIT DATA', @f_prev_value, @f_next_value, @p_mod_date, @p_mod_by, @p_mod_ip_address
				------------------------------------------------------------------------

				FETCH	update_ac
				INTO	@id_c
		END
		
		CLOSE		update_ac
		DEALLOCATE	update_ac

		-- hari - 6/21/2015 11:58:10 PM	update tanggal collection = hari ini
		set @p_collection_date = @p_mod_date

	end  

	-- Chandra - Thu, 02/Apr/2015 - 11:30 am 
	if @p_action_code <> 'PTP' 
	begin
		set @p_promise_date = null	
		if @p_action_code = 'BPH' or @p_action_code = 'MSG'
			set @p_result_code = ''	
	end
    
	insert into account_collection
	(
		account_no,
		collection_date,
		cust_name,		
		result_id,
		ACTION_ID,
		remark,
		ASAL_ACTION,
		cre_date,
		cre_by,
		cre_ip_address,
		mod_date,
		mod_by,
		mod_ip_address,
		promise_date,
		period
	)
	values
	(
		@p_account_no,
		getdate(), --@p_collection_date,
		@p_cust_name,		
		(select	top 1 id from master_result where code = @p_result_code), -- Chandra - Thu, 02/Apr/2015 - 11:30 am 
		(select top 1 id from master_action where code = @p_action_code), -- Chandra - Thu, 02/Apr/2015 - 11:30 am 
		@p_remark,
		@p_asal_action,
		getdate(), --modified by Galaxi, 08-Jan-2019
		@p_cre_by,
		@p_cre_ip_address,
		getdate(), --modified by Galaxi, 08-Jan-2019
		@p_mod_by,
		@p_mod_ip_address,
		@p_promise_date,
		@p_period
	)
	set	@p_id = @@IDENTITY
	
	SET @menu_name		= 'Desk Collection - Result'
	SET @table_name		= 'account_collection'
	SET @id_log			= 'ID'
	SET	@menu_name		= UPPER(@menu_name)	
	SET @table_name		= UPPER(@table_name)	

  exec dbo.xsp_data_log_trx_get_value @table_name, @id_log, @p_id, @f_next_value output

  exec dbo.xsp_data_log_trx_insert @menu_name, @table_name, 'NEW DATA', '', @f_next_value, @p_cre_date, @p_cre_by, @p_cre_ip_address
  ----------------------------------------------------------------------------------------------

	declare		@type			nvarchar(1000),
				@action_id		nvarchar(100),
				@result_id		nvarchar(100),
				@hist_name		nvarchar(350),
				@hist_amtlease	numeric(16,2),
				@desk_col		nvarchar(20)
				--@head_coll		nvarchar(20)

	select		@action_id	= ISNULL(DESCRIPTION,'')
	from		MASTER_ACTION
	WHERE		code		= @p_action_code
	
	select		@result_id	= ISNULL(description,'')
	from		master_result	
	WHERE		code		= @p_result_code
	
	SET			@type	= 'Desk Collection Insert' + ' ' + @action_id + ' ' + @result_id + ' Pada Tanggal ' + CAST(ISNULL(@p_promise_date,'') AS NVARCHAR)
	
	SELECT		@hist_name		= NAME,
				@hist_amtlease	= AMTLEASE,
				@desk_col		= desk_col 
	FROM		LS_AGREEMENT 
	WHERE		LSAGREE			= @p_account_no
	
	-- Insert History Transaksi ke Contract_Activity_Histoy	Putri 2014-12-10
	EXEC xsp_contract_activity_history_insert @p_account_no, @p_collection_date, @type, @hist_name, @hist_amtlease, @p_id, @p_cre_by, @p_cre_date, @p_cre_ip_address, @p_mod_by, @p_mod_date, @p_mod_ip_address
	
	-- Insert collection_mak Chandra 12-01-2015
	exec xsp_collection_mak_insert 
		-1
		, @p_account_no
		, @p_collection_date
		, @action_id
		, @result_id
		, @p_remark
		, 'Desk Coll Result'
		, @p_cre_by
		, @p_cre_date
		, @p_cre_ip_address
		, @p_mod_by
		, @p_mod_date
		, @p_mod_ip_address
	
	/*select	@head_coll	= head
	from	sys_tblemployee
	where	code		= @desk_col
	
	if @head_coll is null 
	begin
		set @head_coll = @desk_col
	end
	
	exec xsp_collection_mak_request_insert
		0
		,@p_c_code
		,@p_account_no
		,@desk_col
		,@p_collection_date
		,@type
		,@p_remark
		,''
		,'Desk Collection'
		,'1'
		,@head_coll
		,@p_collection_date
		,@p_mod_by
		,@p_mod_ip_address
		,@p_collection_date
		,@p_mod_by
		,@p_mod_ip_address*/
		
end


