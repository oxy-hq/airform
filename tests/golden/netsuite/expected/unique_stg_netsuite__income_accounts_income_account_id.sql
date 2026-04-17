select
    income_account_id as unique_field,
    count(*) as n_records

from "netsuite"."main_netsuite_source"."stg_netsuite__income_accounts"
where income_account_id is not null
group by income_account_id
having count(*) > 1
