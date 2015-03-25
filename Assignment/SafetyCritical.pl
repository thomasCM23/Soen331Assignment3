%% states

state(dormant).
state(init).
state(idle).
state(monitoring).
state('error_diagnosis').
state('safe_shutdown').
state('boot_hw').
state(senchk).
state(tchk).
state(ready).
state(monidle).
state('regulate_environment').
state(lockdown).
state('prep_vpurge').
state('alt_temp').
state('alt_psi').
state('risk_assess').
state('safe_status').
state('error_rcv').
state('reset_module_data').
state('applicable_rescue').

%% initial states

initial_state(dormant, null).
initial_state('boot_hw', init).
initial_state(monidle, monitor).
initial_state('prep_vpurge', lockdown).
initial_state('error_rcv', 'error_diagnosis').

%% super states

superstate(init, 'boot_hw').
superstate(init, senchk).
superstate(init, tchk).
superstate(init, pcichk).
superstate(init, ready).

superstate(monitoring, monidle).
superstate(monitoring, lockdown).
superstate(monitoring, 'regulate_environment').


superstate(lockdown, 'prep_vpurge').
superstate(lockdown, 'alt_temp').
superstate(lockdown, 'alt_psi').
superstate(lockdown, 'risk_assess').
superstate(lockdown, 'safe_status').

superstate('error_diagnosis', 'error_rcv').
superstate('error_diagnosis', 'reset_module_date').
superstate('error_diagnosis', 'applicable_resucue').

%% transitions

transition(dormant, init, start, null, null).
transition(init, idle, 'init_ok', null, null).
transition(init, 'error_diagnosis', 'init_error', null, null).
transition(idle, monitoring, 'beging_monitoring', null, null).
transition(idle, 'error_diagnosis', 'idle_crash', null, 'idle_err_msg').
transition(monitoring, 'error_diagnosis', 'monitor_crash', null, 'monitor_err_msg').
transition('error_diagnosis', 'safe_shutdown', null, 'retry >= 3', 'shutdown').
transition('error_diagnosis', init, 'rety_init','redy < 3', 'retry++').
transition('error_diagnosis', idle, 'idle_rescue', null, null).
transition('error_diagnosis', monitoring, 'monitor_rescue', null, null).
transition('safe_shutdown', dormant, 'sleep', null, null).

transition('boot_hw', senchk, 'hw_ok', null, null).
transition(senchk, tchk, senok, null, null).
transition(tchk, psichk, 't_ok', null, null).
transition(psichk, ready, 'psi_ok', null, null).

transition(monidle, 'regulate_environment', 'no_contagion', 'after(1 unit time)', null).
transition(monidle, lockdown, 'contagion_alert', null, 'FACILTIY_ALERT_MSG, isLockdown=true').
transition(lockdown, lockdown, null, 'isLockdown==true', null).
transi


