with base as (

    select 
        
    from "sap"."main_sap"."stg_sap__t006_tmp"
),

fields as (

    select
        
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 , 
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as boolean) as 
    
    _fivetran_sap_archived
    
 , 
    cast(null as TEXT) as 
    
    mandt
    
 , 
    cast(null as TEXT) as 
    
    msehi
    
 , 
    cast(null as TEXT) as 
    
    temp_unit
    
 , 
    cast(null as float) as 
    
    temp_value
    
 , 
    cast(null as numeric(28,6)) as 
    
    nennr
    
 , 
    cast(null as TEXT) as 
    
    kzex3
    
 , 
    cast(null as TEXT) as is_primary , 
    cast(null as numeric(28,6)) as 
    
    decan
    
 , 
    cast(null as TEXT) as 
    
    press_unit
    
 , 
    cast(null as TEXT) as 
    
    kzkeh
    
 , 
    cast(null as numeric(28,6)) as 
    
    exp10
    
 , 
    cast(null as numeric(28,6)) as 
    
    zaehl
    
 , 
    cast(null as TEXT) as 
    
    kz2eh
    
 , 
    cast(null as TEXT) as 
    
    famunit
    
 , 
    cast(null as float) as 
    
    press_val
    
 , 
    cast(null as numeric(28,6)) as 
    
    andec
    
 , 
    cast(null as TEXT) as 
    
    kz1eh
    
 , 
    cast(null as numeric(28,6)) as 
    
    addko
    
 , 
    cast(null as TEXT) as 
    
    isocode
    
 , 
    cast(null as TEXT) as 
    
    kzex6
    
 , 
    cast(null as numeric(28,6)) as 
    
    expon
    
 , 
    cast(null as TEXT) as 
    
    dimid
    
 , 
    cast(null as TEXT) as 
    
    kzwob
    
 


    from base
),

final as (

    select
        cast(mandt as TEXT) as mandt,
        cast(msehi as TEXT) as msehi,
        cast(temp_unit as TEXT) as temp_unit,
        temp_value,
        nennr,
        cast(kzex3 as TEXT) as kzex3,
        cast(is_primary as TEXT) as is_primary, --aliased in the get_t006_columns macro.
        decan,
        cast(press_unit as TEXT) as press_unit,
        cast(kzkeh as TEXT) as kzkeh,
        exp10,
        zaehl,
        cast(kz2eh as TEXT) as kz2eh,
        cast(famunit as TEXT) as famunit,
        press_val,
        andec,
        cast(kz1eh as TEXT) as kz1eh,
        addko,
        cast(isocode as TEXT) as isocode,
        cast(kzex6 as TEXT) as kzex6,
        expon,
        cast(dimid as TEXT) as dimid,
        cast(kzwob as TEXT) as kzwob,
        _fivetran_deleted,
        _fivetran_synced,
        _fivetran_sap_archived

    from fields

)

select * from final
