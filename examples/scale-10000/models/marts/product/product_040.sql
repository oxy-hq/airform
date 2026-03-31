with base as (select * from {{ ref('stg_feature_usage_040') }}),
ranked as (select *, row_number() over (partition by account_id order by compliance_record_id) as rn from base)
select * from ranked where rn = 1
