// Agent sample_agent in project stones

/* Initial beliefs and rules */

/* Initial goals */

/*Você pode modificar aqui a quantidade máxima de torres, pedras por torre e número de partidas*/
maxTowers(4).
maxStonesByTower(20).
maxPartidas(10).

endedGame :- not(tower(_,X) & X>0). //Test if there's a tower with more than 0 stones
otherplayer(A,B) :- player(A) & player(B) & A \== B.

!start.

/* Security */

+violation(Ag, Violation)[source(percept)] <-
    .print("!! VIOLATION !! Agent ", Ag, " ", Violation);
    if (.term2string(TermAg, Ag) & .all_names(L) & member(TermAg, L)) {
        .kill_agent(Ag);
        .print("!! KILLED !! Agent ", Ag, " because ", Violation);
        .stopMAS;
    }.

/* Plans */

+!start[source(self)]: maxPartidas(P)
    <- .print("hello world.");
       .date(Y,M,D); .time(H,Min,Sec,MilSec); // get current date & time
       +started(Y,M,D,H,Min,Sec);
       !startGames(P, aluno, debi). // Modifique aqui os nomes dos agentes que irão jogar ... não modifique mais nada no código do agente judge, pois na hora da apresentação o agente judge será o original

+!startGames(0,Ag1,Ag2)[source(self)].
+!startGames(N,Ag1,Ag2)[source(self)]: maxPartidas(P) <-
    !newGame(Ag1, Ag2,P-N+1);
    .wait(1000);
    !startGames(N-1,Ag2,Ag1).

+!setStonesForTowers(0)[source(self)].
+!setStonesForTowers(N)[source(self)]: maxStonesByTower(MaxStones) <-
    K = math.round(math.random(MaxStones) + 1);
    setAmountStonesTower(N,K);
    !setStonesForTowers(N-1).

+!newGame(Ag1, Ag2, P)[source(self)]: maxTowers(MaxTowers) <-
    .abolish(winner(_));

    reset;

    N = math.round(math.random(MaxTowers) + 1);
    setAmountTowers(N);

    !setStonesForTowers(N);
    
    addPlayer(Ag1);
    addPlayer(Ag2);

    startGame;
    
    .wait(winner(Who));
    .print("Partida ", P ," Winner is ", Who);

    .min([Ag1,Ag2], AgMin);
    .max([Ag1,Ag2], AgMax);
    .term2string(WhoTerm,Who);
    +winner(P, AgMin, AgMax, WhoTerm);
    .broadcast(tell, winner(P, AgMin, AgMax, WhoTerm));

    .count(winner(_, AgMin, AgMax, AgMin), TotAgMin);
    TotAgMax = P-TotAgMin;
    
    .print("Placar: ", AgMin, " ",TotAgMin," vs ",TotAgMax," ", AgMax);

    reset;
    -winner(Who).

+start[source(percept)] <- .print("Game started!").
+round(N,Who)[source(percept)] <- 
    //.findall(tower(T,K),tower(T,K),L);
    //.print("Round ", N, " Player ", Who, " Towers ", L);
    .wait(round(X, _) & X > N | endedGame, 1100, EventTime);
    if (.ground(EventTime) & EventTime >= 1100) {
        .print("Still same round ", N, " Player ", Who, " is sleeping ", EventTime);
        ?otherplayer(Who,Other);
        +winner(Other);
        .print("!! KILLED !! Agent ", Who, " because sleeping in its turn. The winner will be ", Other);
        .stopMAS;
    };
    !checkWinner.

+!checkWinner[source(self)]: endedGame & round(_, Who) & otherplayer(Who, Other) <-
    +winner(Other).
+!checkWinner[source(self)].

{ include("$jacamo/templates/common-cartago.asl") }
{ include("$jacamo/templates/common-moise.asl") }

// uncomment the include below to have an agent compliant with its organisation
//{ include("$moise/asl/org-obedient.asl") }

