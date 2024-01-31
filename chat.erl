%AUTHOR: MA. JAZMINE P. ROSELLOO
%PROGRAM DESCRIPTION: THIS PROGRAM IS ABOUT EXCHANGING MESSAGE AND RECEIVING MESSAGE FROM TWO TERMINAL OR PROCESS CONCURRENTLY.
%WHEN ONE OF THE PROCESS OR TERMINAL USER INPUTS BYE, IT TERMINATE THE PROGRAM.

-module ( chat) .
-compile ( export_all ) .

%JULIET
init_chat () ->
    String = io:get_line('Enter your name: '),
    P = string:strip(String, right, $\n), %ask for the name
    register(p1_print, spawn(chat, p1_print,[])), 
    register(p1_wait, spawn(chat, p1_wait, [P])).%register a process called as p1_print
    % p1_ask(P). %call the function where it will ask user for message input

%this function waits for p2 terminal, after p2 terminal input his/her name, it will now go here
p1_wait(Name) ->
    receive
        {p2_ask} ->
            p1_ask(Name) %and ask for p1_ask
    end.



%simplyy ask for message input and once there is a message, it will be passed to the p2_print
p1_ask(Name) ->
    M = string:strip(io:get_line('You: '), right, $\n),
    {p2_print, lists:nth(1,nodes())} ! {Name, M},
    % p1_ask(Name). %loop again so it will ask for message input again.
    if
        M =:= "bye" ->  init:stop();
        true ->  p1_ask(Name)
    end.
    
%simply prints the message being passed
p1_print() ->
    receive 
         %if the Reply is bye then terminals or processes must stop
        {NameOfSender, Reply} when Reply =:= "bye"->
            {p2_print, lists:nth(1,nodes())} ! terminate,
            init:stop(), %before terminating the terminal of this process, call the terminate to other process to it will also be terminated
            io:format("~s ended the chat ~n", [NameOfSender]);
            % init:stop();
        {NameOfSender, Reply} ->
            io:format("~s: ~s ~n", [NameOfSender, Reply]),
            p1_print(); %after printing the message call again its self function so it will be in condition of receiving
        terminate ->
            init:stop(),
            io:format("You ended the chat ~n")
            % init:stop()
    end.

%ROMEO
init_chat2 ( New_node ) ->
    String2 = io:get_line('Enter your name: '),
    N = string:strip(String2, right, $\n), %for asking for name that will be stored in N,
    register(p2_print, spawn(chat, p2_print, [])), %register a process in p2_print
    p2_ask(New_node, N). %call the function of p2_ask where it will ask for input message

%simply prints the message being passed
p2_print() ->
    receive 
        %if the Reply is bye then terminals or processes must stop
        {NameOfSender, Reply} when Reply =:= "bye" ->
            {p1_print, lists:nth(1,nodes())} ! terminate,
            init:stop(), %before terminating the terminal of this process, call the terminate to other process to it will also be terminated
            io:format(" ~s ended the chat ~n", [NameOfSender]);
            % init:stop();
        {NameOfSender, Reply} ->
            io:format("~s: ~s ~n", [NameOfSender, Reply]),
            p2_print(); %after printing the message call again its self function so it will be in condition of receiving
        terminate ->
            init:stop(),
            io:format("You ended the chat ~n")
            % init:stop()
    end.

%simplyy ask for message input and once there is a message, it will be passed to the p1_print
p2_ask(New_node, Name) ->
    {p1_wait, lists:nth(1,nodes())} ! {p2_ask}, %notify the p1 for asking message
    R =string:strip(io:get_line('You: '), right, $\n), %ask for input 
    {p1_print, lists:nth(1,nodes())} ! {Name, R},
    if
        R =:= "bye" ->  init:stop();
        true -> p2_ask(New_node, Name)
    end.%prints the output in other person's terminal by calling and passing it to p1_print
    % p2_ask(New_node, Name). %self loop


% net_adm:ping('Juliet@Jazmines-MacBook-Air').
% c(chat).
% chat:init_chat().
% chat:init_chat2('Juliet@Jazmines-MacBook-Air').

% c(sample).
% sample:init_chat().
% sample:init_chat2('Juliet@Jazmines-MacBook-Air').