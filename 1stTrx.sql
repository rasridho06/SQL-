with PII as 
(
select
  da.client_id as client_id_PII,
  AEAD.DECRYPT_STRING(dak.keyset,da.client_name,da.app_id) as farmer_name
from
  `alami-group-data.p2p_access.dim_application` as da
left join
  `alami-group-data.p2p_access_enigma.dim_application_keys` as dak
on da.app_id = dak.id 
where
  da.company_id = "2c91808274029f1c017402f293560005" or da.company_id = "2c918082835230120183547eb56906dd"
order by 2
)

, first_trx as 
(
select
  client_id as client_id,
  company_name_short,
  min(date(disburse_time, "Asia/Jakarta")) as first_disburse
from
  `group-data.p2p_access.dim_application`
group by 1,2
)

select
  date_trunc(date(da.disburse_time, "Asia/Jakarta"), month) as month,
  da.company_name_short,
  case when date_trunc(date(da.disburse_time, "Asia/Jakarta"), month) = date_trunc(ft.first_disburse,month) then "New Farmer" else "Repeat Farmer" end as Farmer_Category,
  count(distinct ft.client_id) as total_trx,
  sum(da.disbursement_amount) as total_disburse
from
  `group-data.p2p_access.dim_application` as da
left join
  first_trx as ft
on da.client_id = ft.client_id
where
  da.loan_product_type ="EF-Indirect"
and
  (da.company_id = "2c91808274029f1c017402f293560005" or da.company_id = "2c918082835230120183547eb56906dd")
and
  date_trunc(date(disburse_time, "Asia/Jakarta"), month) is not null 
group by 1,2,3
order by 1
