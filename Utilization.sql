-- utilization LF by transaction
-- ambil table disbursement dari dim_application lalu filter ke loan_product_type = "EF-Indirect"
-- filter portofolio_status_id = 14
-- ambil kolom client_id
-- transaksi petani perbulan

with farmer_transaction as 
(
select
  client_id,
  date(disburse_time,"Asia/Jakarta") as disburse_date,
  disbursement_amount 
from
  `alami-group-data.p2p_access.dim_application`
where
  loan_product_type = "EF-Indirect"
and
  portfolio_status_id = "14"
order by 2 desc
)

-- farmer line facility
, farmer_line_facility as 
(
select
  day,
  individual_id,
  line_facility_amount
from
  `alami-group-data.p2p_mart.summary_individual_line_facility_daily`
)

-- utilisasi dari seluruh transaksi/total LF
, utilization_all_trx as (
select
  date_trunc(ft.disburse_date, month) as month_disburse,
  client_id,
  sum(ft.disbursement_amount)/sum(flf.line_facility_amount) as all_utilization_lf_trx,
from
  farmer_transaction as ft
left join
  farmer_line_facility as flf
on
  ft.client_id = flf.individual_id
group by 1,2
order by 1 desc )

-- final battle
select
  month_disburse,
  sum(case when all_utilization_lf_trx >= 0 and all_utilization_lf_trx <= 0.25 then all_utilization_lf_trx else 0 end ) as uti_below_25,
  sum(case when all_utilization_lf_trx > 0.25 and all_utilization_lf_trx <= 0.50 then all_utilization_lf_trx else 0 end) as uti_25_50,
  sum(case when all_utilization_lf_trx > 0.50 and all_utilization_lf_trx <= 0.75 then all_utilization_lf_trx else 0 end) as uti_50_75,
  sum(case when all_utilization_lf_trx > 0.75 and all_utilization_lf_trx <= 1.00 then all_utilization_lf_trx else 0 end) as uti_75_100,
  sum(case when all_utilization_lf_trx > 1.00 then all_utilization_lf_trx else 0 end) as uti_above_100
from
  utilization_all_trx
where 
  utilization_all_trx.month_disburse is not null
group by 1 
order by 1
