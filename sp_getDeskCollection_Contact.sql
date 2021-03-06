USE [MNC_GUI_SSS]
GO
/****** Object:  StoredProcedure [dbo].[getDeskCollection_Contact]    Script Date: 27/01/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[getDeskCollection_Contact]
--exec getDeskCollection_Contact
AS  
BEGIN 
declare @tempAgree table
(
	lsagree varchar(50),
	overdue int,
	lsperiod int,
	os_period int,
	paywith varchar(5),
	lessee varchar(10),
	c_code varchar(5), 
	mktcode varchar(50),
	module int,
	outstanding_ar float,
	product_facility_code int
)

insert into @tempAgree
select lsagree, overdue, lsperiod, os_period, paywith, lessee, C_CODE, mktcode, module, outstanding_ar, product_facility_code 
from ls_agreement
where	LSAGREE in (
	select Data.LSAGREE from (
	--- belum jatuh tempo OVD -3
	select lsagree, overdue from ls_agreement agree 
	where (isnull(agree.overdue,0) between -4 and -2) -- bucket DC overdue -3 sampai 7
	and agree.MODULE not in ( 5,6 )
	and agree.contract_status = 'GOLIVE'
	and agree.OUTSTANDING_AR > 0
	and agree.lsagree not in ( -- kecuali yang pernah di telepon hingga 3 hari kebelakang 
		select account_no
		from account_collection (NOLOCK)
		where cast(collection_date as date) between dateadd(day,-3,getdate()) and cast(getdate() as date) and ACTION_ID <> '124'
	)
	UNION ALL
	-- jatuh tempo hari ini -1 dan belum pernah ditelp
	select agree.LSAGREE, overdue from ls_agreement agree 
	where agree.LSAGREE IN (
				select LSAGREE
				FROM (
					select a.LSAGREE, PERIOD, DUEDATE, sum(payment) payment
					from LS_LEDGERRENTAL a with(NOLOCK)
					inner join LS_AGREEMENT b with(NOLOCK) on a.LSAGREE = b.LSAGREE
					where b.MODULE not in ( 5,6 ) and b.CONTRACT_STATUS = 'GOLIVE'
					GROUP BY a.LSAGREE, PERIOD, DUEDATE
					having sum(PAYMENT) > 0
				) as X
				group by LSAGREE
				having cast(min(duedate) as date) = cast(dateadd(day,-1,getdate()) as date)
		)	
		and	agree.lsagree not in (
								select account_no
								from account_collection (NOLOCK)
								where cast(collection_date as date) = cast(getdate() as date) and ACTION_ID <> '124'
		)
	UNION ALL
	-- OVD sampai 7 dan dalam 7 hari kebelakang belum pernah di telp
	select lsagree, overdue from ls_agreement agree
		where agree.overdue between 2 and 6
		and agree.MODULE not in ( 5,6 )
		and agree.contract_status = 'GOLIVE'
		and agree.OUTSTANDING_AR > 0
		and	agree.lsagree not in (
									select account_no
									from account_collection (NOLOCK)
									where cast(collection_date as date) between dateadd(day,-7,getdate()) and cast(getdate() as date) and ACTION_ID <> '124'
	)
	UNION ALL
	select la.lsagree, la.overdue -- yg janji bayar di hari ini
	from account_collection col with(NOLOCK)
		inner join master_action act with(NOLOCK) on col.action_id = act.id
		inner join ls_agreement la with(NOLOCK) on col.account_no = la.lsagree
		where	act.code = 'PTP'
		AND CONVERT(date, PROMISE_DATE) = CONVERT(date, getdate()-1)-- and CONVERT(date, getdate()+1) --PTP 
		AND	ISNULL(la.overdue, 0) between 1 and 7-- batas_bwh between (@batas_awal*-1) and @batas_bwh
		AND la.CONTRACT_STATUS = 'GOLIVE'
		AND la.MODULE not in ( 5,6 )
	UNION ALL
	select la.lsagree, la.overdue 
	from account_collection col with(NOLOCK)
	inner join master_action act with(NOLOCK) on col.action_id = act.id
	inner join ls_agreement la with(NOLOCK) on col.account_no = la.lsagree
	where act.code = 'MSG' and convert(date, col.collection_date) = CONVERT(date, getdate()-1)
	and la.OVERDUE > 0
	) Data
)

select	agree.lsagree as contract_no,
		cli.name,
		'' as contact_person,-- belum tau maksudnya
		isnull(cli.address1,'')+ ' ' + isnull(cli.address2,'')+ ' ' + isnull(cli.address3,'') + ', ' + KOTA as 'address',
		sc.C_NAME as branch_name,
		se.descs as marketing_name,
		case cli.STATUS
			when '1' then isnull(cli.INMAILTELP,'0')
			when '2' then isnull(cli.CONTACTHP,'0')
		end phone1,
		'' as phone2,
		'' as phone3,
		'' as phone4,
		case when isnull(agree.overdue, 0) + 1 < 0 then 0 else isnull(agree.overdue, 0) + 1 end as 'overdue',
		llr.period as 'installmentnumber',
		agree.lsperiod as total_installmentnumber,
		convert(varchar,llr.duedate, 23) as duedate_installment,
		case agree.paywith
			when 1 then 'Transfer'
			when 2 then 'Giro/Cheq'
			when 3 then 'Payment Point'
			when 4 then 'Auto Debet'
			when 5 then 'Cash'
		end payment_methode,
		lav.description as description_assets, -- collateral > 1 
		agree.lessee as customer_code,
		(llr.interest + llr.principal) as installment_amount,
		isnull(llp.penalty,0) as pinalty,
		(llr.interest + llr.principal) + isnull(llp.penalty,0) as total_amount,
		agree.outstanding_ar as osar,
		(llrl.interest + llrl.principal)*-1 as lastpaid_amount,
		llrl.duedate as lastpaid_duedate,
		llrl.period as lastpaid_tenor,
		convert(varchar, llrl.cre_date, 23) as lastpaid_paydate,
		pf.description as product,
		'1' as flag_dedicated

from @tempAgree agree
inner join sys_client cli with(NOLOCK) on agree.lessee  COLLATE Latin1_General_CI_AS = cli.client	
left join sys_company sc with(NOLOCK) on agree.C_CODE  COLLATE Latin1_General_CI_AS = sc.C_CODE
left join sys_tblemployee se with(NOLOCK) on agree.mktcode  COLLATE Latin1_General_CI_AS = se.code
left join (
	select lsagree, max(period) lastPayPeriod from ls_ledgerrental 
	where lsagree  COLLATE Latin1_General_CI_AS in (select lsagree from @tempAgree) and payment < 0
	group by lsagree
) llren on agree.lsagree COLLATE Latin1_General_CI_AS = llren.lsagree
left join LS_LEDGERRENTAL llr with(NOLOCK) on agree.lsagree  COLLATE Latin1_General_CI_AS = llr.lsagree and (llren.lastPayPeriod + 1) = llr.period
left join (
	select lsagree, isnull(sum(DR_CR),0) penalty  from LS_LEDGERPENALTY 
	where lsagree COLLATE Latin1_General_CI_AS in (select lsagree from @tempAgree)
	group by lsagree
) llp on agree.lsagree  COLLATE Latin1_General_CI_AS = llp.lsagree
left join ls_ledgerrental llrl with(NOLOCK) on agree.lsagree  COLLATE Latin1_General_CI_AS = llrl.lsagree and isnull(llren.lastPayPeriod,0) = llrl.period and llrl.payment < 0
left join product_facility pf with(NOLOCK) on pf.code  COLLATE Latin1_General_CI_AS = agree.product_facility_code
left join LS_ASSETVEHICLE lav with(NOLOCK) on lav.lsagree = agree.lsagree collate Latin1_General_CI_AS
END