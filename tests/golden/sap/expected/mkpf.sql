with stg_sap__matdoc as (
  select *
  from main_sap.stg_sap__matdoc
)

select *
from stg_sap__matdoc
where (record_type = 'MDOC'and header_counter = 1)
