#!/usr/bin/env escript
%%! -noshell

%% FizzBuzz as an example of why function pattern matching is good and bad.
%%
%% - Order matters. rem(x, 15) must come first.
%% - Guards support arithmetic natively, so this is less awkward than in Elixir.
%% - Complex cases still have to go inside function bodies.
%%
%% Pattern matches save you one or two indentations. That's not nothing.

main(Args) ->
    Results = lists:map(fun convert/1, Args),
    lists:foreach(fun(R) -> io:format("~s~n", [R]) end, Results).

convert(X) when is_list(X) ->
    %% escript args arrive as strings (character lists), not binaries
    case string:to_integer(X) of
        {I, ""} -> convert_integer(I);
        _ -> X
    end;
convert(X) when is_integer(X) ->
    convert_integer(X);
convert(X) ->
    X.

convert_integer(X) when X rem 15 =:= 0 -> "FizzBuzz";
convert_integer(X) when X rem 3 =:= 0 -> "Fizz";
convert_integer(X) when X rem 5 =:= 0 -> "Buzz";
convert_integer(X) -> integer_to_list(X).