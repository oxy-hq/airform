select
    segment_id as unique_field,
    count(*) as n_records

from "mailchimp"."main_stg_mailchimp"."stg_mailchimp__segments"
where segment_id is not null
group by segment_id
having count(*) > 1
