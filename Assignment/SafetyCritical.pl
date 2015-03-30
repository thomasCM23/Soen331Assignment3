%% Facts
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
transition(lockdown, monidle, pruge_succ, null, 'isLockdown=false').

transition('prep_vpurge', 'alt_temp', 'initiate_purge', null, lock_doors).
transition('prep_vpurge', 'alt_psi', 'initiate_purge', null, lock_doors).
transition('alt_temp', 'risk_assess', 'tcyc_comp', null, null).
transition('alt_psi', 'risk_assess', 'psicyc_comp', null, null).
transition('risk_assess', 'alt_temp', null, 'risk>=1%', null).
transition('risk_assess', 'alt_psi', null, 'risk>=1%', null).
transition('risk_assess', 'safe_status', null, 'risk<1%', 'door_lock=false').

transition('error_rcv', 'reset_module_data', null, 'err_protocol_def==false', null).
transition('error_rcv', 'applicable_rescue', null, 'err_protocol_def==true', null).
transition('reset_module_data', 'final', 'reset_to_stable', null, null).
tranistion('applicable_rescue', 'final', 'apply_protocol_rescue', null, null).

%% Rules

%% succeeds by finding a loop edge. We assume that an edge can be represented by a non-null event-guard pair.
is_loop(Event, Guard) :- 
	transition(A, A, Event, Guard, _),
	Event not null
	Guard not null 

%% succeeds by returning a set of all loop edges.
all_loops(Set):- 
	findall(transition(_, _, Event, Guard, _), is_loop(Event, Guard), lst), 
	list_to_set(lst, Set). 

%% succeeds by finding an edge.

is_edge(Event, Guard):- 
	transition(_,_, Event, Guard, _), 
	Event not null 
	Guard not null

%% succeeds by returning the size of the entire EFSM (given by the numberof its edges).
size(Length):-
	findall(transition(_, _, Event, Guard, _), is_edge(Event, Guard), lst), 
	list_to_set(lst, Set),
	length(Set, Length).

%% succeeds by finding a link edge.

is_link(Event, Guard):-
	isEdge(Event, Guard),
	transition(_, _, Event, Guard, _).

%% succeeds by finding all superstates in the EFSM.

all_superstates(set):- 
	findall(State, superstate(State, _), lst), 
	list_to_set(lst, Set).

%% is a utility rule that succeeds by returning an ancestor to a given state.
ancestor(Ancestor, Descendant):- 
	superstate(Ancestor, Descendant).

ancestor(Ancestor, Descendant):- 
	superstate(Ancestor, Child), 
	ancestor(Child, Descendant).

%% succeeds by returning all transitions inherited by a given state.
inherites_transition(State, List):-
	findall(transition(State, _, _, _, _), transition(ancestor(_, State), _, _, _, _), List). 
	
%% succeeds by returning a list of all states.

all_states(lst):- 
	findall(State, state(State), lst).

%% succeeds by returning a list of all starting states.

all_inti_states(l):- 
	findall(State, initial_state(State, _), lst).

%% succeeds by returning the top-level starting state.

%%get_starting_state(State):- 
	transition(State)
	initial_state(State, _)

%% succeeds is State is reflexive.

state_is_reflective(State):- 
	transition(State, State, _, _, _,).

%% succeeds if the entire EFSM is reflexive.
%%graph_is_reflective:-
	state_is_reflective([state(_)]).

%%  succeeds by returning a set of all guards.
get_guards(Ret):- 
	findall(Guard, transition(_, _, _, Guard, _), lst), 
	list_to_set(lst, Ret).

%%  succeeds by returning a set of all events.
get_events(Ret):- 
	findall(Event, transition(_, _, Event, _, _), lst), 
	list_to_set(lst, Ret).

%%  succeeds by returning a set of all actions.
get_actions(Ret) :- 
	findall(Action, transition(_, _, _, _, Action), lst), 
	list_to_set(lst, Ret).
