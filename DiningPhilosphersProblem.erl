-module(dpp).
-compile(export_all).

%College class which spawns 5 Fork processes and assigns them var names,
%Spawns 5 philosopher processes
college() ->

   
    Fork1 = spawn_link(?MODULE, fork, ["Fork 1"]),
    Fork2 = spawn_link(?MODULE, fork, ["Fork 2"]), 
    Fork3 = spawn_link(?MODULE, fork, ["Fork 3"]),
    Fork4 = spawn_link(?MODULE, fork, ["Fork 4"]),
    Fork5 = spawn_link(?MODULE, fork, ["Fork 5"]),

%Fork ordering based on philosopers
%
% 5 - 1
% 1 - 2
% 2 - 3
% 3 - 4
% 4 - 5

spawn_link(?MODULE, philosopher, ["Aristotle",thinking, Fork5, Fork1]),
spawn_link(?MODULE, philosopher, ["Plato",thinking, Fork1, Fork2]),
spawn_link(?MODULE, philosopher, ["Socrates",thinking, Fork2, Fork3]),
spawn_link(?MODULE, philosopher, ["Ludwig",thinking, Fork3, Fork4]),
spawn_link(?MODULE, philosopher, ["Confucius",thinking, Fork4, Fork5]).

%Fork process which receives a pick_up and put_down message from the philopsher.
%If pick_up is received, pick up the left fork and print out the name of the fork in use.

%If put_down is received then drop the fork and print out the name of the fork that was in use.
fork(Philosopher) ->
    receive
        {pick_up,PID} ->
            PID ! {picked_up, self()},
            io:format("~s : in use ~n", [Philosopher]),
            receive
                {put_down, PID} ->

                    io:format("~s : put down ~n", [Philosopher]),
                    fork(Philosopher)
            end
    end.
            
%The philosoper

%Philosopher alternates between 3 states, thinking, hungry and eating.
%When the philopsher is thinking, they transition into hungry after some time.
%When a philopsher is hungry they will pick up the fork to their left, this is assigned to them.

%A philopsher will then attempt to pick up the right fork.
%The philopsher will then begin eating then put both forks down.

%The process then repeats recursively.

philosopher(Philosopher, thinking, LeftFork, RightFork) -> 
    io:format("~s : is thinking ~n", [Philosopher]),
    sleep(rand:uniform(1000)),
    philosopher(Philosopher,hungry,LeftFork, RightFork);
    philosopher(Philosopher,hungry, LeftFork, RightFork) ->
   
    io:format("~s : is hungry ~n", [Philosopher]),

    LeftFork ! {pick_up, self()},
    receive
        {picked_up, LeftFork} ->
        io:format("~s : got left fork ~n", [Philosopher]),
    philosopher(Philosopher, has_LeftFork, LeftFork, RightFork)
    end;
   
philosopher(Philosopher, has_LeftFork,LeftFork,RightFork) ->
    
    RightFork ! {pick_up, self()},
    receive
        {picked_up, RightFork} ->
            io:format("~s : got right fork ~n", [Philosopher]),
            philosopher(Philosopher, eating, LeftFork, RightFork)
    end;
    
philosopher(Philosopher, eating, LeftFork, RightFork) ->
    
     io:format("~s : eating ~n", [Philosopher]),
     LeftFork ! {put_down, self()},
     RightFork ! {put_down, self()},
     sleep(rand:uniform(1000)),
     philosopher(Philosopher, thinking, LeftFork, RightFork).
    
sleep(T) ->
    receive
        after T ->
            true
    end.

% ------ Question 2 -----

%----- Part 2 ------
%Question 1

%In my system, there is an extremely low chance of an actual deadlock occuring.
%for a deadlock to occur, there would need to be an occurance of philopshers going for the left fork at the same time,
%the times from rand:uniform could line up so that this happens.

%Question 2

%Deadlock could be prevented by firstly by checking the state of the right fork after picking up the left,
%if the right fork isnot free then we could potentially put a timer on it, recurse over hungry again, pick up the left fork
%then check for the right fork again after some time. this would give time for the right fork to open up again.


