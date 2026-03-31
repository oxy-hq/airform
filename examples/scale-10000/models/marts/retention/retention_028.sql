with base as (select * from {{ ref('stg_channels_028') }}),
ranked as (select *, row_number() over (partition by session_id order by page_view_id) as rn from base)
select * from ranked where rn = 1
