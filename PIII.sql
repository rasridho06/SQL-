--Personally Identifiable Information (PII) 
with PII as (
select
  denk.id as id,
  AEAD.DECRYPT_STRING(denk.keyset,den.nominative_identity_number, den.id) as ktp_petani,
  --AEAD.DECRYPT_STRING digunakan untuk mendecrypt PII atau informasi identitas 
  -- 1=denk.keyset mengacu ke keyset dari table decrypt. misal kita mendecrypt dim_ecofin_nominatif, berarti harus join ke table p2p_access_enigma.dim_ecofin_nominatif_keys
  -- 2=mengacu ke column yang ingin didecrypt atau dibuka datanya, Misal kita ingin mendecrypt nominative_name, maka parameter ke 2 ini diisi dengan den.nominative_name
  -- 3=mengacu ke support key untuk parameter 2, contohnya kita ingin men-decrypt dim_ecofin_nominatif.nominative_name di sheet itu sudah distate bahwa support keynya adalah id.  Sehingga parameter ke-3 diisi dengan den.id
  AEAD.DECRYPT_STRING(denk.keyset,den.nominative_name, den.id) as farmer_name,
  AEAD.DECRYPT_STRING(denk.keyset,den.spouse_identity_number, den.id) as ktp_spouse,
  AEAD.DECRYPT_STRING(denk.keyset,den.spouse_name, den.id) as spouse_name
from
  `group-data.p2p_access.dim_ecofin_nominatif` as den
left join
  `group-data.p2p_access_enigma.dim_ecofin_nominatif_keys` as denk
on den.id = denk.id --on pada join menyesuaikan dengan sheet pada P2P Access Layer Design
)

, line_facility as
(
select
  date(line_facility_sent_time, "Asia/Jakarta") as approved_time,
  de.id as id,
  df.id as id2,
  status,
  status_message,
  credit_score,
  submission_method,
  lokasi_point,
  line_facility_amount
from
  `group-data.p2p_access.dim_ecofin_nominatif` as de
left join
  `group-data.p2p_access.dim_individual_line_facility` as df
on
  de.individual_id = df.individual_id
where
  (de.submission_method="API" or de.submission_method="Manual")
and
  (status_message="Line Facility Sent" or status_message="Line Facility Signed") 
and
  (de.partner_id ="2c91808274029f1c017402f293560005" or de.partner_id ="2c918082835230120183547eb56906dd")
  --jika tidak menggunakan tanda kurung, maka query setelah And yaitu status message akan dieksekusi terlebih dahulu
  --jika menggunakan tanda kurung maka query dalam tanda kurung akan dieksekusi setelah "where = submission method=API"
  --OR digunakan jika salah satu kondisi terpenuhi maka return the value
  --AND digunakan dengan minimal 2 kondisi terpenuhi maka return the value, jika salah satu atau keduanya tidak terpenuhi maka akan Null/No
order by 1 desc
)

select
  pii.id,
  PII.ktp_petani,
  PII.farmer_name,
  PII.ktp_spouse,
  PII.spouse_name,
  lf.approved_time,
  lf.status,
  lf.credit_score,
  lf.submission_method,
  lf.lokasi_point,
  max(lf.line_facility_amount) as latest_lf,
  min(lf.line_facility_amount) as lf_before_upgrading
from
  PII 
left join
  line_facility as lf
on PII.id = lf.id
where
  lf.status is not null
group by 1,2,3,4,5,6,7,8,9,10
order by 3 
