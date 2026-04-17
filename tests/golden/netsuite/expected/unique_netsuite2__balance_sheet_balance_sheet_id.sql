select
    balance_sheet_id as unique_field,
    count(*) as n_records

from "netsuite"."main_netsuite"."netsuite2__balance_sheet"
where balance_sheet_id is not null
group by balance_sheet_id
having count(*) > 1
