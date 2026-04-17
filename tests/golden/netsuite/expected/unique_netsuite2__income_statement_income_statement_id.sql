select
    income_statement_id as unique_field,
    count(*) as n_records

from "netsuite"."main_netsuite"."netsuite2__income_statement"
where income_statement_id is not null
group by income_statement_id
having count(*) > 1
