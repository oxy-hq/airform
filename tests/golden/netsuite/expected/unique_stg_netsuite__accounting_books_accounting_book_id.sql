select
    accounting_book_id as unique_field,
    count(*) as n_records

from "netsuite"."main_netsuite_source"."stg_netsuite__accounting_books"
where accounting_book_id is not null
group by accounting_book_id
having count(*) > 1
