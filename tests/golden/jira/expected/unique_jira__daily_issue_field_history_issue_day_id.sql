select
    issue_day_id as unique_field,
    count(*) as n_records

from "jira"."main_jira"."jira__daily_issue_field_history"
where issue_day_id is not null
group by issue_day_id
having count(*) > 1
