function [ output_args ] = run_all_protocols()

[res_viapoint_multi] = run_multi_learning('viapoint_multi');
save('saved_results/multi_runs/res_viapoint_multi', 'res_viapoint_multi');

[res_viapoint_advanced_multi] = run_multi_learning('viapoint_advanced_multi');
save('saved_results/multi_runs/res_viapoint_advanced_multi', 'res_viapoint_advanced_multi');

[res_viapoint_advancedx_multi] = run_multi_learning('viapoint_advancedx_multi');
save('saved_results/multi_runs/res_viapoint_advancedx_multi', 'res_viapoint_advancedx_multi');

[res_viapoint_advancedx_var_multi] = run_multi_learning('viapoint_advancedx_var_multi');
save('saved_results/multi_runs/res_viapoint_advancedx_var_multi', 'res_viapoint_advancedx_var_multi');

[res_viapoint_single] = run_multi_learning('viapoint_single');
save('saved_results/multi_runs/res_viapoint_single', 'res_viapoint_single');

[res_viapoint_advanced_single] = run_multi_learning('viapoint_advanced_single');
save('saved_results/multi_runs/res_viapoint_advanced_single', 'res_viapoint_advanced_single');

[res_viapoint_advancedx_single] = run_multi_learning('viapoint_advancedx_single');
save('saved_results/multi_runs/res_viapoint_advancedx_single', 'res_viapoint_advancedx_single');

[res_viapoint_advancedx_var_single] = run_multi_learning('viapoint_advancedx_var_single');
save('saved_results/multi_runs/res_viapoint_advancedx_var_single', 'res_viapoint_advancedx_var_single');

end