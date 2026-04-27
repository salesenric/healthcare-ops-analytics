with rtt as (

    select *
    from {{ ref('stg_nhs_ops__rtt_waiting_times_base') }}

),

filtered as (

    select *
    from rtt
    where rtt_part_type = 'Part_2'
      and treatment_function_code != 'C_999'

),

final as (

    select
        period_month,
        period_end_date,

        provider_parent_org_code,
        provider_parent_name,
        provider_org_code,
        provider_org_name,

        commissioner_parent_org_code,
        commissioner_parent_name,
        commissioner_org_code,
        commissioner_org_name,

        treatment_function_code,
        treatment_function_name,

        total_pathways as incomplete_pathways_count,

        pathways_00_to_01_weeks,
        pathways_01_to_02_weeks,
        pathways_02_to_03_weeks,
        pathways_03_to_04_weeks,
        pathways_04_to_05_weeks,
        pathways_05_to_06_weeks,
        pathways_06_to_07_weeks,
        pathways_07_to_08_weeks,
        pathways_08_to_09_weeks,
        pathways_09_to_10_weeks,
        pathways_10_to_11_weeks,
        pathways_11_to_12_weeks,
        pathways_12_to_13_weeks,
        pathways_13_to_14_weeks,
        pathways_14_to_15_weeks,
        pathways_15_to_16_weeks,
        pathways_16_to_17_weeks,
        pathways_17_to_18_weeks,

        pathways_18_to_19_weeks,
        pathways_19_to_20_weeks,
        pathways_20_to_21_weeks,
        pathways_21_to_22_weeks,
        pathways_22_to_23_weeks,
        pathways_23_to_24_weeks,
        pathways_24_to_25_weeks,
        pathways_25_to_26_weeks,
        pathways_26_to_27_weeks,
        pathways_27_to_28_weeks,
        pathways_28_to_29_weeks,
        pathways_29_to_30_weeks,
        pathways_30_to_31_weeks,
        pathways_31_to_32_weeks,
        pathways_32_to_33_weeks,
        pathways_33_to_34_weeks,
        pathways_34_to_35_weeks,
        pathways_35_to_36_weeks,
        pathways_36_to_37_weeks,
        pathways_37_to_38_weeks,
        pathways_38_to_39_weeks,
        pathways_39_to_40_weeks,
        pathways_40_to_41_weeks,
        pathways_41_to_42_weeks,
        pathways_42_to_43_weeks,
        pathways_43_to_44_weeks,
        pathways_44_to_45_weeks,
        pathways_45_to_46_weeks,
        pathways_46_to_47_weeks,
        pathways_47_to_48_weeks,
        pathways_48_to_49_weeks,
        pathways_49_to_50_weeks,
        pathways_50_to_51_weeks,
        pathways_51_to_52_weeks,

        pathways_52_to_53_weeks,
        pathways_53_to_54_weeks,
        pathways_54_to_55_weeks,
        pathways_55_to_56_weeks,
        pathways_56_to_57_weeks,
        pathways_57_to_58_weeks,
        pathways_58_to_59_weeks,
        pathways_59_to_60_weeks,
        pathways_60_to_61_weeks,
        pathways_61_to_62_weeks,
        pathways_62_to_63_weeks,
        pathways_63_to_64_weeks,
        pathways_64_to_65_weeks,
        pathways_65_to_66_weeks,
        pathways_66_to_67_weeks,
        pathways_67_to_68_weeks,
        pathways_68_to_69_weeks,
        pathways_69_to_70_weeks,
        pathways_70_to_71_weeks,
        pathways_71_to_72_weeks,
        pathways_72_to_73_weeks,
        pathways_73_to_74_weeks,
        pathways_74_to_75_weeks,
        pathways_75_to_76_weeks,
        pathways_76_to_77_weeks,
        pathways_77_to_78_weeks,

        pathways_78_to_79_weeks,
        pathways_79_to_80_weeks,
        pathways_80_to_81_weeks,
        pathways_81_to_82_weeks,
        pathways_82_to_83_weeks,
        pathways_83_to_84_weeks,
        pathways_84_to_85_weeks,
        pathways_85_to_86_weeks,
        pathways_86_to_87_weeks,
        pathways_87_to_88_weeks,
        pathways_88_to_89_weeks,
        pathways_89_to_90_weeks,
        pathways_90_to_91_weeks,
        pathways_91_to_92_weeks,
        pathways_92_to_93_weeks,
        pathways_93_to_94_weeks,
        pathways_94_to_95_weeks,
        pathways_95_to_96_weeks,
        pathways_96_to_97_weeks,
        pathways_97_to_98_weeks,
        pathways_98_to_99_weeks,
        pathways_99_to_100_weeks,
        pathways_100_to_101_weeks,
        pathways_101_to_102_weeks,
        pathways_102_to_103_weeks,
        pathways_103_to_104_weeks,
        pathways_104_plus_weeks

    from filtered

)

select *
from final