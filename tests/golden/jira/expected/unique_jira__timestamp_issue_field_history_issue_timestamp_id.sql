select
    issue_timestamp_id as unique_field,
    count(*) as n_records

from "jira"."main_jira"."jira__timestamp_issue_field_history"
where issue_timestamp_id is not null
group by issue_timestamp_id
having count(*) > 1
