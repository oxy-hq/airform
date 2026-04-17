with

    pa0000_beg as (
        select
            pernr,
            begda as date_change
        from "sap"."main_sap"."stg_sap__pa0000"
    ),

    pa0000_end as (
        select
            pernr,
			case when endda = '99991231' then endda
				else 

    to_char(dateadd(day, 1, to_date(endda, 'YYYYMMDD')), 'YYYYMMDD')

 
				end as date_change
		from "sap"."main_sap"."stg_sap__pa0000"
	), 

    pa0001_beg as (
        select
            pernr,
            begda as date_change
        from "sap"."main_sap"."stg_sap__pa0001"
    ),

    pa0001_end as (
        select
            pernr,
			case when endda = '99991231' then endda
				else 

    to_char(dateadd(day, 1, to_date(endda, 'YYYYMMDD')), 'YYYYMMDD')

 
				end as date_change
		from "sap"."main_sap"."stg_sap__pa0001"
	), 

    pa0007_beg as (
        select
            pernr,
            begda as date_change
        from "sap"."main_sap"."stg_sap__pa0007"
    ),

    pa0007_end as (
        select
            pernr,
			case when endda = '99991231' then endda
				else 

    to_char(dateadd(day, 1, to_date(endda, 'YYYYMMDD')), 'YYYYMMDD')

 
				end as date_change
		from "sap"."main_sap"."stg_sap__pa0007"
	), 

    pa0008_beg as (
        select
            pernr,
            begda as date_change
        from "sap"."main_sap"."stg_sap__pa0008"
    ),

    pa0008_end as (
        select
            pernr,
			case when endda = '99991231' then endda
				else 

    to_char(dateadd(day, 1, to_date(endda, 'YYYYMMDD')), 'YYYYMMDD')

 
				end as date_change
		from "sap"."main_sap"."stg_sap__pa0008"
	), 

    pa0031_beg as (
        select
            pernr,
            begda as date_change
        from "sap"."main_sap"."stg_sap__pa0031"
    ),

    pa0031_end as (
        select
            pernr,
			case when endda = '99991231' then endda
				else 

    to_char(dateadd(day, 1, to_date(endda, 'YYYYMMDD')), 'YYYYMMDD')

 
				end as date_change
		from "sap"."main_sap"."stg_sap__pa0031"
	), 



unioned as (

	
		select 
			pernr,
			date_change 
		from pa0000_beg 

		union all

		select 
			pernr,
			date_change 
		from pa0000_end 

		
		union all
		 
	
		select 
			pernr,
			date_change 
		from pa0001_beg 

		union all

		select 
			pernr,
			date_change 
		from pa0001_end 

		
		union all
		 
	
		select 
			pernr,
			date_change 
		from pa0007_beg 

		union all

		select 
			pernr,
			date_change 
		from pa0007_end 

		
		union all
		 
	
		select 
			pernr,
			date_change 
		from pa0008_beg 

		union all

		select 
			pernr,
			date_change 
		from pa0008_end 

		
		union all
		 
	
		select 
			pernr,
			date_change 
		from pa0031_beg 

		union all

		select 
			pernr,
			date_change 
		from pa0031_end 

		 
	
),
	

unioned_dates as (
	
	select pernr, date_change 
	from unioned
	group by 1,2
	order by pernr, date_change
),

employee_date_ranges as (

	select 
		pernr,
		date_change as begda,
		lead(date_change, 1) over (partition by pernr order by date_change) as endda      
	from unioned_dates			
),

employee_original_date_ranges as (

	select
		pernr,
		begda,
		case when endda = '99991231' then endda
			else 

    to_char(dateadd(day, -1, to_date(endda, 'YYYYMMDD')), 'YYYYMMDD')

 
			end as endda
	from employee_date_ranges
)

select * 
from employee_original_date_ranges
