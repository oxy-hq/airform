with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),
renamed as (
    select
        id as campaign_id
,        status
,        budget
,        spend
,        goal
,        end_date
,        start_date
    from source
)
select * from renamed
