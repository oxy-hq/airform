select
    list_id as unique_field,
    count(*) as n_records

from "mailchimp"."main_stg_mailchimp"."stg_mailchimp__lists"
where list_id is not null
group by list_id
having count(*) > 1
