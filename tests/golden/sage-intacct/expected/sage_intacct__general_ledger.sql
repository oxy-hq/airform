with  __dbt__cte__int_sage_intacct__active_gl_detail as (


with gl_detail as (
    select * 
    from "sage_intacct"."main_sage_intacct_staging"."stg_sage_intacct__gl_detail" 

), gl_batch as (
    select * 
    from "sage_intacct"."main_sage_intacct_staging"."stg_sage_intacct__gl_batch" 

), final as (
    select
        gl_detail.*,
        gl_batch.is_batch_deleted
    from gl_detail
    left join gl_batch
        on gl_batch.record_no = gl_detail.batch_key
        and gl_batch.source_relation = gl_detail.source_relation
    where not coalesce(gl_batch.is_batch_deleted, false) 
        and not coalesce(gl_detail.is_detail_deleted, false) 
)

select *
from final
), gl_detail as (
    select * 
    from __dbt__cte__int_sage_intacct__active_gl_detail 
),

gl_account as (
    select * 
    from "sage_intacct"."main_sage_intacct"."int_sage_intacct__account_classifications" 
),

general_ledger as (

    select

    gld.source_relation,
    gld.gl_detail_id,
    gld.account_no,
    gld.account_title,
    round(cast(gld.amount as numeric(28,6)),2) as amount,
    gld.book_id,
    gld.credit_amount,
    gld.debit_amount,
    gld.currency,
    gld.description,
    gld.doc_number,
    gld.customer_id,
    gld.customer_name,
    gld.entry_date_at,
    gld.entry_state,
    gld.entry_description,
    gld.line_no,
    gld.record_id,
    gld.record_type,
    gld.total_due,
    gld.total_entered,
    gld.total_paid,
    gld.tr_type,
    gld.trx_amount,
    gld.trx_credit_amount,
    gld.trx_debit_amount,
    gld.vendor_id,
    gld.vendor_name,
    gld.created_at,
    gld.due_at,
    gld.modified_at,
    gld.paid_at,
    gla.category,
    gla.classification,
    gla.account_type 

    --The below script allows for pass through columns.
    

    

    from gl_detail gld
    left join gl_account gla
        on gld.account_no = gla.account_no
        and gld.source_relation = gla.source_relation
)

select * 
from general_ledger
