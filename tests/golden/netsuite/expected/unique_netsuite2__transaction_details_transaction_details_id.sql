select
    transaction_details_id as unique_field,
    count(*) as n_records

from "netsuite"."main_netsuite"."netsuite2__transaction_details"
where transaction_details_id is not null
group by transaction_details_id
having count(*) > 1
