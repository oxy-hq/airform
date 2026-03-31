with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),

renamed as (
    select
        id as campaign_id
,        channel
,        budget
,        status
    from source
)

select * from renamed
