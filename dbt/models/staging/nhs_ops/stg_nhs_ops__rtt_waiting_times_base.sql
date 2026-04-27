with source as (

    select *
    from {{ source('nhs_ops_raw', 'rtt_waiting_times_base') }}

),

renamed as (

    select
        -- source period fields
        period as source_period_label,
        date(timestamp_micros(div(source_period_month, 1000))) as period_month,
        date(timestamp_micros(div(source_period_end, 1000))) as period_end_date,

        -- provider hierarchy
        provider_parent_org_code,
        provider_parent_name,
        provider_org_code,
        provider_org_name,

        -- commissioner hierarchy
        commissioner_parent_org_code,
        commissioner_parent_name,
        commissioner_org_code,
        commissioner_org_name,

        -- RTT classification
        rtt_part_type,
        rtt_part_description,

        -- treatment function
        treatment_function_code,
        treatment_function_name,

        -- waiting-time bands
        cast(gt_00_to_01_weeks_sum_1 as int64) as pathways_00_to_01_weeks,
        cast(gt_01_to_02_weeks_sum_1 as int64) as pathways_01_to_02_weeks,
        cast(gt_02_to_03_weeks_sum_1 as int64) as pathways_02_to_03_weeks,
        cast(gt_03_to_04_weeks_sum_1 as int64) as pathways_03_to_04_weeks,
        cast(gt_04_to_05_weeks_sum_1 as int64) as pathways_04_to_05_weeks,
        cast(gt_05_to_06_weeks_sum_1 as int64) as pathways_05_to_06_weeks,
        cast(gt_06_to_07_weeks_sum_1 as int64) as pathways_06_to_07_weeks,
        cast(gt_07_to_08_weeks_sum_1 as int64) as pathways_07_to_08_weeks,
        cast(gt_08_to_09_weeks_sum_1 as int64) as pathways_08_to_09_weeks,
        cast(gt_09_to_10_weeks_sum_1 as int64) as pathways_09_to_10_weeks,
        cast(gt_10_to_11_weeks_sum_1 as int64) as pathways_10_to_11_weeks,
        cast(gt_11_to_12_weeks_sum_1 as int64) as pathways_11_to_12_weeks,
        cast(gt_12_to_13_weeks_sum_1 as int64) as pathways_12_to_13_weeks,
        cast(gt_13_to_14_weeks_sum_1 as int64) as pathways_13_to_14_weeks,
        cast(gt_14_to_15_weeks_sum_1 as int64) as pathways_14_to_15_weeks,
        cast(gt_15_to_16_weeks_sum_1 as int64) as pathways_15_to_16_weeks,
        cast(gt_16_to_17_weeks_sum_1 as int64) as pathways_16_to_17_weeks,
        cast(gt_17_to_18_weeks_sum_1 as int64) as pathways_17_to_18_weeks,

        cast(gt_18_to_19_weeks_sum_1 as int64) as pathways_18_to_19_weeks,
        cast(gt_19_to_20_weeks_sum_1 as int64) as pathways_19_to_20_weeks,
        cast(gt_20_to_21_weeks_sum_1 as int64) as pathways_20_to_21_weeks,
        cast(gt_21_to_22_weeks_sum_1 as int64) as pathways_21_to_22_weeks,
        cast(gt_22_to_23_weeks_sum_1 as int64) as pathways_22_to_23_weeks,
        cast(gt_23_to_24_weeks_sum_1 as int64) as pathways_23_to_24_weeks,
        cast(gt_24_to_25_weeks_sum_1 as int64) as pathways_24_to_25_weeks,
        cast(gt_25_to_26_weeks_sum_1 as int64) as pathways_25_to_26_weeks,
        cast(gt_26_to_27_weeks_sum_1 as int64) as pathways_26_to_27_weeks,
        cast(gt_27_to_28_weeks_sum_1 as int64) as pathways_27_to_28_weeks,
        cast(gt_28_to_29_weeks_sum_1 as int64) as pathways_28_to_29_weeks,
        cast(gt_29_to_30_weeks_sum_1 as int64) as pathways_29_to_30_weeks,
        cast(gt_30_to_31_weeks_sum_1 as int64) as pathways_30_to_31_weeks,
        cast(gt_31_to_32_weeks_sum_1 as int64) as pathways_31_to_32_weeks,
        cast(gt_32_to_33_weeks_sum_1 as int64) as pathways_32_to_33_weeks,
        cast(gt_33_to_34_weeks_sum_1 as int64) as pathways_33_to_34_weeks,
        cast(gt_34_to_35_weeks_sum_1 as int64) as pathways_34_to_35_weeks,
        cast(gt_35_to_36_weeks_sum_1 as int64) as pathways_35_to_36_weeks,
        cast(gt_36_to_37_weeks_sum_1 as int64) as pathways_36_to_37_weeks,
        cast(gt_37_to_38_weeks_sum_1 as int64) as pathways_37_to_38_weeks,
        cast(gt_38_to_39_weeks_sum_1 as int64) as pathways_38_to_39_weeks,
        cast(gt_39_to_40_weeks_sum_1 as int64) as pathways_39_to_40_weeks,
        cast(gt_40_to_41_weeks_sum_1 as int64) as pathways_40_to_41_weeks,
        cast(gt_41_to_42_weeks_sum_1 as int64) as pathways_41_to_42_weeks,
        cast(gt_42_to_43_weeks_sum_1 as int64) as pathways_42_to_43_weeks,
        cast(gt_43_to_44_weeks_sum_1 as int64) as pathways_43_to_44_weeks,
        cast(gt_44_to_45_weeks_sum_1 as int64) as pathways_44_to_45_weeks,
        cast(gt_45_to_46_weeks_sum_1 as int64) as pathways_45_to_46_weeks,
        cast(gt_46_to_47_weeks_sum_1 as int64) as pathways_46_to_47_weeks,
        cast(gt_47_to_48_weeks_sum_1 as int64) as pathways_47_to_48_weeks,
        cast(gt_48_to_49_weeks_sum_1 as int64) as pathways_48_to_49_weeks,
        cast(gt_49_to_50_weeks_sum_1 as int64) as pathways_49_to_50_weeks,
        cast(gt_50_to_51_weeks_sum_1 as int64) as pathways_50_to_51_weeks,
        cast(gt_51_to_52_weeks_sum_1 as int64) as pathways_51_to_52_weeks,

        cast(gt_52_to_53_weeks_sum_1 as int64) as pathways_52_to_53_weeks,
        cast(gt_53_to_54_weeks_sum_1 as int64) as pathways_53_to_54_weeks,
        cast(gt_54_to_55_weeks_sum_1 as int64) as pathways_54_to_55_weeks,
        cast(gt_55_to_56_weeks_sum_1 as int64) as pathways_55_to_56_weeks,
        cast(gt_56_to_57_weeks_sum_1 as int64) as pathways_56_to_57_weeks,
        cast(gt_57_to_58_weeks_sum_1 as int64) as pathways_57_to_58_weeks,
        cast(gt_58_to_59_weeks_sum_1 as int64) as pathways_58_to_59_weeks,
        cast(gt_59_to_60_weeks_sum_1 as int64) as pathways_59_to_60_weeks,
        cast(gt_60_to_61_weeks_sum_1 as int64) as pathways_60_to_61_weeks,
        cast(gt_61_to_62_weeks_sum_1 as int64) as pathways_61_to_62_weeks,
        cast(gt_62_to_63_weeks_sum_1 as int64) as pathways_62_to_63_weeks,
        cast(gt_63_to_64_weeks_sum_1 as int64) as pathways_63_to_64_weeks,
        cast(gt_64_to_65_weeks_sum_1 as int64) as pathways_64_to_65_weeks,
        cast(gt_65_to_66_weeks_sum_1 as int64) as pathways_65_to_66_weeks,
        cast(gt_66_to_67_weeks_sum_1 as int64) as pathways_66_to_67_weeks,
        cast(gt_67_to_68_weeks_sum_1 as int64) as pathways_67_to_68_weeks,
        cast(gt_68_to_69_weeks_sum_1 as int64) as pathways_68_to_69_weeks,
        cast(gt_69_to_70_weeks_sum_1 as int64) as pathways_69_to_70_weeks,
        cast(gt_70_to_71_weeks_sum_1 as int64) as pathways_70_to_71_weeks,
        cast(gt_71_to_72_weeks_sum_1 as int64) as pathways_71_to_72_weeks,
        cast(gt_72_to_73_weeks_sum_1 as int64) as pathways_72_to_73_weeks,
        cast(gt_73_to_74_weeks_sum_1 as int64) as pathways_73_to_74_weeks,
        cast(gt_74_to_75_weeks_sum_1 as int64) as pathways_74_to_75_weeks,
        cast(gt_75_to_76_weeks_sum_1 as int64) as pathways_75_to_76_weeks,
        cast(gt_76_to_77_weeks_sum_1 as int64) as pathways_76_to_77_weeks,
        cast(gt_77_to_78_weeks_sum_1 as int64) as pathways_77_to_78_weeks,

        cast(gt_78_to_79_weeks_sum_1 as int64) as pathways_78_to_79_weeks,
        cast(gt_79_to_80_weeks_sum_1 as int64) as pathways_79_to_80_weeks,
        cast(gt_80_to_81_weeks_sum_1 as int64) as pathways_80_to_81_weeks,
        cast(gt_81_to_82_weeks_sum_1 as int64) as pathways_81_to_82_weeks,
        cast(gt_82_to_83_weeks_sum_1 as int64) as pathways_82_to_83_weeks,
        cast(gt_83_to_84_weeks_sum_1 as int64) as pathways_83_to_84_weeks,
        cast(gt_84_to_85_weeks_sum_1 as int64) as pathways_84_to_85_weeks,
        cast(gt_85_to_86_weeks_sum_1 as int64) as pathways_85_to_86_weeks,
        cast(gt_86_to_87_weeks_sum_1 as int64) as pathways_86_to_87_weeks,
        cast(gt_87_to_88_weeks_sum_1 as int64) as pathways_87_to_88_weeks,
        cast(gt_88_to_89_weeks_sum_1 as int64) as pathways_88_to_89_weeks,
        cast(gt_89_to_90_weeks_sum_1 as int64) as pathways_89_to_90_weeks,
        cast(gt_90_to_91_weeks_sum_1 as int64) as pathways_90_to_91_weeks,
        cast(gt_91_to_92_weeks_sum_1 as int64) as pathways_91_to_92_weeks,
        cast(gt_92_to_93_weeks_sum_1 as int64) as pathways_92_to_93_weeks,
        cast(gt_93_to_94_weeks_sum_1 as int64) as pathways_93_to_94_weeks,
        cast(gt_94_to_95_weeks_sum_1 as int64) as pathways_94_to_95_weeks,
        cast(gt_95_to_96_weeks_sum_1 as int64) as pathways_95_to_96_weeks,
        cast(gt_96_to_97_weeks_sum_1 as int64) as pathways_96_to_97_weeks,
        cast(gt_97_to_98_weeks_sum_1 as int64) as pathways_97_to_98_weeks,
        cast(gt_98_to_99_weeks_sum_1 as int64) as pathways_98_to_99_weeks,
        cast(gt_99_to_100_weeks_sum_1 as int64) as pathways_99_to_100_weeks,
        cast(gt_100_to_101_weeks_sum_1 as int64) as pathways_100_to_101_weeks,
        cast(gt_101_to_102_weeks_sum_1 as int64) as pathways_101_to_102_weeks,
        cast(gt_102_to_103_weeks_sum_1 as int64) as pathways_102_to_103_weeks,
        cast(gt_103_to_104_weeks_sum_1 as int64) as pathways_103_to_104_weeks,
        cast(gt_104_weeks_sum_1 as int64) as pathways_104_plus_weeks,

        -- totals
        cast(total as int64) as pathways_with_known_clock_start_date,
        cast(patients_with_unknown_clock_start_date as int64) as pathways_with_unknown_clock_start_date,
        cast(total_all as int64) as total_pathways,

        -- ingestion metadata
        source_zip_file,
        source_csv_file,
        ingestion_ts

    from source

)

select *
from renamed