--Window Function to calculate the ratio
select
  commodities,
  commodities_trx,
  disburse_per_commodity,
  round((disburse_per_commodity/sum(disburse_per_commodity) over ())*100,2) as ratio_to_disburse
from
(select
  distinct en.commodity as commodities,
  count(1) as commodities_trx,
  sum(ea.disbursement_amount) as disburse_per_commodity
from
  `group-data.p2p_access.dim_ecofin_nominatif` as en
right join
  `group-data.p2p_access.dim_ecofin_application` as ea
on
  en.individual_id = ea.individual_id
where
  en.commodity is not null
group by 1
order by 2 desc)
order by 2 desc
