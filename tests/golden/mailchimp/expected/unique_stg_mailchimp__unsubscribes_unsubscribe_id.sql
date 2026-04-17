select
    unsubscribe_id as unique_field,
    count(*) as n_records

from "mailchimp"."main_stg_mailchimp"."stg_mailchimp__unsubscribes"
where unsubscribe_id is not null
group by unsubscribe_id
having count(*) > 1
